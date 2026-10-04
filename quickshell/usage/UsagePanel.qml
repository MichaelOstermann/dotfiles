import QtQuick
import QtQuick.Layouts
import qs

Panel {
    id: root

    readonly property var usage: Usage.current

    panelName: "claude-usage"
    anchors { top: true; left: true }
    spacing: 20
    onVisibleChanged: Usage.watching = visible

    component Amount: StyledText {
        color: Theme.dim
        horizontalAlignment: Text.AlignRight
    }

    component Limit: ColumnLayout {
        property string name
        property real util
        property string reset
        property string window

        spacing: 6

        RowLayout {
            StyledText { text: name; Layout.fillWidth: true }
            Amount { text: util.toFixed(0) + "%" }
        }
        Meter {
            value: util / 100
            markers: root.usage.scoped.filter(s => s.window === window)
            Layout.fillWidth: true
        }
        StyledText {
            text: "Resets in " + Usage.fmtReset(reset)
            color: Theme.dim
            font.pixelSize: Theme.small
        }
    }

    ColumnLayout {
        spacing: 16
        Section { text: "LIMITS" }
        Limit { name: "Session"; util: root.usage.fiveUtil; reset: root.usage.fiveResetAt; window: "session" }
        Limit { name: "Weekly"; util: root.usage.sevenUtil; reset: root.usage.sevenResetAt; window: "weekly" }
    }

    UsageValue {}
}
