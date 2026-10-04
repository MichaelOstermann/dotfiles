import QtQuick
import Quickshell.Services.Pam

// Checks a password for the current user through PAM, using the config next
// to this file. One answer per check: `succeeded` or `failed`.
PamContext {
    id: root

    property string password
    signal succeeded()
    signal failed()

    function check(text: string): void {
        if (active) return
        password = text
        start()
    }

    configDirectory: Qt.resolvedUrl("pam").toString().replace("file://", "")
    config: "password.conf"

    onPamMessage: if (responseRequired) respond(password)
    onCompleted: result => {
        password = ""
        if (result === PamResult.Success) succeeded()
        else failed()
    }
    onError: {
        password = ""
        failed()
    }

    // A check that never answers must not leave the screen stuck on
    // "checking": give up after ten seconds and count it as a failure.
    property Timer watchdog: Timer {
        interval: 10000
        running: root.active
        onTriggered: {
            root.abort()
            root.password = ""
            root.failed()
        }
    }
}
