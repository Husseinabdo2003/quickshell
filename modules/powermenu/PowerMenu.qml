import Quickshell
import QtQuick
import Quickshell.Io

import "../../theme"
import "../../components"
import "../../services"

PanelWindow {

    IpcHandler {
        target: "powerMenu"

        function toggle(): void {
            ShellState.powerMenuOpen = !ShellState.powerMenuOpen
        }

        function open(): void {
            ShellState.powerMenuOpen = true
        }

        function close(): void {
            ShellState.powerMenuOpen = false
        }
    }

    id: root

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    color: "transparent"

    visible: ShellState.powerMenuOpen

    Rectangle {
        anchors.fill: parent

        visible: ShellState.powerMenuOpen
        enabled: ShellState.powerMenuOpen

        color: Qt.rgba(0, 0, 0, 0.30)

        MouseArea {
            anchors.fill: parent

            onClicked: {
                ShellState.powerMenuOpen = false
            }
        }
    }

    Rectangle {
        id: panel

        visible: ShellState.powerMenuOpen
        enabled: ShellState.powerMenuOpen

        width: 520
        height: 260

        anchors.centerIn: parent

        radius: 28
        color: Theme.pillBg

        border.width: 1
        border.color: Theme.border

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
        }

        Column {
            anchors.centerIn: parent
            spacing: 22

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "Power Menu"
                color: Theme.textStrong
                font.family: Theme.fontFamily
                font.pixelSize: 18
                font.bold: true
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14

                PowerAction {
                    icon: ""
                    text: "Lock"
                    command: "loginctl lock-session"
                }

                PowerAction {
                    icon: "󰒲"
                    text: "Suspend"
                    command: "systemctl suspend"
                }

                PowerAction {
                    icon: ""
                    text: "Reboot"
                    command: "systemctl reboot"
                }

                PowerAction {
                    icon: ""
                    text: "Shutdown"
                    command: "systemctl poweroff"
                }
            }
        }
    }

    component PowerAction: Rectangle {
        id: action

        property string icon: ""
        property string text: ""
        property string command: ""

        width: 105
        height: 130

        radius: 24
        color: Theme.pillBg

        border.width: 1
        border.color: Theme.border

        Column {
            anchors.centerIn: parent
            spacing: 12

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: action.icon
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: 28
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: action.text
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                ShellState.powerMenuOpen = false
                Quickshell.execDetached(["bash", "-c", action.command])
            }
        }
    }
}