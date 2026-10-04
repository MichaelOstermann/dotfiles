import QtQuick
import QtQuick.Layouts
import qs

// The user's apps, busiest first by `sort` ("cpu" or "mem"). An app with
// several processes expands to list them; the cross ends the app or the one
// process.
ColumnLayout {
    id: root

    property string sort: "cpu"
    readonly property var groups: sort === "mem" ? Sysmon.byMem : Sysmon.byCpu
    // The app whose processes are listed underneath it.
    property string expanded: ""

    readonly property int chevronWidth: 12
    readonly property int amountWidth: 56

    function fmtKb(kb: real): string {
        return kb >= 1e6 ? (kb / 1e6).toFixed(1) + "G" : Math.round(kb / 1e3) + "M"
    }

    spacing: 10

    component Row: RowLayout {
        property alias label: label.text
        property alias note: label.note
        property real cpu
        property real rssKb
        property alias key: kill.key
        property alias pids: kill.pids

        spacing: 14

        NameLabel { id: label }
        StyledText {
            text: cpu.toFixed(1) + "%"
            color: root.sort === "cpu" ? Theme.fg : Theme.dim
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: root.amountWidth
        }
        StyledText {
            text: root.fmtKb(rssKb)
            color: root.sort === "mem" ? Theme.fg : Theme.dim
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: root.amountWidth
        }
        KillButton { id: kill }
    }

    RowLayout {
        spacing: 14
        Section { text: "PROCESSES"; Layout.fillWidth: true }
        Section { text: "CPU"; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: root.amountWidth }
        Section { text: "MEM"; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: root.amountWidth }
        Item { Layout.preferredWidth: 22 }
    }

    // Indexed rather than modelled on the list itself, so a refresh rebinds
    // the existing rows instead of recreating them.
    Repeater {
        model: root.groups.length

        ColumnLayout {
            id: group

            required property int index
            readonly property var proc: root.groups[index] ?? []
            readonly property string name: proc[0] ?? ""
            readonly property var members: (proc[3] ?? []).slice()
                .sort((a, b) => root.sort === "mem" ? b[3] - a[3] : b[2] - a[2])
            readonly property bool open: members.length > 1 && root.expanded === name

            spacing: 10

            RowLayout {
                spacing: 6

                Icon {
                    text: group.members.length > 1 ? (group.open ? "󰅀" : "󰅂") : ""
                    color: Theme.dim
                    font.pixelSize: 18
                    Layout.preferredWidth: root.chevronWidth

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        enabled: group.members.length > 1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.expanded = group.open ? "" : group.name
                    }
                }
                Row {
                    label: group.name
                    note: group.members.length > 1 ? "×" + group.members.length : ""
                    cpu: group.proc[1] ?? 0
                    rssKb: group.proc[2] ?? 0
                    key: group.name
                    pids: group.members.map(p => p[0])
                }
            }

            Repeater {
                model: group.open ? group.members.length : 0

                Row {
                    required property int index
                    readonly property var p: group.members[index] ?? []

                    label: p[1] ?? ""
                    note: p[0] ?? ""
                    cpu: p[2] ?? 0
                    rssKb: p[3] ?? 0
                    key: String(p[0] ?? "")
                    pids: [p[0]]
                    Layout.leftMargin: root.chevronWidth + 6 + 14
                }
            }
        }
    }
}
