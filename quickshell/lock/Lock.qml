import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// The real lock: the compositor hides everything and only shows these
// surfaces until the right password is given.
//
//   qs ipc call lock lock     lock the session
//   qs ipc call lock trial    the same, but it unlocks by itself after 20s —
//                             for trying it without the risk of being stuck
//
// It also locks by itself after ten minutes without input.
Scope {
    id: root

    property bool checking: false
    property bool trial: false
    signal failed()

    function lock(trial: bool): void {
        root.trial = trial
        checking = false
        session.locked = true
    }

    IpcHandler {
        target: "lock"
        function lock(): void { root.lock(false) }
        function trial(): void { root.lock(true) }
    }

    Auth {
        id: auth
        onSucceeded: {
            root.checking = false
            session.locked = false
        }
        onFailed: {
            root.checking = false
            root.failed()
        }
    }

    // Something that keeps the screen awake on purpose, a video for instance,
    // also keeps it unlocked.
    IdleMonitor {
        timeout: 600
        respectInhibitors: true
        onIsIdleChanged: if (isIdle && !session.locked) root.lock(false)
    }

    Timer {
        interval: 20000
        running: session.locked && root.trial
        onTriggered: session.locked = false
    }

    WlSessionLock {
        id: session

        // One per screen.
        WlSessionLockSurface {
            color: "#181921"

            LockSurface {
                id: surface
                anchors.fill: parent
                checking: root.checking
                hint: root.trial ? "TRIAL · UNLOCKS BY ITSELF AFTER 20 SECONDS" : ""
                onSubmitted: password => {
                    root.checking = true
                    auth.check(password)
                }

                Connections {
                    target: root
                    function onFailed() { surface.fail() }
                }
            }
        }
    }
}
