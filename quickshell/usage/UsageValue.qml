import QtQuick
import QtQuick.Layouts
import qs

// What the usage would have cost at API prices, over a selectable range:
// headline figure, activity totals, a daily bar chart stacked by model, and
// the per-model breakdown.
ColumnLayout {
    id: root

    readonly property var days: Usage.current.days ?? []
    property string range: "30d"

    // Model families in all-time cost order; the order fixes their colours.
    readonly property var families: {
        const cost = {}
        for (const d of days)
            for (const [name, , c] of d.models) cost[name] = (cost[name] ?? 0) + c
        return Object.keys(cost).sort((a, b) => cost[b] - cost[a])
    }

    function familyColor(name: string): color {
        return Theme.series[families.indexOf(name)] ?? Theme.dim
    }

    function isoDate(d: date): string {
        const pad = n => String(n).padStart(2, "0")
        return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
    }

    // The range as chart buckets, gaps filled with empty days: one bucket per
    // day, or per week once there are too many days to draw.
    readonly property var buckets: {
        const byDate = {}
        for (const d of days) byDate[d.date] = d

        const today = new Date()
        const count = range === "7d" ? 7 : range === "30d" ? 30
            : days.length ? Math.round((new Date(isoDate(today)) - new Date(days[0].date)) / 86400000) + 1 : 1
        const size = count > 62 ? 7 : 1

        const out = []
        for (let i = count - 1; i >= 0; i--) {
            const date = new Date(today.getFullYear(), today.getMonth(), today.getDate() - i)
            if ((count - 1 - i) % size === 0)
                out.push({ start: date, end: date, cost: 0, tokens: 0, msgs: 0, sessions: 0, models: {} })
            const b = out[out.length - 1]
            const d = byDate[isoDate(date)]
            b.end = date
            if (!d) continue
            b.cost += d.cost
            b.tokens += d.tokens
            b.msgs += d.msgs
            b.sessions += d.sessions
            for (const [name, tokens, cost] of d.models) {
                const m = b.models[name] ?? (b.models[name] = { tokens: 0, cost: 0 })
                m.tokens += tokens
                m.cost += cost
            }
        }
        return out
    }

    readonly property var total: buckets.reduce((t, b) => {
        t.cost += b.cost
        t.tokens += b.tokens
        t.msgs += b.msgs
        t.sessions += b.sessions
        for (const name in b.models) {
            const m = t.models[name] ?? (t.models[name] = { tokens: 0, cost: 0 })
            m.tokens += b.models[name].tokens
            m.cost += b.models[name].cost
        }
        return t
    }, { cost: 0, tokens: 0, msgs: 0, sessions: 0, models: {} })

    function money(n: real): string {
        return "$" + Number(n).toLocaleString(Qt.locale("en_US"), "f", 2)
    }

    function count(n: real): string {
        return Number(n).toLocaleString(Qt.locale("en_US"), "f", 0)
    }

    function dayLabel(b: var): string {
        const fmt = d => d.toLocaleDateString(Qt.locale("en_US"), "ddd dd.MM")
        return b.start === b.end ? fmt(b.start) : fmt(b.start) + " – " + fmt(b.end)
    }

    spacing: 20

    ColumnLayout {
        spacing: 6

        RowLayout {
            Section { text: "API ESTIMATE"; Layout.fillWidth: true }
            Tabs {
                compact: true
                current: root.range
                onCurrentChanged: root.range = current
                tabs: [
                    { key: "7d", label: "7D" },
                    { key: "30d", label: "30D" },
                    { key: "all", label: "ALL" },
                ]
            }
        }
        StyledText { text: root.money(root.total.cost); font.pixelSize: 32 }
        StyledText {
            text: root.count(root.total.sessions) + " sessions · " + root.count(root.total.msgs) + " messages · "
                + Usage.fmtTokens(root.total.tokens) + " tokens"
            color: Theme.dim
        }
    }

    ColumnLayout {
        spacing: 10

        RowLayout {
            Section { text: root.buckets.length && root.buckets[0].start !== root.buckets[0].end ? "WEEKLY" : "DAILY"; Layout.fillWidth: true }
            // The bar under the pointer.
            StyledText {
                readonly property var b: root.buckets[chart.hovered]
                visible: !!b
                text: b ? root.dayLabel(b) + " · " + root.money(b.cost) + " · " + Usage.fmtTokens(b.tokens) + " tokens" : ""
                font.pixelSize: Theme.small
            }
        }
        BarChart {
            id: chart
            Layout.fillWidth: true
            bars: root.buckets.map(b => ({
                segments: root.families
                    .filter(name => b.models[name])
                    .map(name => ({ value: b.models[name].cost, color: root.familyColor(name) })),
            }))
        }
        RowLayout {
            Section { text: root.buckets.length ? root.buckets[0].start.toLocaleDateString(Qt.locale("en_US"), "dd.MM") : ""; Layout.fillWidth: true }
            Section { text: "NOW" }
        }
    }

    ColumnLayout {
        spacing: 10

        Section { text: "BY MODEL" }
        Repeater {
            model: root.families.filter(name => root.total.models[name])

            RowLayout {
                required property string modelData
                readonly property var m: root.total.models[modelData]

                spacing: 10

                Rectangle {
                    implicitWidth: 8
                    implicitHeight: 8
                    radius: 4
                    color: root.familyColor(modelData)
                }
                StyledText { text: modelData.charAt(0).toUpperCase() + modelData.slice(1); Layout.fillWidth: true }
                StyledText { text: Usage.fmtTokens(m.tokens); color: Theme.dim }
                StyledText {
                    text: root.money(m.cost)
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 96
                }
            }
        }
    }
}
