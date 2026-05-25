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
    property bool showingResult: ShellState.screenshotMode === "result"

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
        active: ShellState.screenshotOsdOpen

        onCleared: {
            if (ShellState.screenshotOsdOpen)
                ShellState.screenshotOsdOpen = false
        }
    }

    IpcHandler {
        target: "screenshotOsd"

        function show(): void {
            const screenshotPath = Quickshell.env("QS_SCREENSHOT_PATH") || ""
            ShellState.showScreenshotOsd(screenshotPath)
        }

        function menu(): void {
            ShellState.screenshotMode = "menu"
            ShellState.screenshotOsdOpen = true
            ShellState.screenshotPath = ""
        }

        function toggle(): void {
            if (ShellState.screenshotOsdOpen)
                ShellState.screenshotOsdOpen = false
            else
                menu()
        }

        function close(): void {
            ShellState.screenshotOsdOpen = false
        }
    }

    Connections {
        target: ShellState

        function onScreenshotOsdOpenChanged() {
            if (ShellState.screenshotOsdOpen) {
                closeHideTimer.stop()
                root.windowAlive = true

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
            if (!ShellState.screenshotOsdOpen)
                root.windowAlive = false
        }
    }

    function closeMenu() {
        ShellState.screenshotOsdOpen = false
    }

    PopupBackdrop {
        opened: ShellState.screenshotOsdOpen
        dimOpacity: 0.34
        animationDuration: ShellState.screenshotOsdOpen
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

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40

        opened: ShellState.screenshotOsdOpen

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

            // Title and subtitle
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                HeadingText {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "Screenshot"
                    font.pixelSize: 18
                }

                MetaText {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "Choose a capture mode"

                    font.pixelSize: 11
                }
            }

            Divider {
                width: 420
                lineOpacity: 0.55
            }

            // Screenshot action buttons
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 14

                ScreenshotAction {
                    icon: "󰴀"
                    label: "Full Screen"
                    shortcut: "Print"
                    scriptMode: "full"

                    onRequested: function() {
                        root.closeMenu()
                        Quickshell.execDetached([
                            "bash", "-c", "~/.config/hypr/scripts/screenshot.lua full"
                        ])
                    }
                }

                ScreenshotAction {
                    icon: "󰆙"
                    label: "Region"
                    shortcut: "Shift+Print"
                    scriptMode: "region"

                    onRequested: function() {
                        root.closeMenu()
                        Quickshell.execDetached([
                            "bash", "-c", "~/.config/hypr/scripts/screenshot.lua region"
                        ])
                    }
                }

                ScreenshotAction {
                    icon: "󰖲"
                    label: "Window"
                    shortcut: "Alt+Print"
                    scriptMode: "window"

                    onRequested: function() {
                        root.closeMenu()
                        Quickshell.execDetached([
                            "bash", "-c", "~/.config/hypr/scripts/screenshot.lua window"
                        ])
                    }
                }

                ScreenshotAction {
                    icon: "✏"
                    label: "Edit"
                    shortcut: "Super+Print"
                    scriptMode: "edit"

                    onRequested: function() {
                        root.closeMenu()
                        Quickshell.execDetached([
                            "bash", "-c", "~/.config/hypr/scripts/screenshot.lua edit"
                        ])
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        root.windowAlive = ShellState.screenshotOsdOpen
        ShellState.screenshotMode = "menu"
    }
}
