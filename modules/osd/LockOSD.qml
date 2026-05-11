import Quickshell
import QtQuick
import Quickshell.Io

import "../../theme"
import "../../services"

PanelWindow {
    id: root

    anchors {
        bottom: true
    }

    margins {
        bottom: 100 
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true

    implicitWidth: 230
    implicitHeight: ShellState.lockOsdOpen ? 46 : 0

    color: "transparent"
    visible: ShellState.lockOsdOpen

    property string lockName: "Lock"
    property string lockState: "OFF"
    property string lockIcon: "󰌌"

    IpcHandler {
        target: "lockOsd"

        function caps(): void {
            capsProcess.running = true
        }

        function num(): void {
            numProcess.running = true
        }
    }

    Process {
        id: capsProcess

        command: [
            "bash",
            "-c",
            "sleep 0.05; f=$(ls /sys/class/leds/*::capslock/brightness 2>/dev/null | head -1); [ -n \"$f\" ] && cat \"$f\" || echo 0"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim()

                root.lockName = "Caps Lock"
                root.lockIcon = "󰪛"
                root.lockState = value === "1" ? "ON" : "OFF"
                root.show()
            }
        }
    }

    Process {
        id: numProcess

        command: [
            "bash",
            "-c",
            "sleep 0.05; f=$(ls /sys/class/leds/*::numlock/brightness 2>/dev/null | head -1); [ -n \"$f\" ] && cat \"$f\" || echo 0"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim()

                root.lockName = "Num Lock"
                root.lockIcon = ""
                root.lockState = value === "1" ? "ON" : "OFF"
                root.show()
            }
        }
    }

    Rectangle {
        anchors.fill: parent

        radius: 16
        color: Theme.pillBg

        border.width: 1
        border.color: Theme.border

        Row {
            id: contentRow

            width: iconBox.width + labelBox.width + stateBox.width + spacing * 2
            height: parent.height

            anchors.centerIn: parent
            spacing: 10

            Item {
                id: iconBox

                width: 28
                height: parent.height

                Text {
                    anchors.centerIn: parent

                    text: root.lockIcon
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                }
            }

            Item {
                id: labelBox

                width: 92
                height: parent.height

                Text {
                    anchors.centerIn: parent

                    text: root.lockName
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }
            }

            Item {
                id: stateBox

                width: 34
                height: parent.height

                Text {
                    anchors.centerIn: parent

                    text: root.lockState
                    color: root.lockState === "ON" ? Theme.accent : Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }
            }
        }
    }

    Timer {
        id: autoHideTimer

        interval: 1000
        repeat: false

        onTriggered: {
            ShellState.lockOsdOpen = false
        }
    }

    function show() {
        ShellState.lockOsdOpen = true
        autoHideTimer.restart()
    }
}