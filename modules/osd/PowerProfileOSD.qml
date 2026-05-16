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

    implicitWidth: 300
    implicitHeight: ShellState.powerProfileOsdOpen ? 52 : 0

    color: "transparent"
    visible: ShellState.powerProfileOsdOpen

    property string profileName: "Balanced"
    property string profileIcon: "󰾆"
    property string profileRaw: "balanced"

    property bool readPending: false

    IpcHandler {
        target: "powerProfileOsd"

        function show(): void {
            root.show()
        }

        function refresh(): void {
            root.readProfile(true)
        }
    }

    Connections {
        target: ShellState

        function onPowerProfileOsdOpenChanged() {
            if (ShellState.powerProfileOsdOpen) {
                root.readProfile(true)
                autoHideTimer.restart()
            } else {
                autoHideTimer.stop()
            }
        }
    }

    Process {
        id: readProfileProcess

        command: [
            "bash",
            "-lc",
            "powerprofilesctl get 2>/dev/null || echo balanced"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.setProfile(this.text.trim())
            }
        }

        onExited: function(exitCode) {
            if (root.readPending) {
                root.readPending = false
                root.readProfile(false)
            }
        }
    }

    function show() {
        ShellState.powerProfileOsdOpen = true
        root.readProfile(true)
        autoHideTimer.restart()
    }

    function readProfile(showAfterRead) {
        if (showAfterRead)
            ShellState.powerProfileOsdOpen = true

        if (readProfileProcess.running) {
            root.readPending = true
            return
        }

        readProfileProcess.running = true
    }

    function setProfile(profile) {
        const value = String(profile || "balanced").trim()

        root.profileRaw = value

        if (value === "performance") {
            root.profileName = "Performance"
            root.profileIcon = "󰓅"
            return
        }

        if (value === "power-saver") {
            root.profileName = "Power Saver"
            root.profileIcon = "󰌪"
            return
        }

        root.profileRaw = "balanced"
        root.profileName = "Balanced"
        root.profileIcon = "󰾆"
    }

    Card {
        anchors.fill: parent

        cardRadius: 18
        cardColor: Theme.pillBg
        cardBorderColor: WalTheme.border

        Row {
            anchors.centerIn: parent
            spacing: 12

            Rectangle {
                width: 34
                height: 34
                radius: 14

                color: root.profileRaw === "performance"
                    ? WalTheme.urgentAlpha
                    : WalTheme.accentAlpha

                border.width: 1
                border.color: root.profileRaw === "performance"
                    ? WalTheme.urgent
                    : WalTheme.accent

                Text {
                    anchors.centerIn: parent

                    text: root.profileIcon
                    color: WalTheme.fg

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 17
                    font.bold: true
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                TitleText {
                    text: root.profileName
                    font.pixelSize: 14
                }

                MetaText {
                    text: "Power profile"
                    font.pixelSize: 11
                }
            }
        }
    }

    Timer {
        id: autoHideTimer

        interval: 1300
        repeat: false

        onTriggered: {
            ShellState.powerProfileOsdOpen = false
        }
    }

    Component.onCompleted: {
        root.readProfile(false)
    }
}