import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Popup card toggled with `qs ipc call <panelName> toggle`.
PanelWindow {
    id: root

    required property string panelName
    property int contentWidth: 420
    property alias spacing: column.spacing
    default property alias content: column.data

    visible: false
    color: "transparent"
    implicitWidth: card.width
    implicitHeight: card.height
    exclusionMode: ExclusionMode.Normal
    margins { top: 8; left: 8; right: 8 }

    WlrLayershell.namespace: panelName
    WlrLayershell.layer: WlrLayer.Overlay

    function toggle(): void { visible = !visible }

    onVisibleChanged: visible ? Panels.opened(root) : Panels.closed(root)

    IpcHandler {
        target: root.panelName
        function toggle(): void { root.toggle() }
    }

    Rectangle {
        id: card
        width: root.contentWidth + 46
        height: column.implicitHeight + 46
        radius: 8
        color: Theme.bg
        border { width: 1; color: Theme.border }

        ColumnLayout {
            id: column
            anchors { fill: parent; margins: 23 }
        }
    }
}
