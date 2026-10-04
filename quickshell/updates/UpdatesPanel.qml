import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

Panel {
    id: root

    readonly property var u: Updates
    // Packages you installed yourself come first; the dependencies they
    // dragged in (haskell-*, lib*) follow, dimmed.
    readonly property var pending: u.pending.slice()
        .sort((a, b) => b.explicit - a.explicit || a.name.localeCompare(b.name))

    readonly property int rowHeight: 20
    readonly property int rowGap: 10
    readonly property int rows: 12

    panelName: "updates"
    anchors { top: true; right: true }
    spacing: 20
    // Opening it re-checks, unless that just happened.
    onVisibleChanged: if (visible && Date.now() - u.checkedAt > 300000) u.refresh()

    RowLayout {
        StyledText {
            text: root.pending.length === 0 ? "Up to date"
                : root.pending.length + (root.pending.length === 1 ? " update" : " updates")
            font.pixelSize: 22
            Layout.fillWidth: true
        }
        // Runs in a terminal that stays open, so the output can be read.
        Rectangle {
            visible: root.pending.length > 0
            implicitWidth: label.implicitWidth + 24
            implicitHeight: 28
            radius: 4
            color: mouse.containsMouse ? Theme.border : Theme.surface

            StyledText { id: label; anchors.centerIn: parent; text: u.upgrading ? "Upgrading…" : "Upgrade" }
            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    u.upgrade()
                    root.visible = false
                }
            }
        }
    }

    ListView {
        id: list
        visible: count > 0
        Layout.fillWidth: true
        implicitHeight: Math.min(count, root.rows) * (root.rowHeight + root.rowGap) - root.rowGap
        clip: true
        spacing: root.rowGap
        boundsBehavior: Flickable.StopAtBounds
        model: root.pending

        delegate: RowLayout {
            required property var modelData
            width: list.width - (scrollbar.visible ? 12 : 0)
            height: root.rowHeight
            spacing: 12

            StyledText {
                text: modelData.name
                color: modelData.explicit ? Theme.fg : Theme.dim
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            StyledText {
                text: (modelData.aur ? "AUR · " : "") + modelData.old + " → " + modelData.new
                color: Theme.dim
                font.pixelSize: Theme.small
                elide: Text.ElideLeft
                horizontalAlignment: Text.AlignRight
                Layout.maximumWidth: 220
            }
        }

        Rectangle {
            id: scrollbar
            visible: list.visibleArea.heightRatio < 1
            anchors.right: parent.right
            y: list.visibleArea.yPosition * list.height
            width: 3
            height: list.visibleArea.heightRatio * list.height
            radius: 1.5
            color: Theme.border
        }
    }

    Rectangle {
        visible: list.visible && u.news.length > 0
        implicitHeight: 1
        color: Theme.border
        Layout.fillWidth: true
    }

    // That is where manual interventions are announced. This week's are lit.
    ColumnLayout {
        visible: u.news.length > 0
        spacing: 10

        Section { text: "ARCH NEWS" }
        Repeater {
            model: u.news
            ColumnLayout {
                id: item
                required property var modelData
                readonly property bool recent: Date.now() - new Date(modelData.date).getTime() < 7 * 86400000
                spacing: 2

                StyledText {
                    text: item.modelData.title
                    textFormat: Text.PlainText
                    color: item.recent || newsMouse.containsMouse ? Theme.fg : Theme.dim
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true

                    MouseArea {
                        id: newsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["xdg-open", item.modelData.link])
                    }
                }
                Section {
                    text: new Date(item.modelData.date).toLocaleDateString(Qt.locale("en_US"), "dd.MM.yyyy")
                    color: Theme.faint
                }
            }
        }
    }
}
