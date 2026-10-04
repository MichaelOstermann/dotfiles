import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs

// Freezes the screen and picks a pixel under a magnifying glass.
//
//   click   copy the colour in the current format
//   Tab     switch format (hex, rgba, oklch)
//   Esc     cancel
PanelWindow {
    id: root

    readonly property int zoom: 10
    readonly property int glass: 170        // diameter
    property string shot: ""                // the frozen screenshot
    property int serial: 0
    property string hex: "#000000"
    // The pixel under the pointer.
    property real px: mouse.mouseX
    property real py: mouse.mouseY
    onPxChanged: sample()
    onPyChanged: sample()

    // Take the screenshot first; the overlay shows once it is loaded.
    function pick(): void {
        if (visible || grab.running) return
        serial++
        grab.file = Quickshell.env("XDG_RUNTIME_DIR") + "/qs-picker-" + serial + ".png"
        grab.command = ["grim", "-o", screen.name, grab.file]
        grab.running = true
    }

    function sample(): void {
        if (!visible) return
        const x = Math.max(0, Math.min(frozen.width - 1, Math.floor(px)))
        const y = Math.max(0, Math.min(frozen.height - 1, Math.floor(py)))
        const d = frozen.getContext("2d").getImageData(x, y, 1, 1).data
        hex = Picker.toHex(d[0], d[1], d[2])
    }

    function close(): void {
        visible = false
        Quickshell.execDetached(["rm", "-f", grab.file])
    }

    visible: false
    color: "black"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "picker"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: if (visible) keys.forceActiveFocus()

    IpcHandler {
        target: "picker"
        function pick(): void { root.pick() }
    }

    Process {
        id: grab
        property string file
        onExited: code => {
            if (code !== 0) return
            root.shot = "file://" + file
            frozen.loadImage(root.shot)
        }
    }

    // The frozen screen. A Canvas rather than an Image, so pixels can be read.
    Canvas {
        id: frozen
        anchors.fill: parent
        onImageLoaded: {
            requestPaint()
            root.visible = true
        }
        onPaint: {
            if (!isImageLoaded(root.shot)) return
            const ctx = getContext("2d")
            ctx.drawImage(root.shot, 0, 0, width, height)
            root.sample()
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        // The glass is the cursor.
        cursorShape: Qt.BlankCursor
        onClicked: {
            Picker.copy(root.hex, Picker.format)
            root.close()
        }
    }

    Item {
        id: keys
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) root.close()
            else if (event.key === Qt.Key_Tab)
                Picker.format = Picker.formats[(Picker.formats.indexOf(Picker.format) + 1) % Picker.formats.length]
            else return
            event.accepted = true
        }
    }

    // The magnifying glass, centred on the pointer.
    Item {
        id: glass

        x: Math.round(root.px - width / 2)
        y: Math.round(root.py - height / 2)
        width: root.glass
        height: root.glass

        // The screenshot, scaled up and positioned so the pixel under the
        // pointer lands in the middle; masked to a circle below.
        Item {
            id: magnified
            anchors.fill: parent
            visible: false
            layer.enabled: true
            clip: true

            Image {
                source: root.shot
                smooth: false
                cache: false
                width: root.width * root.zoom
                height: root.height * root.zoom
                x: parent.width / 2 - (Math.floor(root.px) + 0.5) * root.zoom
                y: parent.height / 2 - (Math.floor(root.py) + 0.5) * root.zoom
            }
        }
        Item {
            id: circle
            anchors.fill: parent
            visible: false
            layer.enabled: true
            Rectangle { anchors.fill: parent; radius: width / 2 }
        }
        MultiEffect {
            anchors.fill: parent
            source: magnified
            maskEnabled: true
            maskSource: circle
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border { width: 2; color: Theme.border }
        }
        // The pixel being picked.
        Rectangle {
            anchors.centerIn: parent
            width: root.zoom + 2
            height: root.zoom + 2
            color: "transparent"
            border { width: 1; color: "white" }
        }

        Rectangle {
            // Below the glass, or above it near the bottom of the screen.
            anchors.horizontalCenter: parent.horizontalCenter
            y: glass.y + glass.height + 8 + height <= root.height ? glass.height + 8 : -height - 8
            width: value.implicitWidth + 44
            height: value.implicitHeight + 12
            radius: 6
            color: Theme.bg
            border { width: 1; color: Theme.border }

            Rectangle {
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                width: 14
                height: 14
                radius: 3
                color: root.hex
            }
            StyledText {
                id: value
                anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                text: Picker.formatted(root.hex, Picker.format)
            }
        }
    }
}
