#!/usr/bin/env bun
import { readFileSync, writeFileSync, existsSync, statSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const CACHE = join(homedir(), ".cache", "quickshell-weather.json");
const CACHE_TTL = 1800; // seconds

// WMO weather codes → description / nerd-font icon / class. Kept as three
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
    if (has([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82], c))
        return "rain";
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
        const age =
            Math.floor(Date.now() / 1000) -
            Math.floor(statSync(CACHE).mtimeMs / 1000);
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
                `&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum` +
                `&hourly=weathercode,temperature_2m,precipitation_probability,precipitation` +
                `&current=temperature_2m,apparent_temperature,weathercode,wind_speed_10m,relative_humidity_2m` +
                `&timezone=auto&forecast_days=7`,
            { signal: AbortSignal.timeout(10_000) },
        );
        if (!mRes.ok) return false;
        const meteo = (await mRes.json()) as any;

        writeFileSync(
            CACHE,
            JSON.stringify({
                location,
                current: meteo.current,
                daily: meteo.daily,
                hourly: meteo.hourly,
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
        JSON.stringify({
            text: "?",
            tooltip: "Weather unavailable",
            class: "unknown",
        }),
    );
    process.exit(0);
}

const data = JSON.parse(readFileSync(CACHE, "utf8"));
const cur = data.current ?? {};
const location: string = data.location ?? "";
const curCode = Number(cur.weathercode);
const tempC = Number(cur.temperature_2m).toFixed(0);
const feelsC = Number(cur.apparent_temperature).toFixed(0);
const curDesc = wmoDesc(curCode);

const daily = data.daily ?? {};
const times: string[] = daily.time ?? [];
const tMax = daily.temperature_2m_max ?? [];
const tMin = daily.temperature_2m_min ?? [];
const codes = daily.weathercode ?? [];
const dPop = daily.precipitation_probability_max ?? [];
const dMm = daily.precipitation_sum ?? [];

const days = times.map((t, i) => {
    const code = Number(codes[i]);
    return {
        day: dayName(t),
        lo: Number(tMin[i]).toFixed(0),
        hi: Number(tMax[i]).toFixed(0),
        icon: wmoIcon(code).trim(),
        desc: wmoDesc(code),
        pop: Number(dPop[i] ?? 0),
        mm: Number(dMm[i] ?? 0),
    };
});

const pad = (n: number) => String(n).padStart(2, "0");
const now = new Date();
const stamp = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}T${pad(now.getHours())}:00`;

const hTimes: string[] = data.hourly?.time ?? [];
const hTemps = data.hourly?.temperature_2m ?? [];
const hCodes = data.hourly?.weathercode ?? [];
const hPop = data.hourly?.precipitation_probability ?? [];
const hMm = data.hourly?.precipitation ?? [];
const start = Math.max(0, hTimes.indexOf(stamp));

const hours = hTimes.slice(start, start + 7).map((t, i) => ({
    time: t.slice(11, 16),
    temp: Number(hTemps[start + i]).toFixed(0),
    icon: wmoIcon(Number(hCodes[start + i])).trim(),
}));

// Precipitation for the next 24 hours: chance (%) and amount (mm) per hour.
const rain = hTimes.slice(start, start + 24).map((t, i) => ({
    time: t.slice(11, 16),
    pop: Number(hPop[start + i] ?? 0),
    mm: Number(hMm[start + i] ?? 0),
}));

// The whole forecast in 3-hour buckets from midnight today, eight per day:
// the highest chance in the bucket and the amount it adds up to.
const week = [];
for (let i = 0; i + 2 < hTimes.length; i += 3) {
    week.push({
        day: dayName(hTimes[i]),
        time: hTimes[i].slice(11, 16),
        pop: Math.max(...[0, 1, 2].map((k) => Number(hPop[i + k] ?? 0))),
        mm: [0, 1, 2].reduce((sum, k) => sum + Number(hMm[i + k] ?? 0), 0),
    });
}

// Heading out now: the worst of the next three hours, or null when it is dry.
const soon = rain.slice(0, 3);
const rainSoon = soon.some((h) => h.pop >= 50 || h.mm >= 0.2)
    ? {
          pop: Math.max(...soon.map((h) => h.pop)),
          mm: soon.reduce((sum, h) => sum + h.mm, 0),
      }
    : null;

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
    JSON.stringify({
        text: `${tempC}°`,
        tooltip,
        class: wmoClass(curCode),
        location,
        temp: tempC,
        feels: feelsC,
        desc: curDesc,
        icon: wmoIcon(curCode).trim(),
        wind: Number(cur.wind_speed_10m).toFixed(0),
        humidity: cur.relative_humidity_2m,
        days,
        hours,
        week,
        rainSoon,
    }),
);
