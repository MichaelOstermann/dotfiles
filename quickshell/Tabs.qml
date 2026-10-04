import QtQuick
import QtQuick.Layouts

// Text tabs with an underline on the active one. `compact` is the small
// uppercase variant for switches inside a section.
RowLayout {
    id: root

    property var tabs: []           // [{ key, label }, ...]
    property string current
    property bool compact: false

    spacing: compact ? 12 : 18

    Repeater {
        model: root.tabs

        Item {
            id: tab

            required property var modelData
            readonly property bool active: root.current === modelData.key

            implicitWidth: label.implicitWidth
            implicitHeight: label.implicitHeight + (root.compact ? 6 : 10)

            StyledText {
                id: label
                text: tab.modelData.label
                color: tab.active ? Theme.fg : mouse.containsMouse ? Theme.fg : Theme.dim
                font.pixelSize: root.compact ? Theme.small : 15
                font.letterSpacing: root.compact ? 1 : 0
            }

            Rectangle {
                visible: tab.active
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 2
                radius: 1
                color: Theme.fg
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.current = tab.modelData.key
            }
        }
    }
}
