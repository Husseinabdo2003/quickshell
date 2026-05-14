import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "../../components"
import "../../services"
import "../../theme"

PanelWindow {
    id: root

    property bool windowAlive: false

    readonly property int panelWidth: 520
    readonly property int panelHeight: 260
    readonly property int openDuration: 210
    readonly property int closeDuration: 160

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true

    color: "transparent"
    visible: root.windowAlive

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: ShellState.powerMenuOpen

        onCleared: {
            ShellState.closePowerMenu()
        }
    }

    IpcHandler {
        target: "powerMenu"

        function toggle(): void {
            ShellState.togglePowerMenu()
        }

        function open(): void {
            ShellState.openPowerMenu()
        }

        function close(): void {
            ShellState.closePowerMenu()
        }
    }

    Connections {
        target: ShellState

        function onPowerMenuOpenChanged() {
            if (ShellState.powerMenuOpen) {
                closeHideTimer.stop()
                root.windowAlive = true
            } else {
                closeHideTimer.restart()
            }
        }
    }

    Timer {
        id: closeHideTimer

        interval: root.closeDuration + 40
        repeat: false

        onTriggered: {
            if (!ShellState.powerMenuOpen)
                root.windowAlive = false
        }
    }

    PopupBackdrop {
        opened: ShellState.powerMenuOpen
        dimOpacity: 0.34
        animationDuration: ShellState.powerMenuOpen
            ? root.openDuration
            : root.closeDuration

        onClicked: {
            ShellState.closePowerMenu()
        }
    }

    AnimatedPopupCard {
        id: panel

        width: root.panelWidth
        height: root.panelHeight

        anchors.centerIn: parent

        opened: ShellState.powerMenuOpen

        openedScale: 1.0
        closedScale: 0.92

        openDuration: root.openDuration
        closeDuration: root.closeDuration

        popupRadius: 30
        popupColor: Theme.pillBg
        popupBorderColor: WalTheme.border

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
        }

        Column {
            anchors.centerIn: parent
            spacing: 18

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                HeadingText {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "Power Menu"
                    font.pixelSize: 18
                }

                MetaText {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "Choose a session action"
                    font.pixelSize: 11
                }
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
                        ShellState.closePowerMenu()
                    }
                }

                PowerAction {
                    icon: "󰒲"
                    label: "Suspend"
                    command: "systemctl suspend"

                    onTriggered: {
                        ShellState.closePowerMenu()
                    }
                }

                PowerAction {
                    icon: ""
                    label: "Reboot"
                    command: "systemctl reboot"

                    onTriggered: {
                        ShellState.closePowerMenu()
                    }
                }

                PowerAction {
                    icon: ""
                    label: "Shutdown"
                    command: "systemctl poweroff"

                    onTriggered: {
                        ShellState.closePowerMenu()
                    }
                }
            }
        }
    }
}