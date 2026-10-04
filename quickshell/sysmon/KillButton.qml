import QtQuick
import qs

// Sends TERM to `pids`. If `key` is still listed after the next refresh the
// cross turns red, and a second click sends KILL.
Rectangle {
    id: root

    property string key
    property var pids: []
    readonly property bool survived: key !== "" && Sysmon.killTarget === key

    implicitWidth: 22
    implicitHeight: 22
    radius: 4
    color: mouse.containsMouse ? Theme.surface : "transparent"

    Icon {
        anchors.centerIn: parent
        text: "󰅖"
        font.pixelSize: 16
        color: root.survived ? Theme.critical : mouse.containsMouse ? Theme.fg : Theme.dim
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Sysmon.kill(root.key, root.pids)
    }
}
