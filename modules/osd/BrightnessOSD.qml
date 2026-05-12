import Quickshell
import QtQuick
import Quickshell.Io

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
            root.brightness = Math.max(0, Math.min(100, value))

            if (shouldShow)
                root.show()
        }
    }

    IpcHandler {
        target: "brightnessOsd"

        function show(): void {
            readBrightnessProcess.running = true
        }

        function raise(): void {
            if (!raiseBrightnessProcess.running)
                raiseBrightnessProcess.running = true
        }

        function lower(): void {
            if (!lowerBrightnessProcess.running)
                lowerBrightnessProcess.running = true
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

    OsdPanel {
        anchors.fill: parent

        icon: "󰃠"
        value: root.brightness
        minimum: 0
        maximum: 100
        valueText: root.brightness + "%"
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