import QtQuick
import QtQuick.Layouts
import qs

// The history, and the current colour in every format. Clicking a format
// copies it and makes it the default.
Panel {
    id: root

    panelName: "colors"
    contentWidth: 300
    anchors { top: true; left: true }
    spacing: 20

    // ---- History ------------------------------------------------------------
    RowLayout {
        visible: Picker.history.length > 0
        spacing: 8

        Repeater {
            model: Picker.history
            Rectangle {
                required property string modelData
                Layout.fillWidth: true
                implicitHeight: 28
                radius: 4
                color: modelData
                border { width: Picker.current === modelData ? 2 : 0; color: Theme.fg }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Picker.current = parent.modelData
                }
            }
        }
        // Keeps a short row from stretching its swatches.
        Repeater {
            model: Picker.historySize - Picker.history.length
            Item { Layout.fillWidth: true }
        }
    }

    // ---- Formats ------------------------------------------------------------
    ColumnLayout {
        spacing: 2

        Repeater {
            model: Picker.formats

            Rectangle {
                id: row
                required property string modelData
                readonly property bool active: Picker.format === modelData

                Layout.fillWidth: true
                Layout.leftMargin: -10
                Layout.rightMargin: -10
                implicitHeight: 32
                radius: 4
                color: rowMouse.containsMouse ? Theme.surface : "transparent"

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Picker.copy(Picker.current, row.modelData)
                }
                RowLayout {
                    anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                    spacing: 12
                    Section {
                        text: row.modelData.toUpperCase()
                        color: row.active ? Theme.fg : Theme.dim
                        Layout.preferredWidth: 52
                    }
                    StyledText { text: Picker.formatted(Picker.current, row.modelData); Layout.fillWidth: true }
                    StyledText {
                        visible: rowMouse.containsMouse
                        text: "copy"
                        color: Theme.dim
                        font.pixelSize: Theme.small
                    }
                }
            }
        }
    }
}
