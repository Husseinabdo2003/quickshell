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
    property bool actionRunning: false
    property bool hibernateAvailable: false

    readonly property int panelWidth: 640
    readonly property int panelHeight: 260
    readonly property int openDuration: Animations.normal
    readonly property int closeDuration: Animations.fast

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
            if (ShellState.powerMenuOpen)
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

    Process {
        id: hibernateCheckProcess

        command: []
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.hibernateAvailable = String(this.text || "").trim() === "ok"
            }
        }
    }

    Connections {
        target: ShellState

        function onPowerMenuOpenChanged() {
            if (ShellState.powerMenuOpen) {
                closeHideTimer.stop()
                root.windowAlive = true
                root.actionRunning = false

                Qt.callLater(function() {
                    panel.forceActiveFocus()
                })
            } else {
                closeHideTimer.restart()
            }
        }
    }

    Timer {
        id: closeHideTimer

        interval: Animations.normal
        repeat: false

        onTriggered: {
            if (!ShellState.powerMenuOpen)
                root.windowAlive = false
        }
    }

    function closeMenu() {
        ShellState.closePowerMenu()
    }

    function runPowerAction(command, closeImmediately) {
        if (root.actionRunning)
            return

        const cleanCommand = String(command || "").trim()

        if (cleanCommand.length === 0)
            return

        root.actionRunning = true

        if (closeImmediately)
            root.closeMenu()

        Quickshell.execDetached(cleanCommand.split(/\s+/))
    }

    PopupBackdrop {
        opened: ShellState.powerMenuOpen
        dimOpacity: 0.34
        animationDuration: ShellState.powerMenuOpen
            ? root.openDuration
            : root.closeDuration

        onClicked: {
            root.closeMenu()
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

        focus: true

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.closeMenu()
                event.accepted = true
                return
            }
        }

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

                    text: root.actionRunning
                        ? "Running selected action..."
                        : "Choose a session action"

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
                    locked: root.actionRunning
                    needsConfirmation: false

                    onRequested: function(command) {
                        root.runPowerAction(command, true)
                    }
                }

                PowerAction {
                    icon: "󰒲"
                    label: "Suspend"
                    command: "systemctl suspend"
                    locked: root.actionRunning
                    needsConfirmation: false

                    onRequested: function(command) {
                        root.runPowerAction(command, true)
                    }
                }

                PowerAction {
                    icon: "󰤄"
                    label: "Hibernate"
                    command: "systemctl hibernate"
                    visible: root.hibernateAvailable
                    locked: root.actionRunning
                    needsConfirmation: false
                    danger: false

                    onRequested: function(command) {
                        root.runPowerAction(command, true)
                    }
                }

                PowerAction {
                    icon: ""
                    label: "Reboot"
                    command: "systemctl reboot"
                    locked: root.actionRunning
                    needsConfirmation: true
                    danger: true

                    onRequested: function(command) {
                        root.runPowerAction(command, true)
                    }
                }

                PowerAction {
                    icon: ""
                    label: "Shutdown"
                    command: "systemctl poweroff"
                    locked: root.actionRunning
                    needsConfirmation: true
                    danger: true

                    onRequested: function(command) {
                        root.runPowerAction(command, true)
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        root.windowAlive = ShellState.powerMenuOpen
        hibernateCheckProcess.exec([
            "bash",
            "-c",
            "systemctl hibernate --dry-run >/dev/null 2>&1 && echo ok"
        ])
    }
}
