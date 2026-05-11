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
    }

    TopBar {}

    PowerMenu {
        id: powerMenu
    }

    VolumeOSD {}
    BrightnessOSD {}
    LockOSD {}

    NotificationPopup {}
    NotificationCenter {}
    WallpaperPicker {}

    WorkspaceOverview {}

}
