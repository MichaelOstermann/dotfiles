import QtQuick

// Vertical stacked bars. Each bar is { segments: [{ value, color }, ...] },
// stacked bottom-up and scaled to `max`, or when that is 0 to the tallest bar
// (but never to less than `floor`, so near-idle readings stay small).
// `hovered` is the index under the pointer, or -1; `clicked` reports a click
// on a bar.
Item {
    id: root

    property var bars: []
    property real max: 0
    property real floor: 0
    signal clicked(int index)
    readonly property int hovered: {
        for (let i = 0; i < repeater.count; i++)
            if (repeater.itemAt(i)?.containsMouse) return i
        return -1
    }

    readonly property real peak: max > 0 ? max
        : Math.max(1e-9, floor, ...bars.map(b => b.segments.reduce((sum, s) => sum + s.value, 0)))
    readonly property real gap: bars.length > 14 ? 3 : 8
    readonly property real barWidth: bars.length ? (width - gap * (bars.length - 1)) / bars.length : 0

    implicitHeight: 120

    Repeater {
        id: repeater
        model: root.bars.length

        MouseArea {
            id: bar

            required property int index
            readonly property var segments: root.bars[index]?.segments ?? []
            readonly property real total: segments.reduce((sum, s) => sum + s.value, 0)

            x: index * (root.barWidth + root.gap)
            width: root.barWidth
            height: root.height
            hoverEnabled: true
            onClicked: root.clicked(index)
            opacity: root.hovered < 0 || root.hovered === index ? 1 : 0.4

            Behavior on opacity { NumberAnimation { duration: 120 } }

            // Baseline stub, so an empty day still reads as a day.
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 2
                radius: 1
                color: Theme.surface
            }

            Column {
                anchors.bottom: parent.bottom
                width: parent.width

                Repeater {
                    // Top of the stack first: Column lays out downwards.
                    model: bar.segments.length

                    Rectangle {
                        required property int index
                        readonly property var segment: bar.segments[bar.segments.length - 1 - index]

                        width: parent.width
                        height: segment.value > 0 ? Math.max(2, Math.round(segment.value / root.peak * root.height)) : 0
                        color: segment.color
                        topLeftRadius: index === 0 ? 3 : 0
                        topRightRadius: index === 0 ? 3 : 0
                    }
                }
            }
        }
    }
}
