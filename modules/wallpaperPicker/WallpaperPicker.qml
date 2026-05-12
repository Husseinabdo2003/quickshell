import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "../../components"
import "../../theme"

PanelWindow {
    id: root

    property bool pickerVisible: false
    property bool pickerOpen: false

    property string selectedPath: ""
    property string selectedName: ""
    property string selectedUrl: ""
    property string currentWallpaperPath: ""

    property string searchText: ""

    visible: pickerVisible

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
        active: root.pickerOpen

        onCleared: {
            root.closePicker()
        }
    }

    IpcHandler {
        target: "wallpaperPicker"

        function toggle() {
            if (root.pickerOpen)
                root.closePicker()
            else
                root.openPicker()
        }

        function open() {
            root.openPicker()
        }

        function close() {
            root.closePicker()
        }

        function restore() {
            wallpaperActions.restoreWallpaper()
        }
    }

    Timer {
        id: closeTimer

        interval: Animations.slow
        repeat: false

        onTriggered: {
            if (!root.pickerOpen)
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

    function openPicker() {
        closeTimer.stop()

        root.pickerVisible = true
        root.pickerOpen = true
        root.searchText = ""

        root.reloadWallpapers()
        wallpaperActions.readCurrentWallpaper()

        focusTimer.restart()
    }

    function closePicker() {
        root.pickerOpen = false
        closeTimer.restart()
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

    Rectangle {
        anchors.fill: parent

        color: Qt.rgba(0, 0, 0, root.pickerOpen ? 0.48 : 0)

        Behavior on color {
            ColorAnimation {
                duration: Animations.popupFade
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.closePicker()
            }
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
            y: root.pickerOpen ? 0 : panel.height + 40

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