pragma Singleton
import QtQuick
import Quickshell

// Which panel is open. Only one is at a time: opening one closes the other.
Singleton {
    property var current: null

    function opened(panel: var): void {
        if (current && current !== panel) current.visible = false
        current = panel
    }

    function closed(panel: var): void {
        if (current === panel) current = null
    }
}
