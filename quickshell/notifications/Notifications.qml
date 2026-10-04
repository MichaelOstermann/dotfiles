pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs

// The notification daemon. A notification pops up for a few seconds and then
// stays in the history until it is cleared, its app gets focused, or its
// sender withdraws it. Blacklisted apps only get the popup.
Singleton {
    id: root

    // Kept notifications, newest first.
    readonly property var history: server.trackedNotifications.values
        .filter(n => !root.ignored(n))
        .reverse()
    readonly property bool unread: history.length > 0

    // On screen right now, newest first: [{ id, app, summary, body, critical, until }, ...]
    property var popups: []
    readonly property int maxPopups: 3

    // When each one arrived, by id.
    property var arrived: ({})

    // App names whose notifications are shown but never kept.
    property var blacklist: []

    function ignored(n: var): bool {
        return n.appName === "" || blacklist.includes(n.appName)
    }

    // Notification app names and niri app ids differ only in case and
    // reverse-DNS prefix for the apps that matter ("Slack" vs "slack").
    function fromApp(n: var, appId: string): bool {
        const id = appId.toLowerCase()
        const names = [n.appName, n.desktopEntry].map(s => (s ?? "").toLowerCase())
        return id !== "" && (names.includes(id) || names.includes(id.split(".").pop()))
    }

    function find(id: int): var {
        return server.trackedNotifications.values.find(n => n.id === id) ?? null
    }

    // Runs the notification's default action, if it has one, and clears it.
    function activate(id: int): void {
        const n = find(id)
        if (!n) return
        const action = n.actions.find(a => a.identifier === "default") ?? n.actions[0]
        if (action) action.invoke()
        dismiss(id)
    }

    function dismiss(id: int): void {
        popups = popups.filter(p => p.id !== id)
        find(id)?.dismiss()
    }

    // Clears the history and takes down whatever is on screen.
    function clearAll(): void {
        popups = []
        for (const n of server.trackedNotifications.values) n.dismiss()
    }

    function clearApp(appId: string): void {
        for (const n of history)
            if (fromApp(n, appId)) n.dismiss()
    }

    // Going to an app counts as having seen what it had to say.
    Connections {
        target: Niri
        function onFocusedChanged() {
            if (Niri.focused) root.clearApp(Niri.focused.app_id ?? "")
        }
    }

    // `qs ipc call notify clear`, for a keybind.
    IpcHandler {
        target: "notify"
        function clear(): void { root.clearAll() }
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        keepOnReload: false

        onNotification: n => {
            n.tracked = true
            const critical = n.urgency === NotificationUrgency.Critical
            const life = critical ? Infinity : n.urgency === NotificationUrgency.Low ? 3000 : 6000
            root.arrived[n.id] = Date.now()
            root.popups = [{
                id: n.id,
                app: n.appName,
                summary: n.summary,
                body: n.body,
                critical: critical,
                until: Date.now() + life,
            }].concat(root.popups.filter(p => p.id !== n.id)).slice(0, root.maxPopups)
        }
    }

    // Takes popups off the screen when their time is up. What happens next
    // depends: ignored apps and the app being looked at are dropped, the
    // rest stay in the history.
    Timer {
        interval: 250
        running: root.popups.length > 0
        repeat: true
        onTriggered: {
            const now = Date.now()
            const expired = root.popups.filter(p => p.until <= now || !root.find(p.id))
            if (expired.length === 0) return
            root.popups = root.popups.filter(p => !expired.includes(p))
            for (const p of expired) {
                const n = root.find(p.id)
                if (n && (root.ignored(n) || root.fromApp(n, Niri.focused?.app_id ?? ""))) n.dismiss()
            }
        }
    }

    FileView {
        path: Qt.resolvedUrl("blacklist.txt")
        onLoaded: root.blacklist = text().split("\n")
            .map(line => line.replace(/#.*$/, "").trim())
            .filter(line => line !== "")
    }
}
