import QtQuick

Rectangle {
    property real value: 0
    property alias fill: bar.color
    // Other allowances on the same clock ({ percent: 0-100 }), drawn as ticks.
    property var markers: []

    implicitHeight: 8
    radius: 4
    color: Theme.surface

    Rectangle {
        id: bar
        width: parent.width * Math.max(0, Math.min(1, parent.value))
        height: parent.height
        radius: parent.radius
        color: Theme.fg
    }

    Repeater {
        model: parent.markers
        Rectangle {
            required property var modelData
            x: Math.max(0, Math.min(parent.width - width, parent.width * modelData.percent / 100 - width / 2))
            y: (parent.height - height) / 2
            width: 2
            height: parent.height * 2.5
            radius: 1
            color: Theme.fg
        }
    }
}
