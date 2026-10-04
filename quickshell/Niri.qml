pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Windows and workspaces, kept current from niri's event stream.
Singleton {
    id: root

    property var byId: ({})             // window id -> window
    property var workspaces: ({})       // workspace id -> workspace

    // Every window in the order niri lays them out: by workspace, then by
    // column and row, with floating windows after the tiled ones.
    readonly property var windows: Object.values(byId).sort((a, b) => {
        const ws = id => workspaces[id]?.idx ?? 1e6
        const pos = w => w.layout?.pos_in_scrolling_layout ?? [1e6, 1e6]
        return ws(a.workspace_id) - ws(b.workspace_id)
            || pos(a)[0] - pos(b)[0]
            || pos(a)[1] - pos(b)[1]
            || a.id - b.id
    })

    readonly property var focused: Object.values(byId).find(w => w.is_focused) ?? null

    function focus(id: int): void {
        Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", String(id)])
    }

    function handle(event: var): void {
        if (event.WindowsChanged) {
            const all = {}
            for (const w of event.WindowsChanged.windows) all[w.id] = w
            byId = all
        } else if (event.WindowOpenedOrChanged) {
            const w = event.WindowOpenedOrChanged.window
            const all = Object.assign({}, byId)
            // A window that arrives focused takes the focus from the others.
            if (w.is_focused)
                for (const id in all) all[id] = Object.assign({}, all[id], { is_focused: false })
            all[w.id] = w
            byId = all
        } else if (event.WindowClosed) {
            const all = Object.assign({}, byId)
            delete all[event.WindowClosed.id]
            byId = all
        } else if (event.WindowFocusChanged) {
            const all = {}
            for (const id in byId)
                all[id] = Object.assign({}, byId[id], { is_focused: byId[id].id === event.WindowFocusChanged.id })
            byId = all
        } else if (event.WindowLayoutsChanged) {
            const all = Object.assign({}, byId)
            for (const [id, layout] of event.WindowLayoutsChanged.changes)
                if (all[id]) all[id] = Object.assign({}, all[id], { layout: layout })
            byId = all
        } else if (event.WorkspacesChanged) {
            const all = {}
            for (const ws of event.WorkspacesChanged.workspaces) all[ws.id] = ws
            workspaces = all
        }
    }

    Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try { root.handle(JSON.parse(line)) } catch (e) {}
            }
        }
    }
}
