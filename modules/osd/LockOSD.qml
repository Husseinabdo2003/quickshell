import Quickshell
import QtQuick
import Quickshell.Io

import "../../components"
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

    property string pendingLock: ""

    IpcHandler {
        target: "lockOsd"

        function caps(): void {
            root.requestRead("caps")
        }

        function num(): void {
            root.requestRead("num")
        }
    }

    Timer {
        id: readDelayTimer

        interval: 70
        repeat: false

        onTriggered: {
            if (root.pendingLock === "caps") {
                root.startCapsRead()
                return
            }

            if (root.pendingLock === "num") {
                root.startNumRead()
                return
            }
        }
    }

    Process {
        id: capsProcess

        command: [
            "bash",
            "-lc",
            "f=$(ls /sys/class/leds/*::capslock/brightness 2>/dev/null | head -1); [ -n \"$f\" ] && cat \"$f\" || echo 0"
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

        onExited: function(exitCode) {
            if (root.pendingLock === "caps") {
                root.pendingLock = ""
                root.startCapsRead()
            }
        }
    }

    Process {
        id: numProcess

        command: [
            "bash",
            "-lc",
            "f=$(ls /sys/class/leds/*::numlock/brightness 2>/dev/null | head -1); [ -n \"$f\" ] && cat \"$f\" || echo 0"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim()

                root.lockName = "Num Lock"
                root.lockIcon = "󰎠"
                root.lockState = value === "1" ? "ON" : "OFF"
                root.show()
            }
        }

        onExited: function(exitCode) {
            if (root.pendingLock === "num") {
                root.pendingLock = ""
                root.startNumRead()
            }
        }
    }

    function requestRead(lockType) {
        root.pendingLock = lockType
        readDelayTimer.restart()
    }

    function startCapsRead() {
        if (capsProcess.running) {
            root.pendingLock = "caps"
            return
        }

        root.pendingLock = ""
        capsProcess.running = true
    }

    function startNumRead() {
        if (numProcess.running) {
            root.pendingLock = "num"
            return
        }

        root.pendingLock = ""
        numProcess.running = true
    }

    function show() {
        ShellState.lockOsdOpen = true
        autoHideTimer.restart()
    }

    Card {
        anchors.fill: parent

        cardRadius: 16
        cardColor: Theme.pillBg
        cardBorderColor: root.lockState === "ON"
            ? WalTheme.accent
            : WalTheme.border

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
                    color: root.lockState === "ON"
                        ? WalTheme.accent
                        : WalTheme.fg

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                }
            }

            Item {
                id: labelBox

                width: 92
                height: parent.height

                TitleText {
                    anchors.centerIn: parent

                    text: root.lockName
                    font.pixelSize: Theme.fontSize
                }
            }

            Item {
                id: stateBox

                width: 34
                height: parent.height

                MetaText {
                    anchors.centerIn: parent

                    text: root.lockState
                    accentText: root.lockState === "ON"
                    boldText: true
                    font.pixelSize: Theme.fontSize
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
}