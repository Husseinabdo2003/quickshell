import QtQuick

import "../../components"
import "../../theme"

Rectangle {
    id: root

    property int sidebarWidth: 188
    property string currentDir: ""
    property var places: []
    property var devices: []

    signal pathRequested(string path, string kind)
    signal deviceMountRequested(string blockPath)
    signal deviceUnmountRequested(string blockPath)

    width: sidebarWidth

    color: "transparent"

    function normalized(path) {
        return String(path || "").replace(/\/+$/, "")
    }

    function pathMatches(path) {
        return root.normalized(path) === root.normalized(root.currentDir)
    }

    Column {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Column {
            width: parent.width
            spacing: 6

            MetaText {
                width: parent.width

                text: "Favorites"
                font.pixelSize: 11
                opacity: 0.65
            }

            Repeater {
                model: root.places

                Rectangle {
                    width: parent.width
                    height: 30
                    radius: 7

                    readonly property bool activePlace: modelData.path.length > 0
                        && root.pathMatches(modelData.path)
                    readonly property string placeKind: String(modelData.kind || "folder")

                    color: activePlace
                        ? WalTheme.accentAlpha
                        : placeMouse.containsMouse
                            ? Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.06)
                            : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 9
                        anchors.rightMargin: 9
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            width: 18

                            text: modelData.icon
                            color: activePlace ? WalTheme.accent : WalTheme.fgMuted

                            font.family: Theme.iconFontFamily
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            width: parent.width - 26

                            text: modelData.label
                            color: WalTheme.fg

                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: activePlace

                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: placeMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: modelData.path.length > 0
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                        onClicked: {
                            if (modelData.path.length > 0)
                                root.pathRequested(modelData.path, placeKind)
                        }
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 6
            visible: root.devices.length > 0

            MetaText {
                width: parent.width

                text: "Devices"
                font.pixelSize: 11
                opacity: 0.65
            }

            Repeater {
                model: root.devices

                Rectangle {
                    width: parent.width
                    height: 30
                    radius: 7

                    readonly property bool mounted: Boolean(modelData.mounted)
                    readonly property bool canUnmount: Boolean(modelData.canUnmount)
                    readonly property string blockPath: String(modelData.blockPath || "")
                    readonly property bool activePlace: modelData.path.length > 0
                        && root.pathMatches(modelData.path)

                    color: activePlace
                        ? WalTheme.accentAlpha
                        : deviceMouse.containsMouse
                            ? Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.06)
                            : "transparent"

                    Row {
                        z: 2

                        anchors.fill: parent
                        anchors.leftMargin: 9
                        anchors.rightMargin: 9
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            width: 18

                            text: modelData.icon
                            color: activePlace ? WalTheme.accent : WalTheme.fgMuted

                            font.family: Theme.iconFontFamily
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            width: parent.width - 54

                            text: modelData.label
                            color: WalTheme.fg

                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            font.bold: activePlace

                            elide: Text.ElideRight
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            width: 20

                            text: mounted
                                ? canUnmount ? "⏏" : ""
                                : ""
                            color: deviceActionMouse.containsMouse
                                ? WalTheme.accent
                                : WalTheme.fgMuted

                            font.family: mounted ? Theme.fontFamily : Theme.iconFontFamily
                            font.pixelSize: mounted ? 13 : 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter

                            MouseArea {
                                id: deviceActionMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: mounted && !canUnmount
                                    ? Qt.ArrowCursor
                                    : Qt.PointingHandCursor

                                onClicked: function(mouse) {
                                    mouse.accepted = true

                                    if (mounted && canUnmount) {
                                        root.deviceUnmountRequested(blockPath)
                                        return
                                    }

                                    if (!mounted)
                                        root.deviceMountRequested(blockPath)
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: deviceMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: modelData.path.length > 0 || !mounted
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                        onClicked: {
                            if (modelData.path.length > 0) {
                                root.pathRequested(modelData.path, "folder")
                                return
                            }

                            if (!mounted)
                                root.deviceMountRequested(blockPath)
                        }
                    }
                }
            }
        }
    }
}
