import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs

// Incoming notifications, stacked in the top right corner, or beside a panel
// that is open there. Click one to act on it, right-click to dismiss it.
PanelWindow {
    id: root

    visible: Notifications.popups.length > 0
    color: "transparent"
    anchors { top: true; right: true }
    margins {
        top: 8
        right: Panels.current?.anchors.right ? Panels.current.width + 16 : 8
    }
    exclusionMode: ExclusionMode.Normal
    implicitWidth: 380
    implicitHeight: Math.max(1, stack.implicitHeight)
    WlrLayershell.namespace: "notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    ColumnLayout {
        id: stack
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifications.popups

            Rectangle {
                id: card
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: content.implicitHeight + 28
                radius: 8
                color: Theme.bg
                border { width: 1; color: card.modelData.critical ? Theme.critical : Theme.border }

                ColumnLayout {
                    id: content
                    anchors { fill: parent; margins: 14; leftMargin: 18; rightMargin: 18 }
                    spacing: 4

                    Section {
                        visible: text !== ""
                        text: card.modelData.app.toUpperCase()
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    StyledText {
                        text: card.modelData.summary
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    StyledText {
                        visible: text !== ""
                        text: card.modelData.body
                        textFormat: Text.PlainText
                        color: Theme.dim
                        wrapMode: Text.Wrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: event => {
                        if (event.button === Qt.RightButton) Notifications.dismiss(card.modelData.id)
                        else Notifications.activate(card.modelData.id)
                    }
                }
            }
        }
    }
}
