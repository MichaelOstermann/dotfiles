pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Screen recording with wf-recorder, into ~/Videos/Recordings.
Singleton {
    id: root

    readonly property bool recording: proc.running
    property int seconds: 0
    readonly property string elapsed: Math.floor(seconds / 60) + ":" + String(seconds % 60).padStart(2, "0")

    function stamp(): string {
        return Qt.formatDateTime(new Date(), "yyyy-MM-dd HH-mm-ss")
    }

    // `geometry` is a slurp-style region: "x,y WxH".
    function start(geometry: string): void {
        if (proc.running) return
        seconds = 0
        proc.file = Quickshell.env("HOME") + "/Videos/Recordings/Recording from " + stamp() + ".mp4"
        proc.command = ["sh", "-c", `
            mkdir -p "$(dirname "$2")"
            exec wf-recorder -c libx264 -r 60 -p pix_fmt=yuv420p -p color_range=2 -g "$1" -f "$2"
        `, "sh", geometry, proc.file]
        proc.running = true
    }

    // A notification that shows the file in Files when clicked.
    function notifySaved(title: string, file: string): void {
        Quickshell.execDetached(["sh", "-c", `
            [ "$(notify-send -A default=Show "$1" "Click to show in Files")" = default ] && nautilus --select "$2"
        `, "sh", title, file])
    }

    // SIGINT lets wf-recorder finish the file.
    function stop(): void {
        if (proc.running) proc.signal(2)
    }

    Process {
        id: proc
        property string file
        onExited: root.notifySaved("Recording saved", file)
    }

    Timer {
        interval: 1000
        running: proc.running
        repeat: true
        onTriggered: root.seconds++
    }
}
