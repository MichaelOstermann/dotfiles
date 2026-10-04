pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property color fg: "#93a2d7"
    readonly property color dim: "#6e7bb0"
    readonly property color faint: "#555e86"
    readonly property color bg: "#1f2029"
    readonly property color surface: "#282a3a"
    readonly property color border: "#3b405a"
    readonly property color blue: "#6789d0"
    readonly property color warning: "#907149"
    readonly property color critical: "#b05669"
    // Data series, in order of prominence.
    readonly property var series: [fg, "#9D7CD8", "#51909f", "#a36747", "#69884b", "#b05669", "#6789d0", "#907149", "#866fb1"]
    readonly property string font: "Iosevka NF"
    readonly property int small: 13
}
