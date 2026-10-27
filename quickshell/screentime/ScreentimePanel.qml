import QtQuick
import QtQuick.Layouts
import qs

// Where the time went: the apps of today, the last week or the last month.
Panel {
    id: root

    readonly property var st: Screentime
    property string range: "today"
    readonly property int shown: 12

    // Everything over the period, most used first: [{ what, app, project, seconds }, ...],
    // where `what` is an app or one project in nvim (see Screentime).
    readonly property var all: {
        const now = new Date()
        const count = range === "today" ? 1 : range === "week" ? 7 : 30
        const sum = {}
        for (let i = 0; i < count; i++) {
            const day = st.days[st.key(new Date(now.getFullYear(), now.getMonth(), now.getDate() - i))] ?? {}
            for (const h in day)
                for (const what in day[h]) sum[what] = (sum[what] ?? 0) + day[h][what]
        }
        return Object.keys(sum)
            .map(what => Object.assign({ what: what, seconds: sum[what] }, st.parse(what)))
            .sort((a, b) => b.seconds - a.seconds)
    }
    readonly property real total: all.reduce((sum, e) => sum + e.seconds, 0)
    // Under a minute is noise.
    readonly property var entries: all.filter(e => e.seconds >= 60)

    // By rank; whatever comes after the last colour shares a grey.
    function colorOf(what: string): color {
        return Theme.series[entries.findIndex(e => e.what === what)] ?? Theme.faint
    }

    panelName: "screentime"
    anchors { top: true; left: true }
    spacing: 20

    ColumnLayout {
        spacing: 6

        RowLayout {
            Section { text: "SCREEN TIME"; Layout.fillWidth: true }
            Tabs {
                compact: true
                current: root.range
                onCurrentChanged: root.range = current
                tabs: [
                    { key: "today", label: "TODAY" },
                    { key: "week", label: "WEEK" },
                    { key: "month", label: "MONTH" },
                ]
            }
        }
        StyledText { text: st.fmt(root.total); font.pixelSize: 32 }
    }

    ColumnLayout {
        visible: root.entries.length > 0
        spacing: 12

        Repeater {
            model: root.entries.slice(0, root.shown)
            ColumnLayout {
                required property var modelData
                spacing: 6

                RowLayout {
                    spacing: 10
                    Rectangle {
                        implicitWidth: 8
                        implicitHeight: 8
                        radius: 4
                        color: root.colorOf(modelData.what)
                    }
                    // Nvim shows its project, with its own name beside it.
                    StyledText {
                        text: modelData.project || modelData.app
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        Layout.maximumWidth: 250
                    }
                    StyledText {
                        visible: modelData.project !== ""
                        text: modelData.app
                        color: Theme.dim
                        font.pixelSize: Theme.small
                    }
                    Item { Layout.fillWidth: true }
                    StyledText { text: st.fmt(modelData.seconds); color: Theme.dim }
                }
                Meter {
                    value: modelData.seconds / root.entries[0].seconds
                    fill: root.colorOf(modelData.what)
                    Layout.fillWidth: true
                }
            }
        }
        Section {
            visible: root.entries.length > root.shown
            text: "+ " + (root.entries.length - root.shown) + " MORE"
        }
    }
}
