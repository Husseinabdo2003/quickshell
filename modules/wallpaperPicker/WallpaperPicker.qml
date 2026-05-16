import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "../../components"
import "../../theme"
import "../../services"

PanelWindow {
    id: root

    property bool pickerVisible: false

    property string selectedPath: ""
    property string selectedName: ""
    property string selectedUrl: ""
    property string currentWallpaperPath: ""

    property string searchText: ""

    visible: root.pickerVisible

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true

    color: "transparent"

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: ShellState.wallpaperPickerOpen

        onCleared: {
            if (ShellState.wallpaperPickerOpen)
                root.closePicker()
        }
    }

    IpcHandler {
        target: "wallpaperPicker"

        function toggle(): void {
            ShellState.toggleWallpaperPicker()
        }

        function open(): void {
            ShellState.openWallpaperPicker()
        }

        function close(): void {
            ShellState.closeWallpaperPicker()
        }

        function restore(): void {
            wallpaperActions.restoreWallpaper()
        }
    }

    Connections {
        target: ShellState

        function onWallpaperPickerOpenChanged() {
            if (ShellState.wallpaperPickerOpen)
                root.openPickerAnimation()
            else
                root.closePickerAnimation()
        }
    }

    Timer {
        id: closeTimer

        interval: Animations.slow
        repeat: false

        onTriggered: {
            if (!ShellState.wallpaperPickerOpen)
                root.pickerVisible = false
        }
    }

    Timer {
        id: focusTimer

        interval: Animations.instant
        repeat: false

        onTriggered: {
            searchBox.forceInputFocus()
        }
    }

    WallpaperActions {
        id: wallpaperActions

        onCurrentWallpaperRead: function(path) {
            root.currentWallpaperPath = path
        }

        onWallpaperFound: function(path, name, url) {
            wallpapersModel.append({
                path: path,
                name: name,
                url: url
            })

            if (root.selectedPath.length === 0)
                root.selectWallpaper(path, name, url)
        }

        onWallpaperApplied: function(path) {
            root.currentWallpaperPath = path
            root.closePicker()
        }

        onWallpaperRestored: function(path) {
            root.currentWallpaperPath = path
            root.closePicker()
        }

        onWallpaperApplyFailed: function(path) {
            console.log("Wallpaper apply failed:", path)
        }

        onWallpaperRestoreFailed: function(path) {
            console.log("Wallpaper restore failed:", path)
        }
    }

    function openPickerAnimation() {
        closeTimer.stop()

        root.pickerVisible = true
        root.searchText = ""

        root.reloadWallpapers()
        wallpaperActions.readCurrentWallpaper()

        focusTimer.restart()

        Qt.callLater(function() {
            panel.forceActiveFocus()
        })
    }

    function closePickerAnimation() {
        closeTimer.restart()
    }

    function openPicker() {
        ShellState.openWallpaperPicker()
    }

    function closePicker() {
        ShellState.closeWallpaperPicker()
    }

    function reloadWallpapers() {
        wallpapersModel.clear()

        root.selectedPath = ""
        root.selectedName = ""
        root.selectedUrl = ""

        wallpaperActions.listWallpapers()
    }

    function selectWallpaper(path, name, url) {
        root.selectedPath = String(path || "")
        root.selectedName = String(name || "")
        root.selectedUrl = String(url || "")
    }

    function applyWallpaperPath(path, name, url) {
        const cleanPath = String(path || "")

        if (cleanPath.length === 0)
            return

        if (wallpaperActions.applying)
            return

        root.selectWallpaper(cleanPath, name, url)
        wallpaperActions.applyWallpaper(cleanPath)
    }

    ListModel {
        id: wallpapersModel
    }

    PopupBackdrop {
        opened: ShellState.wallpaperPickerOpen
        dimOpacity: 0.48
        animationDuration: Animations.popupFade

        onClicked: {
            if (!wallpaperActions.applying)
                root.closePicker()
        }
    }

    Card {
        id: panel

        width: Math.max(360, Math.min(parent.width - 80, 1060))
        height: 360

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18

        focus: true

        cardRadius: 24
        cardColor: Theme.pillBg
        cardBorderColor: wallpaperActions.applying
            ? WalTheme.accent
            : WalTheme.border

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (!wallpaperActions.applying)
                    root.closePicker()

                event.accepted = true
                return
            }
        }

        transform: Translate {
            y: ShellState.wallpaperPickerOpen ? 0 : panel.height + 40

            Behavior on y {
                NumberAnimation {
                    duration: Animations.slow
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
        }

        Column {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 16

            WallpaperHeader {
                width: parent.width
                imageCount: wallpapersModel.count
                applying: wallpaperActions.applying

                onCloseRequested: {
                    if (!wallpaperActions.applying)
                        root.closePicker()
                }
            }

            SearchBox {
                id: searchBox

                width: parent.width

                text: root.searchText
                placeholder: "Search wallpapers ..."

                enabled: !wallpaperActions.applying
                opacity: wallpaperActions.applying ? 0.55 : 1.0

                onTextChanged: {
                    root.searchText = text
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Escape) {
                        if (!wallpaperActions.applying)
                            root.closePicker()

                        event.accepted = true
                        return
                    }
                }
            }

            WallpaperList {
                width: parent.width
                height: parent.height - 112

                model: wallpapersModel
                searchText: root.searchText
                currentWallpaperPath: root.currentWallpaperPath
                selectedPath: root.selectedPath
                applying: wallpaperActions.applying

                onHovered: function(path, name, url) {
                    if (!wallpaperActions.applying)
                        root.selectWallpaper(path, name, url)
                }

                onChosen: function(path, name, url) {
                    root.applyWallpaperPath(path, name, url)
                }
            }
        }
    }
}