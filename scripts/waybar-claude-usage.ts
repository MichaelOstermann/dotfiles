#!/usr/bin/env bun
// NOTE: Shamelessly vibe-coded
// Waybar custom module: Claude Code usage.
//
// Merges the former get-claude-usage.sh (data collection) and
// waybar-claude-usage.sh (rendering) into one Bun/TypeScript file. Requires no
// install — Bun runs .ts directly. Emits a single JSON line: {text, tooltip, class}.
//
// Sources:
//   ~/.claude/projects/**/*.jsonl            assistant turns (default profile)
//   ~/.ccs/instances/*/projects/**/*.jsonl   extra CCS profiles (aggregated in)
//   ~/.claude/.credentials.json              oauth token + subscription
//   Anthropic oauth usage API                5h / 7d rate-limit utilization
//   LiteLLM price table                      per-family token pricing (cached daily)
//
// PERSISTENT ACCUMULATOR (~/.claude/waybar-usage-stats.json)
// ---------------------------------------------------------
// Claude Code prunes old session .jsonl files, so a plain scan only ever sees a
// rolling ~2-month window — "all-time" from disk alone is a lie. To fix this we
// bank every file's contribution in our own state file, keyed by absolute path,
// and NEVER delete banked entries. When Claude later prunes a file, its numbers
// stay banked, so all-time is truly monotonic from the day tracking starts.
//
// The archive is lossless for accounting: for every (date, model) pair we store
// EVERY numeric leaf field found under message.usage (input/output/cache tokens,
// ephemeral 1h/5m cache split, web_search/web_fetch requests, and anything
// Anthropic adds later — flattened generically). Displayed metrics (fresh tokens,
// cost, …) are just views computed over that raw archive, so we can re-slice it
// any way later without having thrown information away.
//
// Files whose mtime+size are unchanged since the last run are reused from the
// archive without re-parsing, so scan cost stays flat as history grows.

import {
  readFileSync,
  writeFileSync,
  existsSync,
  renameSync,
  readdirSync,
  statSync,
  rmSync,
} from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { execSync } from "node:child_process";

// --- Paths & constants ---------------------------------------------------------
const CLAUDE_DIR = join(homedir(), ".claude");
const CREDENTIALS = join(CLAUDE_DIR, ".credentials.json");
const PROJECTS_DIR = join(CLAUDE_DIR, "projects");
const PRICING_CACHE = join(CLAUDE_DIR, "pricing-cache.json");
const USAGE_CACHE = join(CLAUDE_DIR, "usage-cache.json");
const STATE_FILE = join(CLAUDE_DIR, "waybar-usage-stats.json");
const STATE_VERSION = 1;
const USAGE_CACHE_TTL = 120; // seconds
const LITELLM_URL =
  "https://raw.githubusercontent.com/BerriAI/litellm/main/model_prices_and_context_window.json";

const SEP = "\t"; // (date, model) key separator (tab: never in a date or model id)

let CLAUDE_VERSION = "2.0.0";
try {
  const m = execSync("claude --version", { encoding: "utf8" }).match(/[\d.]+/);
  if (m) CLAUDE_VERSION = m[0];
} catch {}

// --- Local date helpers --------------------------------------------------------
// Bucket by LOCAL calendar date so day/week/month boundaries match `date`-based
// intuition. new Date(isoUtc) parses the UTC instant; the get*() accessors then
// yield local components — equivalent to the old jq strflocaltime() dance.
const pad = (n: number) => String(n).padStart(2, "0");
const localDate = (d: Date) =>
  `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;

const now = new Date();
const TODAY = localDate(now);
const dowMon = (now.getDay() + 6) % 7; // 0 = Monday … 6 = Sunday
const WEEK_START = localDate(
  new Date(now.getFullYear(), now.getMonth(), now.getDate() - dowMon),
);
const MONTH_START = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-01`;

function tsToLocalDate(ts: string): string {
  if (!ts) return "1970-01-01";
  const d = new Date(ts);
  return isNaN(d.getTime()) ? "1970-01-01" : localDate(d);
}

// --- Pricing (refresh from LiteLLM once per day) -------------------------------
interface Price {
  input: number;
  output: number;
  cache_read: number;
  cache_write: number;
}
interface Pricing {
  updated: string;
  models: Record<string, Price>;
}

async function refreshPricing(): Promise<Pricing | null> {
  try {
    const res = await fetch(LITELLM_URL, { signal: AbortSignal.timeout(10_000) });
    if (!res.ok) return null;
    const raw = (await res.json()) as Record<string, any>;

    // Keep only "claude-{family}-{major}-{minor}" (no date suffix / provider
    // prefix) with real pricing, then take the latest key per family.
    const byFamily = new Map<string, { key: string; v: any }>();
    for (const [key, v] of Object.entries(raw)) {
      if (!/^claude-[a-z]+-[0-9]+-[0-9]+$/.test(key)) continue;
      if (!(v?.input_cost_per_token > 0)) continue;
      const family = key.split("-")[1];
      const cur = byFamily.get(family);
      if (!cur || key > cur.key) byFamily.set(family, { key, v });
    }
    if (byFamily.size === 0) return null;

    const models: Record<string, Price> = {};
    for (const [family, { v }] of byFamily) {
      models[family] = {
        input: v.input_cost_per_token ?? 0,
        output: v.output_cost_per_token ?? 0,
        cache_read: v.cache_read_input_token_cost ?? 0,
        cache_write: v.cache_creation_input_token_cost ?? 0,
      };
    }
    const pricing: Pricing = { updated: TODAY, models };
    try {
      writeFileSync(PRICING_CACHE, JSON.stringify(pricing));
    } catch {}
    return pricing;
  } catch {
    return null;
  }
}

async function loadPricing(): Promise<Pricing | null> {
  let cached: Pricing | null = null;
  if (existsSync(PRICING_CACHE)) {
    try {
      cached = JSON.parse(readFileSync(PRICING_CACHE, "utf8"));
    } catch {}
  }
  if (cached && cached.updated === TODAY) return cached;
  // Stale or missing: try to refresh, but keep the stale copy if refresh fails.
  return (await refreshPricing()) ?? cached;
}

const familyOf = (model: string): string => {
  const p = model.split("-");
  return p.length >= 3 && p[0] === "claude" ? p[1] : model;
};

// --- Profiles: default + CCS instances -----------------------------------------
interface Profile {
  name: string;
  projects: string;
  creds: string;
  usageCache: string;
}

function collectProfiles(): Profile[] {
  const profiles: Profile[] = [];
  if (existsSync(PROJECTS_DIR)) {
    profiles.push({
      name: "default",
      projects: PROJECTS_DIR,
      creds: CREDENTIALS,
      usageCache: USAGE_CACHE,
    });
  }
  const ccsDir = join(homedir(), ".ccs", "instances");
  if (existsSync(ccsDir)) {
    for (const entry of readdirSync(ccsDir, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      const proj = join(ccsDir, entry.name, "projects");
      if (!existsSync(proj)) continue;
      const name = entry.name.replace(/[,|:]/g, "");
      if (!name) continue;
      profiles.push({
        name,
        projects: proj,
        creds: join(ccsDir, entry.name, ".credentials.json"),
        usageCache: join(CLAUDE_DIR, `usage-cache-${name}.json`),
      });
    }
  }
  return profiles;
}

// --- Persistent accumulator ----------------------------------------------------
// One entry per session file we've ever seen. `sessions` maps sessionId ->
// earliest local date seen (usually a single entry). `buckets` is keyed by
// `${date}${SEP}${model}` and holds a message count plus a generic bag of every
// numeric usage counter summed for that (date, model).
interface Bucket {
  messages: number;
  counters: Record<string, number>;
}
interface FileEntry {
  mtimeMs: number;
  size: number;
  sessions: Record<string, string>;
  buckets: Record<string, Bucket>;
}
interface State {
  version: number;
  files: Record<string, FileEntry>;
}

function loadState(): State {
  if (existsSync(STATE_FILE)) {
    try {
      const s = JSON.parse(readFileSync(STATE_FILE, "utf8"));
      if (s && s.files) return { version: STATE_VERSION, files: s.files };
    } catch {}
  }
  return { version: STATE_VERSION, files: {} };
}

function saveState(state: State): void {
  const tmp = `${STATE_FILE}.${process.pid}.tmp`;
  try {
    writeFileSync(tmp, JSON.stringify(state));
    renameSync(tmp, STATE_FILE);
  } catch {
    try {
      rmSync(tmp);
    } catch {}
  }
}

function findJsonl(dir: string): string[] {
  const out: string[] = [];
  const stack = [dir];
  while (stack.length) {
    const d = stack.pop()!;
    let entries;
    try {
      entries = readdirSync(d, { withFileTypes: true });
    } catch {
      continue;
    }
    for (const e of entries) {
      const p = join(d, e.name);
      if (e.isDirectory()) stack.push(p);
      else if (e.isFile() && e.name.endsWith(".jsonl")) out.push(p);
    }
  }
  return out;
}

// Flatten every numeric leaf under an object into dotted keys, so we archive all
// usage counters that exist (now or in future) without hardcoding them. Arrays
// are skipped — the usage.iterations[] array just re-states the top-level totals
// and would double-count.
function flattenNumeric(
  obj: any,
  prefix: string,
  out: Record<string, number>,
): void {
  if (!obj || typeof obj !== "object" || Array.isArray(obj)) return;
  for (const [k, v] of Object.entries(obj)) {
    if (typeof v === "number" && isFinite(v)) {
      out[prefix + k] = (out[prefix + k] ?? 0) + v;
    } else if (v && typeof v === "object" && !Array.isArray(v)) {
      flattenNumeric(v, `${prefix}${k}.`, out);
    }
  }
}

function parseFile(path: string, mtimeMs: number, size: number): FileEntry {
  const entry: FileEntry = { mtimeMs, size, sessions: {}, buckets: {} };
  let text: string;
  try {
    text = readFileSync(path, "utf8");
  } catch {
    return entry;
  }
  for (const line of text.split("\n")) {
    if (!line) continue;
    let rec: any;
    try {
      rec = JSON.parse(line);
    } catch {
      continue;
    }
    if (rec?.type !== "assistant") continue;

    const date = tsToLocalDate(rec.timestamp ?? "");
    const model = rec.message?.model ?? "unknown";
    const sess = rec.sessionId ?? "unknown";
    const prev = entry.sessions[sess];
    if (!prev || date < prev) entry.sessions[sess] = date;

    const key = `${date}${SEP}${model}`;
    const bucket = (entry.buckets[key] ??= { messages: 0, counters: {} });
    bucket.messages++;
    flattenNumeric(rec.message?.usage ?? {}, "", bucket.counters);
  }
  return entry;
}

// Re-parse only changed/new files; leave banked (incl. now-deleted) entries intact.
function updateState(state: State, profiles: Profile[]): void {
  for (const profile of profiles) {
    for (const path of findJsonl(profile.projects)) {
      let st;
      try {
        st = statSync(path);
      } catch {
        continue;
      }
      const cur = state.files[path];
      if (cur && cur.mtimeMs === st.mtimeMs && cur.size === st.size) continue;
      state.files[path] = parseFile(path, st.mtimeMs, st.size);
    }
  }
}

// --- Metrics derived from the archive ------------------------------------------
const c = (b: Bucket, key: string) => b.counters[key] ?? 0;
// "Fresh" tokens: each distinct token once (input + output + cache_write).
// cache_read is excluded — it's the same cached context re-read every turn.
const freshTokens = (b: Bucket) =>
  c(b, "input_tokens") + c(b, "output_tokens") + c(b, "cache_creation_input_tokens");
// Cost bills ALL four token types (cache_read included, at its discounted rate).
const bucketCost = (b: Bucket, p?: Price) =>
  p
    ? c(b, "input_tokens") * p.input +
      c(b, "output_tokens") * p.output +
      c(b, "cache_read_input_tokens") * p.cache_read +
      c(b, "cache_creation_input_tokens") * p.cache_write
    : 0;

interface Period {
  tokens: number;
  cost: number;
  models: Map<string, number>;
}
interface Metrics {
  today: Period;
  week: Period;
  month: Period;
  allTokens: number;
  allCost: number;
  allMsgs: number;
  allSessions: number;
}

const newPeriod = (): Period => ({ tokens: 0, cost: 0, models: new Map() });

function addTo(p: Period, family: string, tokens: number, cost: number): void {
  p.tokens += tokens;
  p.cost += cost;
  p.models.set(family, (p.models.get(family) ?? 0) + tokens);
}

function computeMetrics(state: State, pricing: Pricing | null): Metrics {
  const m: Metrics = {
    today: newPeriod(),
    week: newPeriod(),
    month: newPeriod(),
    allTokens: 0,
    allCost: 0,
    allMsgs: 0,
    allSessions: 0,
  };
  const sessions = new Set<string>();

  for (const entry of Object.values(state.files)) {
    for (const s of Object.keys(entry.sessions)) sessions.add(s);
    for (const [key, bucket] of Object.entries(entry.buckets)) {
      const sepIdx = key.indexOf(SEP);
      const date = key.slice(0, sepIdx);
      const model = key.slice(sepIdx + 1);
      const family = familyOf(model);
      const price = pricing?.models[family];
      const fresh = freshTokens(bucket);
      const cost = bucketCost(bucket, price);

      m.allTokens += fresh;
      m.allCost += cost;
      m.allMsgs += bucket.messages;

      if (date === TODAY) addTo(m.today, family, fresh, cost);
      if (date >= WEEK_START) addTo(m.week, family, fresh, cost);
      if (date >= MONTH_START) addTo(m.month, family, fresh, cost);
    }
  }
  m.allSessions = sessions.size;
  return m;
}

// --- Rate-limit usage (default profile only; that's all the tooltip shows) -----
interface Usage {
  subType: string;
  fiveUtil: number;
  fiveReset: string;
  sevenUtil: number;
  sevenReset: string;
}

async function fetchUsage(p: Profile): Promise<Usage> {
  const blank: Usage = {
    subType: "unknown",
    fiveUtil: 0,
    fiveReset: "",
    sevenUtil: 0,
    sevenReset: "",
  };
  if (!existsSync(p.creds)) return blank;

  let creds: any = {};
  try {
    creds = JSON.parse(readFileSync(p.creds, "utf8"));
  } catch {}
  const subType = creds?.claudeAiOauth?.subscriptionType ?? "unknown";
  const token = creds?.claudeAiOauth?.accessToken ?? "";

  // Serve from cache while fresh; keep stale data as a fallback if the fetch fails.
  let data: any = {};
  let fresh = false;
  if (existsSync(p.usageCache)) {
    try {
      const cache = JSON.parse(readFileSync(p.usageCache, "utf8"));
      data = cache.data ?? {};
      if (Math.floor(Date.now() / 1000) - (cache.cached_at ?? 0) < USAGE_CACHE_TTL)
        fresh = true;
    } catch {}
  }

  if (!fresh && token) {
    try {
      const res = await fetch("https://api.anthropic.com/api/oauth/usage", {
        headers: {
          Authorization: `Bearer ${token}`,
          Accept: "application/json",
          "Content-Type": "application/json",
          "User-Agent": `claude-code/${CLAUDE_VERSION}`,
          "anthropic-beta": "oauth-2025-04-20",
        },
        signal: AbortSignal.timeout(5_000),
      });
      if (res.ok) {
        const j = (await res.json()) as any;
        if (j?.five_hour) {
          data = j;
          // Atomic write: overlapping refreshes must not interleave into the cache.
          const tmp = `${p.usageCache}.${process.pid}.tmp`;
          try {
            writeFileSync(
              tmp,
              JSON.stringify({ cached_at: Math.floor(Date.now() / 1000), data: j }),
            );
            renameSync(tmp, p.usageCache);
          } catch {
            try {
              rmSync(tmp);
            } catch {}
          }
        }
      }
    } catch {}
  }

  return {
    subType,
    fiveUtil: data?.five_hour?.utilization ?? 0,
    fiveReset: data?.five_hour?.resets_at ?? "",
    sevenUtil: data?.seven_day?.utilization ?? 0,
    sevenReset: data?.seven_day?.resets_at ?? "",
  };
}

// --- Formatting ----------------------------------------------------------------
function fmtTokens(n: number): string {
  if (n >= 1e9) return (n / 1e9).toFixed(1) + "B";
  if (n >= 1e6) return (n / 1e6).toFixed(1) + "M";
  if (n >= 1e3) return (n / 1e3).toFixed(1) + "k";
  return String(n);
}

function fmtReset(iso: string): string {
  if (!iso) return "?";
  const t = new Date(iso).getTime();
  if (isNaN(t)) return "?";
  const diff = Math.floor((t - Date.now()) / 1000);
  if (diff < 0) return "now";
  if (diff >= 86400)
    return `${Math.floor(diff / 86400)}d ${pad(Math.floor((diff % 86400) / 3600))}h`;
  return `${Math.floor(diff / 3600)}h ${pad(Math.floor((diff % 3600) / 60))}m`;
}

const fmtUtil = (n: number) => n.toFixed(1);
const fmtCost = (n: number) => n.toFixed(2);
const capitalize = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

function fmtPeriod(title: string, p: Period): string {
  const rows = [...p.models.entries()]
    .filter(([, v]) => v > 0)
    .sort((a, b) => b[1] - a[1])
    .map(([name, v]) => `- ${capitalize(name).padEnd(7)}${fmtTokens(v)}`);
  return [
    title,
    `Cost   $${fmtCost(p.cost)}`,
    `Tokens ${fmtTokens(p.tokens)}`,
    ...rows,
  ].join("\n");
}

// --- Main ----------------------------------------------------------------------
const profiles = collectProfiles();
const pricing = await loadPricing();

// Kick the network usage request off first so it overlaps the (sync) file scan.
const usagePromise = profiles.length
  ? fetchUsage(profiles[0])
  : Promise.resolve<Usage>({
      subType: "unknown",
      fiveUtil: 0,
      fiveReset: "",
      sevenUtil: 0,
      sevenReset: "",
    });

const state = loadState();
updateState(state, profiles);
saveState(state);
const t = computeMetrics(state, pricing);
const usage = await usagePromise;

const utilInt = Math.floor(usage.fiveUtil);
const klass = utilInt >= 90 ? "critical" : utilInt >= 70 ? "warning" : "normal";
const text = `${fmtUtil(usage.fiveUtil)}%`;

const tooltip = [
  `Claude Code (${usage.subType})`,
  `5h: ${fmtUtil(usage.fiveUtil)}% - resets in ${fmtReset(usage.fiveReset)}`,
  `7d: ${fmtUtil(usage.sevenUtil)}% - resets in ${fmtReset(usage.sevenReset)}`,
  ``,
  fmtPeriod("Today", t.today),
  ``,
  fmtPeriod("Week", t.week),
  ``,
  fmtPeriod("Month", t.month),
  ``,
  `All-time`,
  `${t.allSessions} sessions`,
  `${t.allMsgs} messages`,
  `${fmtTokens(t.allTokens)} tokens`,
  `$${fmtCost(t.allCost)}`,
].join("\n");

console.log(JSON.stringify({ text, tooltip, class: klass }));
