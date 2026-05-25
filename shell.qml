//@ pragma UseQApplication
//@ pragma IconTheme Yaru

import Quickshell
import Quickshell.Io
import QtQuick

import "services"

import "modules/bar"
import "modules/powermenu"
import "modules/osd"
import "modules/notifications"
import "modules/wallpaperPicker"
import "modules/overview"
import "modules/launcher"
import "modules/clipboard"
import "modules/fileManager"
import "modules/screenshot"

ShellRoot {
    id: root

    IpcHandler {
        target: "shell"

        function toggleOverview(): void {
            ShellState.toggleOverview()
        }

        function openOverview(): void {
            ShellState.openOverview()
        }

        function closeOverview(): void {
            ShellState.closeOverview()
        }

        function showPowerProfileOsd(): void {
            ShellState.showPowerProfileOsd()
        }
    }

    IpcHandler {
        target: "dnd"

        function toggle(): void {
            ShellState.toggleDoNotDisturb()
        }

        function enable(): void {
            ShellState.enableDoNotDisturb()
        }

        function disable(): void {
            ShellState.disableDoNotDisturb()
        }
    }

    Timer {
        id: startupWallpaperRestoreTimer

        interval: 900
        running: true
        repeat: false

        onTriggered: {
            Quickshell.execDetached([
                "qs",
                "ipc",
                "call",
                "wallpaperPicker",
                "restore"
            ])
        }
    }

    TopBar {}

    PowerMenu {
        id: powerMenu
    }

    VolumeOSD {}
    BrightnessOSD {}
    LockOSD {}
    PowerProfileOSD {}
    ScreenshotOSD {}

    NotificationPopup {}
    NotificationCenter {}
    WallpaperPicker {}


    AppLauncher {}
    ClipboardPicker {}
    FileManager {}

    WorkspaceOverview {}

}
