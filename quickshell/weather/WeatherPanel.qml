import QtQuick
import QtQuick.Layouts
import qs

Panel {
    id: root

    readonly property var weather: Weather.current
    readonly property real lo: Math.min(...weather.days.map(d => Number(d.lo)))
    readonly property real hi: Math.max(...weather.days.map(d => Number(d.hi)))
    readonly property real span: hi - lo || 1

    // How hard it rains, per 3 hours: drizzle, steady rain, downpour.
    function rainColor(mm: real): color {
        return mm >= 6 ? Theme.fg : mm >= 1 ? Theme.blue : "#455a87"
    }

    function mm(n: real): string {
        return (n >= 10 ? Math.round(n) : n.toFixed(1)) + " mm"
    }

    panelName: "weather"
    anchors { top: true; right: true }
    spacing: 20

    component Small: StyledText {
        color: Theme.dim
        font.pixelSize: Theme.small
    }

    // ---- Now ---------------------------------------------------------------
    ColumnLayout {
        spacing: 6

        Section { text: root.weather.location.toUpperCase() }
        RowLayout {
            spacing: 12
            Icon { text: root.weather.icon; font.pixelSize: 32 }
            StyledText { text: root.weather.temp + "°"; font.pixelSize: 32; Layout.fillWidth: true }
            StyledText {
                text: root.weather.desc ?? ""
                color: Theme.dim
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 5
            }
        }
        StyledText {
            text: "Feels like " + (root.weather.feels ?? "?") + "° · High " + (root.weather.days[0]?.hi ?? "?")
                + "° · Low " + (root.weather.days[0]?.lo ?? "?") + "° · Wind " + (root.weather.wind ?? "?") + " km/h"
            color: Theme.dim
        }
    }

    // ---- Next hours --------------------------------------------------------
    // Spread edge to edge: the first hour sits flush left, the last flush right.
    Item {
        Layout.fillWidth: true
        implicitHeight: hours.implicitHeight

        Row {
            id: hours

            readonly property real cells: hourCells.count ? hourCells.count * hourCells.itemAt(0).width : 0

            spacing: hourCells.count > 1 ? Math.max(0, (parent.width - cells) / (hourCells.count - 1)) : 0

            Repeater {
                id: hourCells
                model: root.weather.hours

                Column {
                    required property var modelData
                    spacing: 6

                    Small { id: time; text: modelData.time }
                    Icon { text: modelData.icon; font.pixelSize: 20; width: time.width }
                    StyledText { text: modelData.temp + "°"; horizontalAlignment: Text.AlignHCenter; width: time.width }
                }
            }
        }
    }

    // ---- Rain over the week ------------------------------------------------
    // One bar per 3 hours: height is the chance of rain, colour is how hard.
    ColumnLayout {
        spacing: 10

        RowLayout {
            Section { text: "CHANCE OF RAIN"; Layout.fillWidth: true }
            StyledText {
                readonly property var h: root.weather.week[chart.hovered]
                visible: !!h
                text: h ? h.day + " " + h.time + " · " + h.pop + "% · " + root.mm(h.mm) : ""
                font.pixelSize: Theme.small
            }
        }
        BarChart {
            id: chart
            implicitHeight: 56
            max: 100
            Layout.fillWidth: true
            bars: root.weather.week.map(h => ({
                segments: [{ value: h.pop, color: root.rainColor(h.mm) }],
            }))
        }
        RowLayout {
            uniformCellSizes: true
            spacing: 0
            Repeater {
                model: root.weather.days
                Section {
                    required property var modelData
                    text: modelData.day.toUpperCase()
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
        }
    }

    // ---- Days --------------------------------------------------------------
    ColumnLayout {
        spacing: 10
        Repeater {
            model: root.weather.days
            RowLayout {
                required property var modelData
                spacing: 10

                StyledText { text: modelData.day; Layout.preferredWidth: 34 }
                Icon { text: modelData.icon; font.pixelSize: 18; color: Theme.dim; Layout.preferredWidth: 22 }
                StyledText {
                    text: modelData.lo + "°"
                    color: Theme.dim
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 28
                }
                Rectangle {
                    id: track
                    Layout.fillWidth: true
                    implicitHeight: 8
                    radius: 4
                    color: Theme.surface

                    Rectangle {
                        x: Math.round((Number(modelData.lo) - root.lo) / root.span * track.width)
                        width: Math.max(8, Math.round((Number(modelData.hi) - Number(modelData.lo)) / root.span * track.width))
                        height: parent.height
                        radius: parent.radius
                        color: Theme.fg
                    }
                }
                StyledText {
                    text: modelData.hi + "°"
                    color: Theme.dim
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 28
                }
            }
        }
    }
}
