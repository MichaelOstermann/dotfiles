pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var current: ({
        subType: "",
        fiveUtil: 0,
        fiveResetAt: "",
        sevenUtil: 0,
        sevenResetAt: "",
        scoped: [],
        days: [],
    })

    // Set by the panel while it is open: keeps the reset countdowns ticking.
    property bool watching: false
    property real now: Date.now()

    onWatchingChanged: if (watching) {
        now = Date.now()
        proc.fresh = true
        proc.running = true
    }

    function fmtReset(iso: string): string {
        const t = new Date(iso).getTime()
        if (!iso || isNaN(t)) return "?"
        const diff = Math.floor((t - now) / 1000)
        const pad = n => String(Math.floor(n)).padStart(2, "0")
        if (diff < 0) return "now"
        if (diff >= 86400) return `${Math.floor(diff / 86400)}d ${pad((diff % 86400) / 3600)}h`
        return `${Math.floor(diff / 3600)}h ${pad((diff % 3600) / 60)}m`
    }

    function fmtTokens(n: real): string {
        if (n >= 1e9) return (n / 1e9).toFixed(1) + "B"
        if (n >= 1e6) return (n / 1e6).toFixed(1) + "M"
        if (n >= 1e3) return (n / 1e3).toFixed(1) + "k"
        return String(n)
    }

    Process {
        id: proc
        property bool fresh: false
        command: ["bun", Qt.resolvedUrl("probe.ts").toString().replace("file://", "")].concat(fresh ? ["--fresh"] : [])
        onExited: fresh = false
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.current = JSON.parse(text) } catch (e) { console.warn("usage:", e) }
                root.now = Date.now()
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }

    Timer {
        interval: 30000
        running: root.watching
        repeat: true
        onTriggered: root.now = Date.now()
    }
}
