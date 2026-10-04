import QtQuick
import QtQuick.Layouts
import qs

// Where the time went: the apps of today, the last week or the last month,
// with a chart of the same period stacked by app.
Panel {
    id: root

    readonly property var st: Screentime
    property string range: "today"
    readonly property int shown: 12

    // The period as chart buckets, oldest first: hours of today, or days.
    // Each is { label, spent: { what: seconds } }, where `what` is an app or
    // one project in nvim (see Screentime).
    readonly property var buckets: {
        const now = new Date()
        if (range === "today") {
            const day = st.days[st.key(now)] ?? {}
            return Array.from({ length: 24 }, (_, h) => ({
                label: String(h).padStart(2, "0") + ":00",
                spent: day[h] ?? {},
            }))
        }
        const count = range === "week" ? 7 : 30
        return Array.from({ length: count }, (_, i) => {
            const date = new Date(now.getFullYear(), now.getMonth(), now.getDate() - (count - 1 - i))
            const day = st.days[st.key(date)] ?? {}
            const spent = {}
            for (const h in day)
                for (const what in day[h]) spent[what] = (spent[what] ?? 0) + day[h][what]
            return { label: Qt.formatDate(date, "ddd dd.MM"), spent: spent }
        })
    }

    // Everything over the whole period, most used first:
    // [{ what, app, project, seconds }, ...]
    readonly property var all: {
        const sum = {}
        for (const b of buckets)
            for (const what in b.spent) sum[what] = (sum[what] ?? 0) + b.spent[what]
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
        RowLayout {
            StyledText { text: st.fmt(root.total); font.pixelSize: 32; Layout.fillWidth: true }
            // The bar under the pointer.
            StyledText {
                readonly property var b: root.buckets[chart.hovered]
                text: b ? b.label + " · " + st.fmt(Object.values(b.spent).reduce((sum, s) => sum + s, 0)) : ""
                color: Theme.dim
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 5
            }
        }
    }

    ColumnLayout {
        spacing: 10

        BarChart {
            id: chart
            implicitHeight: 80
            Layout.fillWidth: true
            // An hour cannot hold more than an hour.
            max: root.range === "today" ? 3600 : 0
            // The biggest at the bottom, so its colour forms the base.
            bars: root.buckets.map(b => ({
                segments: root.all
                    .filter(e => b.spent[e.what])
                    .map(e => ({ value: b.spent[e.what], color: root.colorOf(e.what) })),
            }))
        }
        RowLayout {
            Section { text: root.range === "today" ? "00:00" : root.buckets[0].label.toUpperCase(); Layout.fillWidth: true }
            Section { text: root.range === "today" ? "24:00" : "TODAY" }
        }
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
