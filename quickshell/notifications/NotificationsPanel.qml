import QtQuick
import QtQuick.Layouts
import qs

// The notifications that are still waiting, grouped by app. Click one to act
// on it, right-click to dismiss it; the cross clears an app's, and so does
// going to the app.
Panel {
    id: root

    // [{ app, items: [notification, ...] }, ...], the most recent app first.
    readonly property var groups: {
        const out = []
        for (const n of Notifications.history) {
            let group = out.find(g => g.app === n.appName)
            if (!group) out.push(group = { app: n.appName, items: [] })
            group.items.push(n)
        }
        return out
    }

    function ago(id: int): string {
        const s = Math.max(0, Math.round((clock.now - (Notifications.arrived[id] ?? clock.now)) / 1000))
        return s < 60 ? "now" : s < 3600 ? Math.floor(s / 60) + "m" : s < 86400 ? Math.floor(s / 3600) + "h" : Math.floor(s / 86400) + "d"
    }

    panelName: "notifications"
    // The bell goes away with the last notification, so close along with it.
    onGroupsChanged: if (groups.length === 0) visible = false
    anchors { top: true; right: true }
    spacing: 16

    Timer {
        id: clock
        property real now: Date.now()
        interval: 30000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: now = Date.now()
    }

    component Cross: Icon {
        signal clicked()

        text: "󰅖"
        font.pixelSize: 16
        color: crossMouse.containsMouse ? Theme.fg : Theme.dim

        MouseArea {
            id: crossMouse
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    RowLayout {
        Section { text: root.groups.length ? "NOTIFICATIONS" : "NO NOTIFICATIONS"; Layout.fillWidth: true }
        Section {
            visible: root.groups.length > 0
            text: "CLEAR ALL"
            color: clearMouse.containsMouse ? Theme.fg : Theme.dim

            MouseArea {
                id: clearMouse
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Notifications.clearAll()
            }
        }
    }

    Flickable {
        visible: root.groups.length > 0
        Layout.fillWidth: true
        implicitHeight: Math.min(contentHeight, 520)
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: list
            width: parent.width
            spacing: 18

            Repeater {
                model: root.groups

                ColumnLayout {
                    id: group
                    required property var modelData
                    spacing: 8

                    RowLayout {
                        spacing: 8
                        StyledText { text: group.modelData.app; textFormat: Text.PlainText; elide: Text.ElideRight }
                        StyledText {
                            visible: group.modelData.items.length > 1
                            text: "×" + group.modelData.items.length
                            color: Theme.dim
                            font.pixelSize: Theme.small
                        }
                        Item { Layout.fillWidth: true }
                        Cross { onClicked: Notifications.clearApp(group.modelData.app); Layout.rightMargin: 12 }
                    }

                    Repeater {
                        model: group.modelData.items

                        // The same card as the popup, on the panel's surface.
                        Rectangle {
                            id: card
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: content.implicitHeight + 24
                            radius: 6
                            color: cardMouse.containsMouse ? "#2f3346" : Theme.surface

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: event => {
                                    if (event.button === Qt.RightButton) Notifications.dismiss(card.modelData.id)
                                    else Notifications.activate(card.modelData.id)
                                }
                            }

                            ColumnLayout {
                                id: content
                                anchors { fill: parent; margins: 12; leftMargin: 14; rightMargin: 14 }
                                spacing: 2

                                RowLayout {
                                    spacing: 10
                                    StyledText {
                                        text: card.modelData.summary
                                        textFormat: Text.PlainText
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Section { text: root.ago(card.modelData.id).toUpperCase(); color: Theme.faint }
                                }
                                StyledText {
                                    visible: text !== ""
                                    text: card.modelData.body
                                    textFormat: Text.PlainText
                                    color: Theme.dim
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 3
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
