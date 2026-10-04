import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import Quickshell.Widgets
import qs.notifications
import qs.picker
import qs.screentime
import qs.sysmon
import qs.updates
import qs.usage
import qs.weather

PanelWindow {
    id: root

    required property SysmonPanel sysmonPanel
    required property Panel usagePanel
    required property Panel updatesPanel
    required property Panel pickerPanel
    required property Panel notificationsPanel
    required property Panel screentimePanel
    required property Panel weatherPanel

    anchors { top: true; left: true; right: true }
    implicitHeight: 38
    color: "transparent"
    WlrLayershell.namespace: "bar"

    readonly property PwNode sink: Pipewire.defaultAudioSink
    // Nodes only report their volume while something tracks them.
    PwObjectTracker { objects: [root.sink] }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    component Pill: Rectangle {
        id: pill

        property alias text: label.text
        property alias textColor: label.color
        property alias fontSize: label.font.pixelSize
        signal clicked()

        implicitWidth: label.implicitWidth + 24
        implicitHeight: 30
        radius: 4
        color: Theme.bg

        StyledText {
            id: label
            anchors.centerIn: parent
            font.pixelSize: 17
        }

        MouseArea {
            anchors.fill: parent
            onClicked: pill.clicked()
        }
    }

    // Open windows, in niri's own order, with a wider gap between workspaces.
    Row {
        anchors.centerIn: parent

        Repeater {
            model: Niri.windows.filter(w => w.title !== "Picture-in-Picture")

            Item {
                id: task

                required property var modelData
                required property int index
                readonly property bool newWorkspace: index > 0
                    && Niri.windows[index - 1]?.workspace_id !== modelData.workspace_id
                readonly property var entry: DesktopEntries.heuristicLookup(modelData.app_id ?? "")

                width: 30 + (newWorkspace ? 14 : 2)
                height: 30

                Rectangle {
                    anchors.right: parent.right
                    width: 30
                    height: 30
                    radius: 4
                    color: task.modelData.is_focused ? Theme.surface : "transparent"

                    // 16px is a size icon themes ship, so nothing is rescaled.
                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 16
                        source: Quickshell.iconPath(task.entry?.icon ?? task.modelData.app_id ?? "", "application-x-executable")
                    }
                    MouseArea {
                        id: taskMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Niri.focus(task.modelData.id)
                        onContainsMouseChanged: {
                            if (containsMouse) {
                                tooltip.target = parent
                                tooltip.text = task.modelData.title ?? ""
                            } else if (tooltip.target === parent) {
                                tooltip.target = null
                            }
                        }
                    }
                }
            }
        }
    }

    // The title of the window under the pointer.
    PopupWindow {
        id: tooltip

        property Item target: null
        property string text

        visible: target !== null && text !== ""
        anchor {
            item: tooltip.target
            edges: Edges.Bottom
            gravity: Edges.Bottom
            margins.bottom: -6
        }
        implicitWidth: Math.min(480, tip.implicitWidth + 24)
        implicitHeight: tip.implicitHeight + 12
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 4
            color: Theme.surface
            border { width: 1; color: Theme.border }

            StyledText {
                id: tip
                anchors.centerIn: parent
                width: Math.min(implicitWidth, 456)
                text: tooltip.text
                textFormat: Text.PlainText
                elide: Text.ElideRight
            }
        }
    }

    RowLayout {
        anchors { fill: parent; leftMargin: 6; rightMargin: 6 }
        spacing: 6

        Pill {
            text: Math.round(Sysmon.cpuPct) + "%"
            fontSize: 16
            textColor: Theme.dim
            onClicked: root.sysmonPanel.show("cpu")
        }

        Pill {
            text: (Sysmon.memUsedKb / 1e6).toFixed(1) + "GB " + Math.round(Sysmon.memPct) + "%"
            fontSize: 16
            textColor: Theme.dim
            onClicked: root.sysmonPanel.show("memory")
        }

        Pill {
            text: Math.round(Sysmon.diskUsedB / 1e9) + "GB " + Math.round(Sysmon.diskPct) + "%"
            fontSize: 16
            textColor: Theme.dim
            onClicked: root.sysmonPanel.show("disk")
        }

        Pill {
            readonly property string level: Usage.current.class ?? ""

            text: Usage.current.text ?? ""
            fontSize: 16
            textColor: level === "critical" ? Theme.critical : level === "warning" ? Theme.warning : Theme.dim
            onClicked: root.usagePanel.toggle()
        }

        // Screen time; the number stays in the panel.
        Pill {
            text: "󰔟"
            fontSize: 16
            textColor: Theme.dim
            onClicked: root.screentimePanel.toggle()
        }

        // The last picked colour.
        Pill {
            implicitWidth: 34
            onClicked: root.pickerPanel.toggle()

            Rectangle {
                anchors.centerIn: parent
                width: 12
                height: 12
                radius: 6
                color: Picker.current
            }
        }

        Item { Layout.fillWidth: true }

        // Only while recording; click to stop.
        Pill {
            visible: Recorder.recording
            text: "󰑊 " + Recorder.elapsed
            textColor: Theme.critical
            onClicked: Recorder.stop()
        }

        // Only while something is waiting to be read.
        Pill {
            visible: Notifications.unread
            text: "󰂚"
            textColor: Theme.critical
            onClicked: root.notificationsPanel.toggle()
        }

        // Just the icon: red when there is something to install.
        Pill {
            text: "󰮯"
            textColor: Updates.pending.length > 0 ? Theme.critical : Theme.dim
            onClicked: root.updatesPanel.toggle()
        }

        Pill {
            // Rain within three hours shows as its chance next to the temperature.
            readonly property var rain: Weather.current.rainSoon
            text: (Weather.current.text ?? "") + (rain ? "  󰖗 " + rain.pop + "%" : "")
            onClicked: root.weatherPanel.toggle()
        }

        Pill {
            readonly property var audio: root.sink?.audio ?? null

            text: audio ? Math.round(audio.volume * 100) + "%" : "–"
            textColor: audio?.muted ? Theme.dim : Theme.fg
            onClicked: Quickshell.execDetached(["env", "XDG_CURRENT_DESKTOP=GNOME", "gnome-control-center", "sound"])
        }

        Pill {
            text: Qt.formatDateTime(clock.date, "ddd dd.MM.yy")
            onClicked: Quickshell.execDetached(["gnome-calendar"])
        }

        Pill {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            onClicked: Quickshell.execDetached(["gnome-calendar"])
        }
    }
}
