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

    color: "transparent"

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: ShellState.wallpaperPickerOpen

        onCleared: {
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
        }

        onWallpaperRestored: function(path) {
            root.currentWallpaperPath = path
        }
    }

    function openPickerAnimation() {
        closeTimer.stop()

        root.pickerVisible = true
        root.searchText = ""

        root.reloadWallpapers()
        wallpaperActions.readCurrentWallpaper()

        focusTimer.restart()
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
        root.selectedPath = path
        root.selectedName = name
        root.selectedUrl = url
    }

    function applyWallpaperPath(path, name, url) {
        if (path.length === 0)
            return

        root.selectWallpaper(path, name, url)
        wallpaperActions.applyWallpaper(path)

        root.currentWallpaperPath = path
        root.closePicker()
    }

    ListModel {
        id: wallpapersModel
    }

    PopupBackdrop {
        opened: ShellState.wallpaperPickerOpen
        dimOpacity: 0.48
        animationDuration: Animations.popupFade

        onClicked: {
            root.closePicker()
        }
    }

    Card {
        id: panel

        width: Math.min(parent.width - 80, 1060)
        height: 360

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18

        cardRadius: 24
        cardColor: Theme.pillBg
        cardBorderColor: WalTheme.border

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

                onCloseRequested: {
                    root.closePicker()
                }
            }

            SearchBox {
                id: searchBox

                width: parent.width

                text: root.searchText
                placeholder: "Search wallpapers ..."

                onTextChanged: {
                    root.searchText = text
                }
            }

            WallpaperList {
                width: parent.width
                height: parent.height - 112

                model: wallpapersModel
                searchText: root.searchText
                currentWallpaperPath: root.currentWallpaperPath
                selectedPath: root.selectedPath

                onHovered: function(path, name, url) {
                    root.selectWallpaper(path, name, url)
                }

                onChosen: function(path, name, url) {
                    root.applyWallpaperPath(path, name, url)
                }
            }
        }
    }
}