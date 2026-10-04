import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Region picker for screenshots and recordings, macOS style: drag out an
// area, then move it or resize it by its handles before confirming.
//
//   drag outside        new selection (hold Space to move it while dragging)
//   drag inside         move
//   drag an edge/corner resize
//   Shift while dragging snap to a 10px grid
//   arrows              nudge by 1px, 10px with Shift
//   Enter, double-click confirm          Esc cancel
PanelWindow {
    id: root

    property string mode: "screenshot"      // or "record"

    // The selection, in window coordinates. It is kept between openings.
    property real sx: 0
    property real sy: 0
    property real sw: 0
    property real sh: 0
    readonly property bool selected: sw >= 2 && sh >= 2

    readonly property int grip: 10          // how close counts as on an edge

    function open(as: string): void {
        mode = as
        visible = true
    }

    // slurp-style, in global coordinates.
    function geometry(): string {
        return `${Math.round(screen.x + sx)},${Math.round(screen.y + sy)} ${Math.round(sw)}x${Math.round(sh)}`
    }

    function confirm(): void {
        if (!selected) return
        const region = geometry()
        visible = false
        if (mode === "record") {
            startRecording.region = region
            startRecording.start()
        } else {
            shot.file = Quickshell.env("HOME") + "/Pictures/Screenshots/Screenshot from " + Recorder.stamp() + ".png"
            shot.command = ["sh", "-c", `
                sleep 0.15
                mkdir -p "$(dirname "$2")"
                grim -g "$1" "$2" && wl-copy --type image/png < "$2"
            `, "sh", region, shot.file]
            shot.running = true
        }
    }

    function clamp(): void {
        sw = Math.min(sw, width)
        sh = Math.min(sh, height)
        sx = Math.max(0, Math.min(width - sw, sx))
        sy = Math.max(0, Math.min(height - sh, sy))
    }

    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "capture"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: if (visible) keys.forceActiveFocus()

    IpcHandler {
        target: "capture"
        function screenshot(): void { root.open("screenshot") }
        // Stops a running recording, otherwise picks a region for a new one.
        function record(): void {
            if (Recorder.recording) Recorder.stop()
            else root.open("record")
        }
    }

    // Runs after the overlay is gone, so it is not in the picture.
    Process {
        id: shot
        property string file
        onExited: code => {
            if (code === 0) Recorder.notifySaved("Screenshot copied", file)
        }
    }
    Timer {
        id: startRecording
        property string region
        interval: 150
        onTriggered: Recorder.start(region)
    }

    // Everything outside the selection is dimmed.
    component Dim: Rectangle { color: "#80000000" }
    Dim { visible: !root.selected; anchors.fill: parent; color: "#40000000" }
    Dim { visible: root.selected; x: 0; y: 0; width: root.width; height: root.sy }
    Dim { visible: root.selected; x: 0; y: root.sy + root.sh; width: root.width; height: root.height - root.sy - root.sh }
    Dim { visible: root.selected; x: 0; y: root.sy; width: root.sx; height: root.sh }
    Dim { visible: root.selected; x: root.sx + root.sw; y: root.sy; width: root.width - root.sx - root.sw; height: root.sh }

    Rectangle {
        id: frame
        visible: root.selected
        x: root.sx - 1
        y: root.sy - 1
        width: root.sw + 2
        height: root.sh + 2
        color: "transparent"
        border { width: 1; color: Theme.fg }

        // Handles on the corners and edge midpoints.
        Repeater {
            model: [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [1, 0.5], [0, 1], [0.5, 1], [1, 1]]
            Rectangle {
                required property var modelData
                width: 8
                height: 8
                radius: 4
                x: modelData[0] * frame.width - 4
                y: modelData[1] * frame.height - 4
                color: Theme.fg
            }
        }
    }

    MouseArea {
        id: mouse

        // What a drag does: "" nothing, "new", "move", or the edges it
        // resizes as a combination of l/r/t/b.
        property string action: ""
        property bool space: false
        property real ax        // anchor corner of a new selection
        property real ay
        property real px        // last pointer position, for moving
        property real py

        function hit(x: real, y: real): string {
            if (!root.selected) return "new"
            const g = root.grip
            const inX = x >= root.sx - g && x <= root.sx + root.sw + g
            const inY = y >= root.sy - g && y <= root.sy + root.sh + g
            if (!inX || !inY) return "new"
            const edges = (Math.abs(y - root.sy) <= g ? "t" : Math.abs(y - root.sy - root.sh) <= g ? "b" : "")
                + (Math.abs(x - root.sx) <= g ? "l" : Math.abs(x - root.sx - root.sw) <= g ? "r" : "")
            return edges || "move"
        }

        function cursor(action: string): int {
            switch (action) {
            case "move": return Qt.SizeAllCursor
            case "t": case "b": return Qt.SizeVerCursor
            case "l": case "r": return Qt.SizeHorCursor
            case "tl": case "br": return Qt.SizeFDiagCursor
            case "tr": case "bl": return Qt.SizeBDiagCursor
            }
            return Qt.CrossCursor
        }

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: cursor(pressed ? action : hit(mouseX, mouseY))

        onPressed: event => {
            action = hit(event.x, event.y)
            ax = event.x
            ay = event.y
            px = event.x
            py = event.y
            if (action === "new") {
                root.sx = event.x
                root.sy = event.y
                root.sw = 0
                root.sh = 0
            }
        }

        onPositionChanged: event => {
            if (!pressed) return
            // Shift snaps to a 10px grid.
            const snap = v => event.modifiers & Qt.ShiftModifier ? Math.round(v / 10) * 10 : v
            const x = snap(Math.max(0, Math.min(width, event.x)))
            const y = snap(Math.max(0, Math.min(height, event.y)))
            const dx = x - px
            const dy = y - py
            px = x
            py = y

            if (action === "move" || space) {
                root.sx = snap(root.sx + dx)
                root.sy = snap(root.sy + dy)
                ax += dx
                ay += dy
                root.clamp()
            } else if (action === "new") {
                root.sx = Math.min(ax, x)
                root.sy = Math.min(ay, y)
                root.sw = Math.abs(x - ax)
                root.sh = Math.abs(y - ay)
            } else {
                const right = root.sx + root.sw
                const bottom = root.sy + root.sh
                if (action.includes("l")) { root.sx = Math.min(x, right - 2); root.sw = right - root.sx }
                if (action.includes("r")) root.sw = Math.max(2, x - root.sx)
                if (action.includes("t")) { root.sy = Math.min(y, bottom - 2); root.sh = bottom - root.sy }
                if (action.includes("b")) root.sh = Math.max(2, y - root.sy)
            }
        }

        onReleased: action = ""
        onDoubleClicked: event => {
            if (hit(event.x, event.y) === "move") root.confirm()
        }
    }

    Item {
        id: keys
        focus: true

        Keys.onPressed: event => {
            const step = event.modifiers & Qt.ShiftModifier ? 10 : 1
            switch (event.key) {
            case Qt.Key_Escape: root.visible = false; break
            case Qt.Key_Return: case Qt.Key_Enter: root.confirm(); break
            case Qt.Key_Space: mouse.space = true; break
            case Qt.Key_Left: root.sx -= step; root.clamp(); break
            case Qt.Key_Right: root.sx += step; root.clamp(); break
            case Qt.Key_Up: root.sy -= step; root.clamp(); break
            case Qt.Key_Down: root.sy += step; root.clamp(); break
            default: return
            }
            event.accepted = true
        }
        Keys.onReleased: event => {
            if (event.key === Qt.Key_Space) mouse.space = false
        }
    }

    // Toolbar: below the selection, or above it when there is no room.
    Rectangle {
        id: toolbar
        visible: root.selected
        x: Math.max(8, Math.min(root.width - width - 8, root.sx + (root.sw - width) / 2))
        y: root.sy + root.sh + height + 16 <= root.height ? root.sy + root.sh + 8 : Math.max(8, root.sy - height - 8)
        // The buttons sit as far from the left edge as from the top and
        // bottom; the size text gets a little more room on the right.
        width: tools.implicitWidth + 8 + 14
        height: tools.implicitHeight + 16
        radius: 8
        color: Theme.bg
        border { width: 1; color: Theme.border }

        MouseArea { anchors.fill: parent }

        RowLayout {
            id: tools
            anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
            spacing: 14

            // Clicking one captures that way; the lit one is what Enter does.
            component ModeButton: Rectangle {
                required property string key
                property alias icon: icon.text
                readonly property bool active: root.mode === key

                implicitWidth: 30
                implicitHeight: 28
                radius: 4
                color: active ? Theme.surface : "transparent"

                Icon {
                    id: icon
                    anchors.centerIn: parent
                    font.pixelSize: 18
                    color: parent.active || modeMouse.containsMouse ? Theme.fg : Theme.dim
                }
                MouseArea {
                    id: modeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.mode = parent.key
                        root.confirm()
                    }
                }
            }

            RowLayout {
                spacing: 4
                ModeButton { key: "screenshot"; icon: "󰄀" }
                ModeButton { key: "record"; icon: "󰕧" }
            }
            StyledText {
                text: Math.round(root.sw) + " × " + Math.round(root.sh)
                color: Theme.dim
                font.pixelSize: Theme.small
            }
        }
    }
}
