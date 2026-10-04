pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var current: ({
        location: "",
        temp: "?",
        icon: "",
        hours: [],
        days: [],
        week: [],
        rainSoon: null,
    })

    Process {
        id: proc
        command: ["bun", Qt.resolvedUrl("probe.ts").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.current = Object.assign({}, root.current, JSON.parse(text)) } catch (e) { console.warn("weather:", e) }
            }
        }
    }

    Timer {
        interval: 300000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
