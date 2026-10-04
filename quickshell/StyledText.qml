import QtQuick

Text {
    color: Theme.fg
    font.family: Theme.font
    font.pixelSize: 15
    font.weight: Font.Medium
    // FreeType glyphs like GTK draws, not Qt Quick's distance-field text.
    renderType: Text.NativeRendering
}
