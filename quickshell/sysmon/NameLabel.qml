import QtQuick
import QtQuick.Layouts
import qs

// A name with a small dim note after it, taking the row's spare width.
RowLayout {
    property alias text: label.text
    property alias note: note.text
    property alias color: label.color

    spacing: 8

    StyledText {
        id: label
        textFormat: Text.PlainText
        elide: Text.ElideRight
        Layout.maximumWidth: 190
    }
    StyledText {
        id: note
        visible: text !== ""
        textFormat: Text.PlainText
        elide: Text.ElideRight
        color: Theme.dim
        font.pixelSize: Theme.small
        Layout.fillWidth: true
    }
    Item { visible: !note.visible; Layout.fillWidth: true }
}
