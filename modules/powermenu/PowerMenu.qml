import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "../../components"
import "../../services"
import "../../theme"

PanelWindow {
    id: root

    property bool animating: false

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    color: "transparent"

    visible: ShellState.powerMenuOpen || root.animating

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: ShellState.powerMenuOpen

        onCleared: {
            root.closePowerMenu()
        }
    }

    IpcHandler {
        target: "powerMenu"

        function toggle(): void {
            root.togglePowerMenu()
        }

        function open(): void {
            root.openPowerMenu()
        }

        function close(): void {
            root.closePowerMenu()
        }
    }

    Timer {
        id: animationStopper

        interval: Animations.panel
        repeat: false

        onTriggered: {
            root.animating = false
        }
    }

    function togglePowerMenu() {
        if (ShellState.powerMenuOpen)
            root.closePowerMenu()
        else
            root.openPowerMenu()
    }

    function openPowerMenu() {
        root.animating = true
        ShellState.powerMenuOpen = true
        animationStopper.restart()
    }

    function closePowerMenu() {
        root.animating = true
        ShellState.powerMenuOpen = false
        animationStopper.restart()
    }

    Rectangle {
        anchors.fill: parent

        enabled: ShellState.powerMenuOpen

        color: Qt.rgba(0, 0, 0, ShellState.powerMenuOpen ? 0.30 : 0)

        Behavior on color {
            ColorAnimation {
                duration: Animations.popupFade
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.closePowerMenu()
            }
        }
    }

    Card {
        id: panel

        width: 520
        height: 260

        anchors.centerIn: parent

        cardRadius: 28
        cardColor: Theme.pillBg
        cardBorderColor: WalTheme.border

        opacity: ShellState.powerMenuOpen ? 1 : 0
        scale: ShellState.powerMenuOpen ? 1 : 0.92

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.popupFade
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Animations.popupFade
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
        }

        Column {
            anchors.centerIn: parent
            spacing: 22

            HeadingText {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "Power Menu"
                font.pixelSize: 18
            }

            Divider {
                width: 420
                lineOpacity: 0.55
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14

                PowerAction {
                    icon: ""
                    label: "Lock"
                    command: "loginctl lock-session"

                    onTriggered: {
                        root.closePowerMenu()
                    }
                }

                PowerAction {
                    icon: "󰒲"
                    label: "Suspend"
                    command: "systemctl suspend"

                    onTriggered: {
                        root.closePowerMenu()
                    }
                }

                PowerAction {
                    icon: ""
                    label: "Reboot"
                    command: "systemctl reboot"
                    danger: true

                    onTriggered: {
                        root.closePowerMenu()
                    }
                }

                PowerAction {
                    icon: ""
                    label: "Shutdown"
                    command: "systemctl poweroff"
                    danger: true

                    onTriggered: {
                        root.closePowerMenu()
                    }
                }
            }
        }
    }
}