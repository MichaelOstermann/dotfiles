pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

// Screen time: every few seconds the focused app gets that time added to the
// current hour's tally, unless nobody has touched the machine for a while.
Singleton {
    id: root

    // { "2026-10-04": { "13": { "firefox": seconds, ... }, ... }, ... }
    // — day, then hour of the day, then what had the focus. That is an app
    // id, or "nvim<TAB>project" for nvim in a terminal, so that the time in
    // it divides by what was being worked on.
    property var days: ({})
    readonly property int version: 2    // of the stored file; others are dropped
    readonly property var terminals: ["com.mitchellh.ghostty"]
    readonly property int tick: 5           // seconds
    readonly property int keepDays: 120

    function key(date: date): string {
        return Qt.formatDate(date, "yyyy-MM-dd")
    }

    function fmt(seconds: real): string {
        const m = Math.round(seconds / 60)
        return m >= 60 ? Math.floor(m / 60) + "h " + String(m % 60).padStart(2, "0") + "m" : m + "m"
    }

    function appName(appId: string): string {
        return DesktopEntries.heuristicLookup(appId)?.name ?? appId
    }

    // Splits a tally key into { app, project }.
    function parse(what: string): var {
        const [app, project] = what.split("\t")
        return { app: appName(app), project: project ?? "" }
    }

    // The project of an nvim window. Its title is "nvim(dotfiles/quickshell)",
    // the directory written from ~/Development; anywhere else is no project.
    function project(title: string): string {
        const dir = title.match(/^nvim\(([^()]*)\)$/)?.[1] ?? ""
        return /^[~\/]/.test(dir) ? "" : dir.split("/")[0]
    }

    // Away for two minutes: stop counting. Video players inhibit idling, so
    // watching something still counts.
    IdleMonitor {
        id: idle
        timeout: 120
        respectInhibitors: true
    }

    Timer {
        interval: root.tick * 1000
        running: true
        repeat: true
        onTriggered: {
            const app = Niri.focused?.app_id
            if (!app || idle.isIdle) return
            const now = new Date()
            const day = root.days[root.key(now)] ?? (root.days[root.key(now)] = {})
            const hour = day[now.getHours()] ?? (day[now.getHours()] = {})
            const project = root.terminals.includes(app) ? root.project(Niri.focused.title ?? "") : ""
            const what = project ? "nvim\t" + project : app
            hour[what] = (hour[what] ?? 0) + root.tick
            root.daysChanged()
        }
    }

    // Written once a minute rather than on every tick.
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            const cutoff = root.key(new Date(Date.now() - root.keepDays * 86400000))
            for (const day in root.days)
                if (day < cutoff) delete root.days[day]
            store.setText(JSON.stringify({ version: root.version, days: root.days }))
        }
    }

    FileView {
        id: store
        path: Quickshell.statePath("screentime.json")
        printErrors: false
        onLoaded: {
            try {
                const d = JSON.parse(text())
                if (d.version === root.version) root.days = d.days
            } catch (e) {}
        }
    }
}
