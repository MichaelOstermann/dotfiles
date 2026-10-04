import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Text-only app launcher with a numbat calculator built in.
//
// A query with a digit in it is also tried as a numbat expression; "=" in
// front forces calculator-only. Enter on a result copies it and keeps the
// launcher open, and accepted expressions stay in the numbat session, so
// `ans` and `let` definitions carry over to the next line.
PanelWindow {
    id: root

    readonly property int maxApps: 10
    readonly property string query: input.text.trim()
    readonly property bool forced: query.startsWith("=")
    readonly property string expr: forced ? query.slice(1).trim() : query
    readonly property bool mathy: forced || /\d/.test(query)

    // Accepted expressions, replayed before each evaluation.
    property var session: []
    // The last evaluation: { expr, ok, text }
    property var calc: null
    // The last one that worked. It stays on screen, dimmed, while the
    // expression is being typed further, so the row does not flicker.
    property var lastGood: null
    // The result belongs to exactly what is typed: Enter can take it.
    readonly property bool fresh: calc !== null && calc.expr === expr && calc.ok
    // "=" mode also shows why an expression does not evaluate.
    readonly property bool failed: forced && calc !== null && calc.expr === expr && !calc.ok
    readonly property bool hasCalc: expr !== "" && mathy && (lastGood !== null || failed)
    onMathyChanged: if (!mathy) lastGood = null

    // Launch counts by desktop entry id, for ordering.
    property var counts: ({})

    readonly property var apps: forced ? [] : matches(query)
    // Only a fresh result is a selectable row; a stale one is just shown.
    readonly property int rowCount: (fresh ? 1 : 0) + apps.length
    property int selected: 0
    onQueryChanged: selected = 0
    onExprChanged: {
        if (expr === "") lastGood = null
        evaluate.restart()
    }

    function toggle(): void { visible = !visible }

    // 0 best … 4 worst, -1 no match.
    function score(entry: var, q: string): int {
        const name = entry.name.toLowerCase()
        if (name.startsWith(q)) return 0
        if (name.split(/[\s-]+/).some(word => word.startsWith(q))) return 1
        if (name.includes(q)) return 2
        let i = 0
        for (const ch of name) if (ch === q[i]) i++
        if (i === q.length) return 3
        const extra = (entry.genericName + " " + entry.keywords.join(" ")).toLowerCase()
        return extra.includes(q) ? 4 : -1
    }

    function matches(q: string): var {
        const needle = q.toLowerCase()
        return DesktopEntries.applications.values
            .filter(e => !e.noDisplay)
            .map(e => ({ entry: e, score: needle === "" ? 0 : score(e, needle), count: counts[e.id] ?? 0 }))
            .filter(m => m.score >= 0)
            .sort((a, b) => a.score - b.score || b.count - a.count || a.entry.name.localeCompare(b.entry.name))
            .slice(0, maxApps)
            .map(m => m.entry)
    }

    function move(by: int): void {
        if (rowCount > 0) selected = (selected + by + rowCount) % rowCount
    }

    function accept(): void {
        if (fresh && selected === 0) {
            if (calc.text !== "") Quickshell.execDetached(["wl-copy", calc.text])
            session = session.concat([expr]).slice(-20)
            input.text = ""
            return
        }
        const entry = apps[selected - (fresh ? 1 : 0)]
        if (!entry) return
        counts[entry.id] = (counts[entry.id] ?? 0) + 1
        countsChanged()
        store.setText(JSON.stringify(counts))
        if (entry.runInTerminal) Quickshell.execDetached(["ghostty", "-e", ...entry.command])
        else entry.execute()
        visible = false
    }

    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: if (visible) {
        input.text = ""
        input.forceActiveFocus()
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.toggle() }
        // Open with the query filled in; "=" starts in calculator mode.
        function open(query: string): void {
            root.visible = true
            input.text = query
        }
    }

    FileView {
        id: store
        path: Quickshell.statePath("launcher.json")
        printErrors: false
        onLoaded: {
            try { root.counts = JSON.parse(text()) } catch (e) {}
        }
    }

    // Debounced, and re-run when the expression changed while numbat ran.
    Timer {
        id: evaluate
        interval: 80
        onTriggered: {
            if (!root.mathy || root.expr === "") return
            if (numbat.running) { restart(); return }
            numbat.expr = root.expr
            const command = ["sh", "-c", 'numbat --color never "$@" 2>&1; echo "exit:$?"', "sh"]
            for (const e of root.session) command.push("-e", e)
            command.push("-e", root.expr)
            numbat.command = command
            numbat.running = true
        }
    }

    Process {
        id: numbat
        property string expr
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                const ok = lines.pop() === "exit:0"
                const shown = lines.map(l => l.trim()).filter(l => l !== "")
                root.calc = { expr: numbat.expr, ok: ok, text: ok ? shown.join(" ") : (shown[0] ?? "error") }
                if (ok) root.lastGood = root.calc
            }
        }
    }

    // Click outside the card to close.
    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        id: card

        readonly property int rowHeight: 32
        // Placed as if the list were full, so the input does not move as
        // results come and go.
        readonly property real fullHeight: inputBox.height + 1 + 16 + root.maxApps * (rowHeight + 2)

        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round((parent.height - fullHeight) / 2)
        width: 520
        height: inputBox.height + (results.visible ? 1 + results.implicitHeight + 16 : 0)
        radius: 8
        color: Theme.bg
        border { width: 1; color: Theme.border }

        MouseArea { anchors.fill: parent }

        component Row: Rectangle {
            // Position among the selectable rows, or -1.
            property int row: -1
            property alias text: label.text
            property alias note: note.text
            property alias textColor: label.color
            readonly property bool current: row >= 0 && root.selected === row

            implicitHeight: card.rowHeight
            radius: 4
            color: current ? Theme.surface : "transparent"
            Layout.fillWidth: true

            RowLayout {
                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                spacing: 12
                StyledText { id: label; textFormat: Text.PlainText; elide: Text.ElideRight; Layout.fillWidth: true }
                StyledText { id: note; color: Theme.dim; font.pixelSize: Theme.small }
            }

            MouseArea {
                anchors.fill: parent
                enabled: parent.row >= 0
                onClicked: {
                    root.selected = parent.row
                    root.accept()
                }
            }
        }

        // The input, with the same padding on every side.
        Item {
            id: inputBox
            width: parent.width
            height: input.implicitHeight + 36

            TextInput {
                id: input
                anchors { fill: parent; margins: 18 }
                color: Theme.fg
                selectionColor: Theme.border
                selectedTextColor: Theme.fg
                font.family: Theme.font
                font.pixelSize: 15
                font.weight: Font.Medium
                renderType: Text.NativeRendering
                clip: true

                StyledText {
                    visible: input.text === ""
                    text: "Apps, or math with numbat"
                    color: Theme.border
                }

                Keys.onPressed: event => {
                    const ctrl = event.modifiers & Qt.ControlModifier
                    if (event.key === Qt.Key_Escape) root.visible = false
                    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) root.accept()
                    else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab || (ctrl && (event.key === Qt.Key_N || event.key === Qt.Key_J))) root.move(1)
                    else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab || (ctrl && (event.key === Qt.Key_P || event.key === Qt.Key_K))) root.move(-1)
                    else return
                    event.accepted = true
                }
            }
        }

        Rectangle {
            visible: results.visible
            anchors.top: inputBox.bottom
            width: parent.width
            height: 1
            color: Theme.border
        }

        ColumnLayout {
            id: results
            visible: root.hasCalc || root.apps.length > 0
            anchors { top: inputBox.bottom; left: parent.left; right: parent.right; margins: 8; topMargin: 9 }
            spacing: 2

            Row {
                visible: root.hasCalc
                row: root.fresh ? 0 : -1
                text: root.failed ? root.calc.text
                    : !root.lastGood ? ""
                    : root.lastGood.text === "" ? "defined" : "= " + root.lastGood.text
                textColor: root.fresh ? Theme.fg : Theme.dim
                note: !root.fresh ? "" : root.calc.text === "" ? "↵ keep" : "↵ copy"
            }

            Repeater {
                model: root.apps
                Row {
                    required property var modelData
                    required property int index
                    row: index + (root.fresh ? 1 : 0)
                    text: modelData.name
                }
            }
        }
    }
}
