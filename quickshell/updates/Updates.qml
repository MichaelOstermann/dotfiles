pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Pending package updates and Arch news.
Singleton {
    id: root

    property var pending: []        // [{ name, old, new, aur, explicit }, ...]
    property var news: []           // [{ title, link, date }, ...]
    property real checkedAt: 0
    readonly property bool upgrading: terminal.running

    function refresh(): void {
        probe.running = true
    }

    // In a terminal that stays open afterwards, so the output can be read.
    function upgrade(): void {
        terminal.running = true
    }

    Process {
        id: probe
        command: ["bun", Qt.resolvedUrl("probe.ts").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                let d
                try { d = JSON.parse(text) } catch (e) { return }
                root.pending = d.pending
                root.news = d.news
                root.checkedAt = Date.now()
            }
        }
    }

    Process {
        id: terminal
        command: ["ghostty", "-e", "sh", "-c", `
            paru -Syu
            printf '\\n── finished with exit code %s · press Enter to close ' "$?"
            read -r _
        `]
        onExited: root.refresh()
    }

    Timer {
        interval: 1800000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
