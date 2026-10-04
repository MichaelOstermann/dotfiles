import QtQuick
import QtQuick.Layouts
import Quickshell
import qs

// What the lock screen looks like: the time, the date, and a password field.
// It only collects the password; whoever shows it decides what Enter does and
// reports back through `checking` and `fail()`.
Rectangle {
    id: root

    property bool checking: false
    property string hint
    signal submitted(string password)
    signal cancelled()

    // Wrong password: clear it and shake the field.
    function fail(): void {
        input.text = ""
        failed = true
        shake.restart()
        input.forceActiveFocus()
    }

    property bool failed: false

    color: "#181921"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // Typing lands here whatever is on screen; only the dots are shown.
    //
    // This must never lose the keyboard: it is the only way in. So it is never
    // disabled (a disabled item gives up focus and does not take it back) —
    // while a password is being checked it just stops accepting edits — and
    // any click on the screen hands the focus back to it.
    TextInput {
        id: input
        focus: true
        opacity: 0
        echoMode: TextInput.Password
        readOnly: root.checking
        onTextChanged: if (text !== "") root.failed = false
        onAccepted: if (text !== "" && !root.checking) root.submitted(text)
        Keys.onEscapePressed: {
            text = ""
            root.cancelled()
        }
    }
    MouseArea {
        anchors.fill: parent
        onPressed: input.forceActiveFocus()
    }
    onVisibleChanged: if (visible) {
        input.text = ""
        failed = false
        input.forceActiveFocus()
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        StyledText {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.pixelSize: 128
            Layout.alignment: Qt.AlignHCenter
        }
        StyledText {
            text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
            color: Theme.dim
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            id: field
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 48
            implicitWidth: 240
            implicitHeight: 40
            radius: 8
            color: Theme.surface
            border { width: 1; color: root.failed ? Theme.critical : "transparent" }

            Row {
                anchors.centerIn: parent
                spacing: 8
                opacity: root.checking ? 0.4 : 1

                Repeater {
                    model: Math.min(input.text.length, 16)
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: Theme.fg
                    }
                }
            }

            SequentialAnimation {
                id: shake
                NumberAnimation { target: field; property: "Layout.leftMargin"; to: 16; duration: 50 }
                NumberAnimation { target: field; property: "Layout.leftMargin"; to: -16; duration: 80 }
                NumberAnimation { target: field; property: "Layout.leftMargin"; to: 8; duration: 60 }
                NumberAnimation { target: field; property: "Layout.leftMargin"; to: 0; duration: 50 }
            }
        }

        Section {
            text: root.checking ? "CHECKING" : root.failed ? "WRONG PASSWORD" : root.hint
            color: root.failed && !root.checking ? Theme.critical : Theme.faint
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 14
            // Keeps its line when empty, so nothing jumps.
            Layout.minimumHeight: implicitHeight
        }
    }
}
