#!/usr/bin/env bun
// Waybar weather module (ported from waybar-weather.sh). Runs no install — Bun
// runs .ts directly. Emits one JSON line: {text, tooltip, class}.
//
// Fetches location + current conditions from wttr.in and a 7-day forecast from
// open-meteo, caches the merged result for 30 min, and renders a tooltip.

import { readFileSync, writeFileSync, existsSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const CACHE = join(homedir(), ".cache", "waybar-weather.json");
const CACHE_TTL = 1800; // seconds

// WMO weather codes → description / nerd-font icon / waybar class. Kept as three
// lookups (not one table) because the original groups codes differently for each.
const has = (arr: number[], c: number) => arr.includes(c);

function wmoDesc(c: number): string {
  if (c === 0) return "Clear";
  if (has([1, 2, 3], c)) return "Partly cloudy";
  if (has([45, 48], c)) return "Fog";
  if (has([51, 53, 55], c)) return "Drizzle";
  if (has([56, 57], c)) return "Freezing drizzle";
  if (has([61, 63, 65], c)) return "Rain";
  if (has([66, 67], c)) return "Freezing rain";
  if (has([71, 73, 75, 77], c)) return "Snow";
  if (has([80, 81, 82], c)) return "Rain showers";
  if (has([85, 86], c)) return "Snow showers";
  if (c === 95) return "Thunderstorm";
  if (has([96, 99], c)) return "Thunderstorm w/ hail";
  return "Unknown";
}

function wmoIcon(c: number): string {
  if (c === 0) return "󰖙 ";
  if (has([1, 2, 3], c)) return "󰖐 ";
  if (has([45, 48], c)) return "󰖑 ";
  if (has([51, 53, 55, 56, 57], c)) return "󰖗 ";
  if (has([61, 63, 65, 66, 67, 80, 81, 82], c)) return "󰖖 ";
  if (has([71, 73, 75, 77, 85, 86], c)) return "󰖘 ";
  if (has([95, 96, 99], c)) return "󰖓 ";
  return "󰼮";
}

function wmoClass(c: number): string {
  if (c === 0) return "sunny";
  if (has([1, 2, 3], c)) return "cloudy";
  if (has([45, 48], c)) return "fog";
  if (has([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82], c)) return "rain";
  if (has([71, 73, 75, 77, 85, 86], c)) return "snow";
  if (has([95, 96, 99], c)) return "storm";
  return "unknown";
}

// Abbreviated local weekday for a "YYYY-MM-DD" date (matches `date -d … +%a`).
// Build the Date from local parts so no timezone shift moves it a day.
function dayName(iso: string): string {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(iso);
  if (!m) return iso;
  const d = new Date(Number(m[1]), Number(m[2]) - 1, Number(m[3]));
  return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][d.getDay()];
}

function cacheFresh(): boolean {
  if (!existsSync(CACHE)) return false;
  try {
    const age = Math.floor(Date.now() / 1000) - Math.floor(statSync(CACHE).mtimeMs / 1000);
    return age < CACHE_TTL;
  } catch {
    return false;
  }
}

async function refresh(): Promise<boolean> {
  try {
    const wRes = await fetch("https://wttr.in/?format=j1", {
      signal: AbortSignal.timeout(10_000),
    });
    if (!wRes.ok) return false;
    const wttr = (await wRes.json()) as any;

    const area = wttr?.nearest_area?.[0];
    const location = area?.areaName?.[0]?.value ?? "";
    const lat = area?.latitude;
    const lon = area?.longitude;
    if (lat == null || lon == null) return false;

    const mRes = await fetch(
      `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}` +
        `&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=auto&forecast_days=7`,
      { signal: AbortSignal.timeout(10_000) },
    );
    if (!mRes.ok) return false;
    const meteo = (await mRes.json()) as any;

    writeFileSync(
      CACHE,
      JSON.stringify({
        location,
        current: wttr.current_condition?.[0],
        daily: meteo.daily,
      }),
    );
    return true;
  } catch {
    return false;
  }
}

// --- Main ---
if (!cacheFresh()) await refresh(); // ignore failure — fall back to any stale cache

if (!existsSync(CACHE)) {
  console.log(
    JSON.stringify({ text: "?", tooltip: "Weather unavailable", class: "unknown" }),
  );
  process.exit(0);
}

const data = JSON.parse(readFileSync(CACHE, "utf8"));
const cur = data.current ?? {};
const location: string = data.location ?? "";
const tempC = cur.temp_C ?? "?";
const feelsC = cur.FeelsLikeC ?? "?";
const curDesc = cur.weatherDesc?.[0]?.value ?? "";
const curCode = Number(data.daily?.weathercode?.[0] ?? -1);

const daily = data.daily ?? {};
const times: string[] = daily.time ?? [];
const tMax = daily.temperature_2m_max ?? [];
const tMin = daily.temperature_2m_min ?? [];
const codes = daily.weathercode ?? [];

const forecast = times
  .map((t, i) => {
    const code = Number(codes[i]);
    const lo = Number(tMin[i]).toFixed(1);
    const hi = Number(tMax[i]).toFixed(1);
    return `${dayName(t)}: ${lo}/${hi}°C ${wmoIcon(code)} ${wmoDesc(code)}`;
  })
  .join("\n");

const tooltip = `${location} — ${curDesc}, feels like ${feelsC}°C\n\n${forecast}`;

console.log(
  JSON.stringify({ text: `${tempC}°`, tooltip, class: wmoClass(curCode) }),
);
