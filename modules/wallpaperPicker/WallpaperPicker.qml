import QtQuick
import Quickshell
import Quickshell.Io

import "../../theme"

PanelWindow {
    id: root

    property bool pickerVisible: false
    property bool pickerOpen: false

    property string wallpaperDir: "/home/hussein/Pictures/Wallpapers"
    property string applyScript: "/home/hussein/.config/hypr/scripts/wallpaper-picker.lua"
    property string currentWallpaperCache: "/home/hussein/.cache/current-wallpaper"

    property string selectedPath: ""
    property string selectedName: ""
    property string selectedUrl: ""
    property string currentWallpaperPath: ""

    property string searchText: ""

    property color panelBg: Theme.pillBg
    property color cardBg: Qt.rgba(0, 0, 0, 0.22)
    property color softBg: Qt.rgba(255, 255, 255, 0.06)
    property color softHover: Qt.rgba(255, 255, 255, 0.10)
    property color textColor: Theme.text
    property color mutedColor: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.62)
    property color borderColor: Theme.border
    property color accentColor: Theme.accent

    visible: pickerVisible

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"

    IpcHandler {
        target: "wallpaperPicker"

        function toggle() {
            if (root.pickerOpen) {
                root.closePicker()
            } else {
                root.openPicker()
            }
        }

        function open() {
            root.openPicker()
        }

        function close() {
            root.closePicker()
        }
    }

    Timer {
        id: closeTimer
        interval: 260
        repeat: false

        onTriggered: {
            if (!root.pickerOpen) {
                root.pickerVisible = false
            }
        }
    }

    function openPicker() {
        closeTimer.stop()
        root.pickerVisible = true
        root.pickerOpen = true
        root.searchText = ""
        root.reloadWallpapers()
        readCurrentWallpaper.exec(["bash", "-lc", "cat '" + root.currentWallpaperCache + "' 2>/dev/null || true"])
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

        listWallpapers.exec([
            "bash",
            "-lc",
            "find '" + root.wallpaperDir + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"
        ])
    }

    function selectWallpaper(path, name, url) {
        root.selectedPath = path
        root.selectedName = name
        root.selectedUrl = url
    }

    function applySelectedWallpaper() {
        if (root.selectedPath.length === 0)
            return

        applyWallpaper.exec([
            root.applyScript,
            root.selectedPath
        ])

        root.currentWallpaperPath = root.selectedPath
        root.closePicker()
    }

    function matchesSearch(name) {
        if (root.searchText.length === 0)
            return true

        return name.toLowerCase().indexOf(root.searchText.toLowerCase()) !== -1
    }

    ListModel {
        id: wallpapersModel
    }

    Process {
        id: readCurrentWallpaper

        stdout: SplitParser {
            onRead: function(data) {
                if (!data)
                    return

                root.currentWallpaperPath = data.trim()
            }
        }
    }

    Process {
        id: listWallpapers

        stdout: SplitParser {
            onRead: function(data) {
                if (!data)
                    return

                const lines = data.trim().split("\n")

                for (let i = 0; i < lines.length; i++) {
                    const path = lines[i].trim()

                    if (path.length === 0)
                        continue

                    const parts = path.split("/")
                    const name = parts[parts.length - 1]
                    const url = "file://" + path

                    wallpapersModel.append({
                        path: path,
                        name: name,
                        url: url
                    })

                    if (root.selectedPath.length === 0) {
                        root.selectWallpaper(path, name, url)
                    }
                }
            }
        }
    }

    Process {
        id: applyWallpaper
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, root.pickerOpen ? 0.48 : 0)

        Behavior on color {
            ColorAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.closePicker()
        }
    }

    Rectangle {
        id: panel

        width: Math.min(parent.width - 80, 1060)
        height: 360

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18

        radius: 24
        color: root.panelBg
        border.width: 1
        border.color: root.borderColor
        clip: true

        transform: Translate {
            y: root.pickerOpen ? 0 : panel.height + 40

            Behavior on y {
                NumberAnimation {
                    duration: 260
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

            Row {
                width: parent.width
                height: 32
                spacing: 12

                Text {
                    id: titleText
                    text: "󰸉  Wallpapers"
                    color: root.textColor
                    font.pixelSize: 20
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: parent.width - titleText.implicitWidth - countPill.width - closeButton.implicitWidth - 48
                    height: 1
                }

                Rectangle {
                    id: countPill

                    width: countText.implicitWidth + 22
                    height: 28
                    radius: 999
                    color: root.softBg
                    border.width: 1
                    border.color: root.borderColor
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: wallpapersModel.count + " images"
                        color: root.mutedColor
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Text {
                    id: closeButton

                    text: "×"
                    color: root.textColor
                    font.pixelSize: 28
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closePicker()
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 52
                radius: 14
                color: root.softBg
                border.width: 1
                border.color: searchInput.activeFocus ? root.accentColor : root.borderColor

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter

                    visible: searchInput.text.length === 0
                    text: "Search wallpapers ..."
                    color: root.mutedColor
                    font.pixelSize: 14
                    font.bold: true
                }

                TextInput {
                    id: searchInput

                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    verticalAlignment: TextInput.AlignVCenter

                    color: root.textColor
                    selectionColor: root.accentColor
                    selectedTextColor: root.textColor

                    font.pixelSize: 14
                    font.bold: true

                    text: root.searchText
                    onTextChanged: root.searchText = text

                    clip: true
                }
            }

            Flickable {
                id: flick

                width: parent.width
                height: parent.height - 112

                contentWidth: wallpaperRow.implicitWidth
                contentHeight: wallpaperRow.height

                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick
                clip: true

                WheelHandler {
                    target: flick
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

                    onWheel: function(event) {
                        const maxX = Math.max(0, flick.contentWidth - flick.width)
                        const delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.pixelDelta.y

                        if (delta > 0) {
                            flick.contentX = Math.max(0, flick.contentX - 180)
                        } else {
                            flick.contentX = Math.min(maxX, flick.contentX + 180)
                        }

                        event.accepted = true
                    }
                }

                Row {
                    id: wallpaperRow

                    height: flick.height
                    spacing: 20

                    Repeater {
                        model: wallpapersModel

                        Rectangle {
                            id: card

                            required property string path
                            required property string name
                            required property string url

                            property bool shown: root.matchesSearch(card.name)
                            property bool active: root.currentWallpaperPath === card.path
                            property bool selected: root.selectedPath === card.path

                            visible: shown
                            width: shown ? 260 : 0
                            height: 156

                            radius: 14
                            color: root.cardBg
                            border.width: active || selected || mouse.containsMouse ? 2 : 1
                            border.color: active || selected || mouse.containsMouse ? root.accentColor : root.borderColor
                            clip: true

                            scale: mouse.containsMouse ? 1.035 : 1

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 130
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 130
                                }
                            }

                            Image {
                                anchors.fill: parent
                                source: card.url
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                smooth: true
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: mouse.containsMouse
                                    ? Qt.rgba(0, 0, 0, 0.18)
                                    : Qt.rgba(0, 0, 0, 0.30)
                            }

                            Rectangle {
                                visible: card.active

                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 10
                                anchors.rightMargin: 10

                                width: activeText.implicitWidth + 20
                                height: 26
                                radius: 999
                                color: root.accentColor

                                Text {
                                    id: activeText
                                    anchors.centerIn: parent
                                    text: "Active"
                                    color: root.textColor
                                    font.pixelSize: 11
                                    font.bold: true
                                }
                            }

                            Text {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                anchors.bottomMargin: 10

                                text: card.name
                                color: root.textColor
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }

                            MouseArea {
                                id: mouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onEntered: {
                                    root.selectWallpaper(card.path, card.name, card.url)
                                }

                                onClicked: {
                                    root.selectWallpaper(card.path, card.name, card.url)
                                    root.applySelectedWallpaper()
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    visible: flick.contentWidth > flick.width

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2

                    height: 4
                    radius: 999
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.10)

                    Rectangle {
                        height: parent.height
                        radius: 999
                        color: root.accentColor

                        width: flick.contentWidth > 0
                            ? Math.max(80, parent.width * flick.width / flick.contentWidth)
                            : 80

                        x: flick.contentWidth > flick.width
                        ? (parent.width - width) * flick.contentX / (flick.contentWidth - flick.width)
                        : 0

                        Behavior on x {
                            NumberAnimation {
                                duration: 90
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}