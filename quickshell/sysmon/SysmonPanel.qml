import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs

Panel {
    id: root

    readonly property var s: Sysmon
    property string tab: "cpu"

    readonly property int rateWidth: 88

    panelName: "sysmon"
    anchors { top: true; left: true }
    spacing: 20
    onVisibleChanged: Sysmon.watching = visible

    // Bar pills: open on their tab, or close when it is already showing.
    function show(name: string): void {
        if (visible && tab === name) {
            visible = false
        } else {
            tab = name
            visible = true
        }
    }

    // `qs ipc call sysmon-tab open <tab>`, for keybinds.
    IpcHandler {
        target: "sysmon-tab"
        function open(name: string): void { root.show(name) }
    }

    function temp(c: real): string {
        return c >= 0 ? Math.round(c) + "°C" : ""
    }

    function gb(bytes: real): string {
        const n = bytes / 1e9
        return n >= 10 ? Math.round(n) : n.toFixed(1)
    }

    function fmtRate(bps: real): string {
        return bps >= 1e6 ? (bps / 1e6).toFixed(1) + " MB/s"
            : bps >= 1e3 ? Math.round(bps / 1e3) + " kB/s"
            : Math.round(bps) + " B/s"
    }

    // The headline number of a pane, with the fine print beside it.
    component Figure: RowLayout {
        property alias value: value.text
        property alias detail: detail.text

        StyledText { id: value; font.pixelSize: 32; Layout.fillWidth: true }
        StyledText { id: detail; color: Theme.dim; Layout.alignment: Qt.AlignBottom; Layout.bottomMargin: 5 }
    }

    // One of two headline rates sharing a row, with its chart colour.
    component Rate: ColumnLayout {
        property alias label: label.text
        property alias dot: dot.color
        property real bps

        spacing: 2
        Layout.fillWidth: true

        RowLayout {
            spacing: 8
            Rectangle { id: dot; implicitWidth: 8; implicitHeight: 8; radius: 4 }
            Section { id: label }
        }
        StyledText { text: root.fmtRate(bps); font.pixelSize: 22; Layout.fillWidth: true }
    }

    component Stat: ColumnLayout {
        property string name
        property string detail
        property real pct

        spacing: 6

        RowLayout {
            StyledText { text: name; Layout.fillWidth: true }
            StyledText { text: detail; color: Theme.dim }
        }
        Meter { value: pct / 100; fill: s.levelColor(pct); Layout.fillWidth: true }
    }

    // Recent history as bars, padded on the left so the bars keep one width
    // while it fills. `segments` turns a sample into its stacked parts.
    component History: BarChart {
        property var samples: []
        property var segments: v => [{ value: v, color: s.levelColor(v) }]

        implicitHeight: 80
        Layout.fillWidth: true
        bars: Array(Math.max(0, s.samples - samples.length)).fill({ segments: [] })
            .concat(samples.map(v => ({ segments: segments(v) })))
    }

    ColumnLayout {
        spacing: 0
        Tabs {
            current: root.tab
            onCurrentChanged: root.tab = current
            tabs: [
                { key: "cpu", label: "CPU" },
                { key: "gpu", label: "GPU" },
                { key: "memory", label: "Memory" },
                { key: "disk", label: "Disk" },
                { key: "network", label: "Network" },
                { key: "ports", label: "Ports" },
            ]
        }
        Rectangle {
            implicitHeight: 1
            color: Theme.border
            Layout.fillWidth: true
        }
    }

    // ---- CPU ---------------------------------------------------------------
    ColumnLayout {
        visible: root.tab === "cpu"
        spacing: 20

        Figure { value: Math.round(s.cpuPct) + "%"; detail: root.temp(s.cpuTemp) }
        History { samples: s.cpuHistory; floor: 25 }
        ProcList { sort: "cpu" }
    }

    // ---- GPU ---------------------------------------------------------------
    ColumnLayout {
        visible: root.tab === "gpu"
        spacing: 20

        Figure { value: Math.round(Math.max(0, s.gpuPct)) + "%"; detail: root.temp(s.gpuTemp) }
        History { samples: s.gpuHistory; floor: 25 }
        Stat {
            visible: s.vramTotalB > 0
            name: "VRAM"
            detail: root.gb(s.vramUsedB) + " / " + root.gb(s.vramTotalB) + " GB"
            pct: s.vramUsedB / s.vramTotalB * 100
        }
    }

    // ---- Memory ------------------------------------------------------------
    ColumnLayout {
        visible: root.tab === "memory"
        spacing: 20

        Figure {
            value: (s.memUsedKb / 1e6).toFixed(1) + " GB"
            detail: "of " + (s.memTotalKb / 1e6).toFixed(1) + " GB · " + Math.round(s.memPct) + "%"
        }
        History { samples: s.memHistory; max: 100 }
        ProcList { sort: "mem" }
    }

    // ---- Disk --------------------------------------------------------------
    ColumnLayout {
        visible: root.tab === "disk"
        spacing: 20

        Figure {
            value: root.gb(s.diskUsedB) + " GB"
            detail: ["of " + root.gb(s.diskSizeB) + " GB", Math.round(s.diskPct) + "%", root.temp(s.diskTemp)]
                .filter(p => p).join(" · ")
        }
        ColumnLayout {
            spacing: 16
            Repeater {
                model: s.volumes
                Stat {
                    required property var modelData
                    name: modelData[0]
                    detail: root.gb(modelData[1]) + " / " + root.gb(modelData[2]) + " GB"
                    pct: modelData[1] / modelData[2] * 100
                }
            }
        }
        ColumnLayout {
            spacing: 16
            RowLayout {
                uniformCellSizes: true
                Rate { label: "READ"; dot: Theme.series[0]; bps: s.ioRead }
                Rate { label: "WRITE"; dot: Theme.series[1]; bps: s.ioWrite }
            }
            History {
                samples: s.ioHistory
                segments: h => [
                    { value: h.read, color: Theme.series[0] },
                    { value: h.write, color: Theme.series[1] },
                ]
            }
        }
    }

    // ---- Network -----------------------------------------------------------
    ColumnLayout {
        visible: root.tab === "network"
        spacing: 16

        RowLayout {
            uniformCellSizes: true
            Rate { label: "DOWNLOAD"; dot: Theme.series[0]; bps: s.netDown }
            Rate { label: "UPLOAD"; dot: Theme.series[1]; bps: s.netUp }
        }
        History {
            samples: s.netHistory
            segments: h => [
                { value: h.down, color: Theme.series[0] },
                { value: h.up, color: Theme.series[1] },
            ]
        }
    }

    ColumnLayout {
        id: net

        // Whatever the per-app TCP counters do not explain: UDP (QUIC, VPNs),
        // other users, sockets that closed between two samples.
        readonly property real otherDown: Math.max(0, s.netDown - s.netProcs.reduce((sum, p) => sum + p[1], 0))
        readonly property real otherUp: Math.max(0, s.netUp - s.netProcs.reduce((sum, p) => sum + p[2], 0))
        readonly property var rows: s.netProcs.slice(0, 8).concat([["Other traffic", otherDown, otherUp, []]])

        visible: root.tab === "network"
        spacing: 10

        RowLayout {
            spacing: 14
            Section { text: "BY APP"; Layout.fillWidth: true }
            Section { text: "DOWN"; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: root.rateWidth }
            Section { text: "UP"; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: root.rateWidth }
            Item { Layout.preferredWidth: 22 }
        }

        Repeater {
            model: net.rows.length

            RowLayout {
                required property int index
                readonly property var row: net.rows[index] ?? ["", 0, 0, []]
                readonly property bool other: index === net.rows.length - 1

                spacing: 14

                NameLabel { text: row[0]; color: other ? Theme.dim : Theme.fg }
                StyledText {
                    text: root.fmtRate(row[1])
                    color: row[1] >= 1 ? Theme.fg : Theme.dim
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: root.rateWidth
                }
                StyledText {
                    text: root.fmtRate(row[2])
                    color: row[2] >= 1 ? Theme.fg : Theme.dim
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: root.rateWidth
                }
                KillButton { visible: !other; key: row[0]; pids: row[3] }
                Item { visible: other; Layout.preferredWidth: 22 }
            }
        }
    }

    // ---- Ports -------------------------------------------------------------
    ColumnLayout {
        visible: root.tab === "ports"
        spacing: 10

        RowLayout {
            spacing: 14
            Section { text: "PORT"; Layout.preferredWidth: 110 }
            Section { text: "LISTENING"; Layout.fillWidth: true }
        }

        StyledText {
            visible: s.ports.length === 0
            text: "Nothing is listening"
            color: Theme.dim
        }

        Repeater {
            model: s.ports.length

            RowLayout {
                required property int index
                readonly property var port: s.ports[index] ?? [0, "", [], false, ""]
                readonly property bool mine: port[0] > 0

                spacing: 14

                StyledText {
                    text: port[2].join(" ")
                    elide: Text.ElideRight
                    Layout.preferredWidth: 110
                }
                NameLabel {
                    text: mine ? port[1] : "system"
                    note: port[4]
                    color: mine ? Theme.fg : Theme.dim
                }
                // Reachable from other machines, not just this one.
                StyledText {
                    text: port[3] ? "exposed" : "local"
                    color: port[3] ? Theme.warning : Theme.dim
                    font.pixelSize: Theme.small
                }
                KillButton { visible: mine; key: String(port[0]); pids: [port[0]] }
                Item { visible: !mine; Layout.preferredWidth: 22 }
            }
        }
    }
}
