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
    implicitHeight: ShellState.brightnessOsdOpen ? 46 : 0

    color: "transparent"
    visible: ShellState.brightnessOsdOpen

    property int brightness: 0

    function parseBrightness(output, shouldShow) {
        const value = Number(output.trim())

        if (!isNaN(value)) {
            root.brightness = value

            if (shouldShow) {
                root.show()
            }
        }
    }

    IpcHandler {
        target: "brightnessOsd"

        function show(): void {
            readBrightnessProcess.running = true
        }

        function raise(): void {
            if (!raiseBrightnessProcess.running) {
                raiseBrightnessProcess.running = true
            }
        }

        function lower(): void {
            if (!lowerBrightnessProcess.running) {
                lowerBrightnessProcess.running = true
            }
        }
    }

    Process {
        id: readBrightnessProcess

        command: [
            "bash",
            "-c",
            "brightnessctl -m | awk -F, '{gsub(\"%\", \"\", $4); print $4}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseBrightness(this.text, false)
            }
        }
    }

    Process {
        id: raiseBrightnessProcess

        command: [
            "bash",
            "-c",
            "brightnessctl set 5%+ >/dev/null && brightnessctl -m | awk -F, '{gsub(\"%\", \"\", $4); print $4}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseBrightness(this.text, true)
            }
        }
    }

    Process {
        id: lowerBrightnessProcess

        command: [
            "bash",
            "-c",
            "brightnessctl set 5%- >/dev/null && brightnessctl -m | awk -F, '{gsub(\"%\", \"\", $4); print $4}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseBrightness(this.text, true)
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
            anchors.centerIn: parent
            spacing: 9

            Item {
                width: 24
                height: 24

                Text {
                    anchors.centerIn: parent

                    text: "󰃠"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                }
            }

            Rectangle {
                width: 115
                height: 5

                anchors.verticalCenter: parent.verticalCenter

                radius: 999
                color: Theme.border

                Rectangle {
                    height: parent.height
                    width: parent.width * Math.min(root.brightness, 100) / 100

                    radius: 999
                    color: Theme.accent
                }
            }

            Item {
                width: 42
                height: 24

                Text {
                    anchors.centerIn: parent

                    text: root.brightness + "%"
                    color: Theme.text
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
            ShellState.brightnessOsdOpen = false
        }
    }

    function show() {
        ShellState.brightnessOsdOpen = true
        autoHideTimer.restart()
    }

    Component.onCompleted: {
        readBrightnessProcess.running = true
    }
}