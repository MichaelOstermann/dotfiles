#!/usr/bin/env bun
// Background daemon (ported from mako-unread-watch.sh). Watches the session bus
// for org.freedesktop.Notifications.Notify calls and keeps a short rolling log
// for the waybar notifications module — presence of any log entry means "unread"
// (no count is tracked). Started once at session startup. Bun runs .ts directly.

import {
  readFileSync,
  writeFileSync,
  existsSync,
  mkdirSync,
} from "node:fs";
import { homedir } from "node:os";
import { join, dirname } from "node:path";
import { spawn } from "node:child_process";

const LOG_FILE = join(homedir(), ".cache", "waybar-unread-log.jsonl");
const BLACKLIST_FILE = join(import.meta.dir, "mako-blacklist.txt");
const MAX_LOG = 10;

mkdirSync(dirname(LOG_FILE), { recursive: true });
if (!existsSync(LOG_FILE)) writeFileSync(LOG_FILE, "");

// Blacklisted app names (one per line, "#" comments allowed).
const blacklist = new Set<string>();
if (existsSync(BLACKLIST_FILE)) {
  for (const raw of readFileSync(BLACKLIST_FILE, "utf8").split("\n")) {
    const entry = raw.replace(/#.*$/, "").trim();
    if (entry) blacklist.add(entry);
  }
}

function readLog(): string[] {
  try {
    return readFileSync(LOG_FILE, "utf8").split("\n").filter(Boolean);
  } catch {
    return [];
  }
}

function writeLog(lines: string[]): void {
  writeFileSync(LOG_FILE, lines.length ? lines.join("\n") + "\n" : "");
}

function record(app: string, summary: string): void {
  const entry = JSON.stringify({ app, summary, ts: Math.floor(Date.now() / 1000) });
  let lines = readLog();
  lines.push(entry);
  if (lines.length > MAX_LOG) lines = lines.slice(-MAX_LOG);
  writeLog(lines);
}

// Notification app names and niri app ids differ only in case for the apps that
// matter here ("Slack" vs "slack"), so a case-insensitive match is enough.
function clearApp(appId: string): void {
  const lines = readLog();
  const kept = lines.filter((line) => {
    try {
      return JSON.parse(line).app.toLowerCase() !== appId.toLowerCase();
    } catch {
      return true;
    }
  });
  if (kept.length !== lines.length) writeLog(kept);
}

// dbus-monitor prints each top-level Notify arg indented exactly 3 spaces (nested
// array/dict contents are indented further and must be skipped). In the Notify
// signature arg 1 is the app name and arg 4 is the summary.
const TOP_LEVEL_ARG = /^ {3}[^ ]/;
const QUOTED = /"(.*)"/;

let collecting = false;
let argn = 0;
let app = "";

function handleLine(line: string): void {
  if (line.startsWith("method call") && line.includes("member=Notify")) {
    collecting = true;
    argn = 0;
    app = "";
    return;
  }
  if (!collecting || !TOP_LEVEL_ARG.test(line)) return;

  argn++;
  if (argn === 1) {
    app = QUOTED.exec(line)?.[1] ?? "";
  } else if (argn === 4) {
    const summary = QUOTED.exec(line)?.[1] ?? "";
    collecting = false;
    // Skip notifications with no app name (e.g. terminal bell) and anything
    // blacklisted — they can't be shown meaningfully, so don't count them.
    if (app && !blacklist.has(app)) record(app, summary);
  }
}

// niri's WindowFocusChanged only carries a window id, so the app id has to be
// tracked from the window events.
const windowApps = new Map<number, string>();

function handleNiriEvent(line: string): void {
  let event: any;
  try {
    event = JSON.parse(line);
  } catch {
    return;
  }

  if (event.WindowsChanged) {
    windowApps.clear();
    for (const w of event.WindowsChanged.windows) windowApps.set(w.id, w.app_id);
  } else if (event.WindowOpenedOrChanged) {
    const w = event.WindowOpenedOrChanged.window;
    windowApps.set(w.id, w.app_id);
  } else if (event.WindowClosed) {
    windowApps.delete(event.WindowClosed.id);
  } else if (event.WindowFocusChanged) {
    const appId = windowApps.get(event.WindowFocusChanged.id);
    if (appId) clearApp(appId);
  }
}

const niri = spawn("niri", ["msg", "--json", "event-stream"], {
  stdio: ["ignore", "pipe", "ignore"],
});

let niriBuf = "";
niri.stdout.on("data", (chunk: Buffer) => {
  niriBuf += chunk.toString("utf8");
  let nl: number;
  while ((nl = niriBuf.indexOf("\n")) >= 0) {
    handleNiriEvent(niriBuf.slice(0, nl));
    niriBuf = niriBuf.slice(nl + 1);
  }
});

const proc = spawn(
  "dbus-monitor",
  [
    "--session",
    "type='method_call',interface='org.freedesktop.Notifications',member='Notify'",
  ],
  { stdio: ["ignore", "pipe", "ignore"] },
);

let buf = "";
proc.stdout.on("data", (chunk: Buffer) => {
  buf += chunk.toString("utf8");
  let nl: number;
  while ((nl = buf.indexOf("\n")) >= 0) {
    handleLine(buf.slice(0, nl));
    buf = buf.slice(nl + 1);
  }
});
proc.on("exit", (code) => process.exit(code ?? 0));
