//@ pragma UseQApplication

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
            ShellState.powerProfileOsdOpen = false
            ShellState.powerProfileOsdOpen = true
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

    NotificationPopup {}
    NotificationCenter {}
    WallpaperPicker {}

    WorkspaceOverview {}
}