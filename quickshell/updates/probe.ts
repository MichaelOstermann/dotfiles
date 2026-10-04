#!/usr/bin/env bun
// Probe for the updates panel. Prints one JSON line:
//   pending  what `checkupdates` (repos) and `paru -Qua` (AUR) would upgrade;
//            `explicit` marks packages you installed yourself, as opposed to
//            ones pulled in as dependencies
//   news     the latest Arch news headlines (that is where manual
//            interventions are announced)

async function run(cmd: string[]): Promise<string> {
    try {
        const p = Bun.spawn(cmd, { stdout: "pipe", stderr: "ignore" });
        const out = await new Response(p.stdout).text();
        await p.exited;
        return out;
    } catch {
        return "";
    }
}

// "name old -> new" lines.
const parse = (out: string, aur: boolean) =>
    out
        .split("\n")
        .map((l) => /^(\S+)\s+(\S+)\s+->\s+(\S+)/.exec(l))
        .filter((m) => m !== null)
        .map((m) => ({
            name: m[1],
            old: m[2],
            new: m[3],
            aur,
            explicit: explicit.has(m[1]),
        }));

async function news() {
    try {
        const res = await fetch("https://archlinux.org/feeds/news/", {
            signal: AbortSignal.timeout(8_000),
        });
        if (!res.ok) return [];
        const tag = (item: string, name: string) =>
            new RegExp(`<${name}>([\\s\\S]*?)</${name}>`).exec(item)?.[1] ?? "";
        return [...(await res.text()).matchAll(/<item>([\s\S]*?)<\/item>/g)]
            .slice(0, 5)
            .map(([, item]) => ({
                title: tag(item, "title")
                    .replace(/&amp;/g, "&")
                    .replace(/&lt;/g, "<")
                    .replace(/&gt;/g, ">")
                    .replace(/&quot;/g, '"')
                    .replace(/&#39;/g, "'"),
                link: tag(item, "link"),
                date: new Date(tag(item, "pubDate")).toISOString(),
            }));
    } catch {
        return [];
    }
}

const [repo, aur, installed, headlines] = await Promise.all([
    run(["checkupdates"]),
    run(["paru", "-Qua"]),
    run(["pacman", "-Qqe"]),
    news(),
]);
const explicit = new Set(installed.split("\n"));

console.log(
    JSON.stringify({
        pending: [...parse(repo, false), ...parse(aur, true)],
        news: headlines,
    }),
);
