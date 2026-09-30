//@ pragma UseQApplication

// Quickshell greeter for greetd, styled to match the caelestia desktop.
//
// Deliberately self-contained: it shares no code with the vendored
// caelestia shell, because the greeter runs as the `greeter` user, which
// cannot read a home directory at 0700. Everything it needs therefore has
// to live somewhere world readable, and copying caelestia's component tree
// there would couple the login screen to shell updates. The palette below
// is Nord, the same scheme caelestia is pinned to.

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Greetd

ShellRoot {
    id: root

    // ── Nord ────────────────────────────────────────────────────────
    readonly property color base: "#2e3440"
    readonly property color surface: "#3b4252"
    readonly property color overlay: "#434c5e"
    readonly property color muted: "#4c566a"
    readonly property color text: "#d8dee9"
    readonly property color bright: "#eceff4"
    readonly property color accent: "#88c0d0"
    readonly property color accentDim: "#81a1c1"
    readonly property color danger: "#bf616a"

    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    // ── State ───────────────────────────────────────────────────────
    property string user: Quickshell.env("GREETER_USER") || "jabawack81"
    property string message: ""
    property bool failed: false
    property var sessions: []
    property int sessionIndex: 0
    readonly property var session: sessions[sessionIndex] ?? null
    readonly property bool busy: Greetd.state === GreetdState.Authenticating || Greetd.state === GreetdState.Launching

    function authenticate(): void {
        root.message = "";
        root.failed = false;
        if (Greetd.state === GreetdState.Inactive)
            Greetd.createSession(root.user);
        else
            Greetd.respond(passwordField.text);
    }

    Connections {
        target: Greetd

        function onAuthMessage(message: string, error: bool, responseRequired: bool, echoResponse: bool): void {
            if (responseRequired)
                Greetd.respond(passwordField.text);
            else if (error)
                root.message = message;
        }

        function onAuthFailure(message: string): void {
            root.message = message || "Authentication failed";
            root.failed = true;
            passwordField.text = "";
            passwordField.forceActiveFocus();
        }

        function onReadyToLaunch(): void {
            if (root.session)
                Greetd.launch(root.session.exec);
        }

        function onError(error: string): void {
            root.message = error;
            root.failed = true;
        }
    }

    // Available sessions, read from the desktop entries at startup.
    Process {
        running: true
        command: ["sh", "-c", `for f in /usr/share/wayland-sessions/*.desktop; do n=$(sed -n 's/^Name=//p' "$f" | head -1); e=$(sed -n 's/^Exec=//p' "$f" | head -1); [ -n "$n" ] && printf '%s\\t%s\\n' "$n" "$e"; done`]
        stdout: StdioCollector {
            onStreamFinished: {
                root.sessions = text.trim().split("\n").filter(l => l).map(l => {
                    const [name, exec] = l.split("\t");
                    return { name, exec };
                });
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: root.base

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Image {
                anchors.fill: parent
                source: "file:///etc/greetd/wallpaper.png"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                opacity: 0.35
            }

            // ── Clock ───────────────────────────────────────────────
            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.14
                spacing: 4

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    color: root.bright
                    font.family: root.fontFamily
                    font.pixelSize: 96
                    font.weight: Font.Light
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(clock.date, "dddd d MMMM")
                    color: root.accentDim
                    font.family: root.fontFamily
                    font.pixelSize: 18
                }
            }

            // ── Auth card ───────────────────────────────────────────
            Rectangle {
                id: card

                anchors.centerIn: parent
                anchors.verticalCenterOffset: parent.height * 0.1
                implicitWidth: 420
                implicitHeight: cardLayout.implicitHeight + 48
                radius: 16
                color: Qt.rgba(root.surface.r, root.surface.g, root.surface.b, 0.88)
                border.width: 1
                border.color: root.failed ? root.danger : Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.4)

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                ColumnLayout {
                    id: cardLayout

                    anchors.centerIn: parent
                    width: parent.width - 48
                    spacing: 16

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.user
                        color: root.bright
                        font.family: root.fontFamily
                        font.pixelSize: 20
                        font.weight: Font.Medium
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 44
                        radius: 10
                        color: Qt.rgba(root.base.r, root.base.g, root.base.b, 0.9)
                        border.width: 1
                        border.color: passwordField.activeFocus ? root.accent : root.muted

                        TextInput {
                            id: passwordField

                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                            color: root.bright
                            font.family: root.fontFamily
                            font.pixelSize: 15
                            focus: true
                            enabled: !root.busy
                            onAccepted: root.authenticate()

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: passwordField.text.length === 0
                                text: "Password"
                                color: root.muted
                                font: passwordField.font
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        visible: root.message.length > 0
                        text: root.message
                        color: root.danger
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    // Session picker: click to cycle, since there are only
                    // a handful and a dropdown is overkill at a login screen.
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 36
                        radius: 10
                        color: sessionArea.containsMouse ? Qt.rgba(root.overlay.r, root.overlay.g, root.overlay.b, 0.9) : "transparent"
                        border.width: 1
                        border.color: root.muted

                        Text {
                            anchors.centerIn: parent
                            text: root.session ? root.session.name : "No session found"
                            color: root.text
                            font.family: root.fontFamily
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: sessionArea

                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: root.sessions.length > 1
                            onClicked: root.sessionIndex = (root.sessionIndex + 1) % root.sessions.length
                        }
                    }
                }
            }

            // ── Power ───────────────────────────────────────────────
            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 48
                spacing: 12

                Repeater {
                    model: [
                        {
                            label: "Reboot",
                            cmd: ["systemctl", "reboot"]
                        },
                        {
                            label: "Power off",
                            cmd: ["systemctl", "poweroff"]
                        }
                    ]

                    Rectangle {
                        required property var modelData

                        implicitWidth: powerLabel.implicitWidth + 32
                        implicitHeight: 34
                        radius: 10
                        color: powerArea.containsMouse ? Qt.rgba(root.danger.r, root.danger.g, root.danger.b, 0.18) : "transparent"
                        border.width: 1
                        border.color: powerArea.containsMouse ? root.danger : root.muted

                        Text {
                            id: powerLabel

                            anchors.centerIn: parent
                            text: parent.modelData.label
                            color: powerArea.containsMouse ? root.danger : root.text
                            font.family: root.fontFamily
                            font.pixelSize: 13
                        }

                        MouseArea {
                            id: powerArea

                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Quickshell.execDetached(parent.modelData.cmd)
                        }
                    }
                }
            }
        }
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }
}
