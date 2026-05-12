pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import "../components"
import "../theme"

BarPill {
    id: root

    readonly property int itemSize: 24
    readonly property int iconSize: 16
    readonly property int trayPadding: 8
    readonly property int itemSpacing: 4

    readonly property int trayCount: SystemTray.items.values.length

    visible: trayCount > 0

    label: ""
    horizontalPadding: trayPadding

    minPillWidth: visible
        ? trayRow.implicitWidth + trayPadding * 2
        : 0

    Row {
        id: trayRow

        anchors.centerIn: parent
        spacing: root.itemSpacing

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayItem

                required property SystemTrayItem modelData

                width: root.itemSize
                height: root.itemSize

                Rectangle {
                    id: hoverBg

                    anchors.fill: parent
                    radius: root.itemSize / 2

                    color: mouseArea.containsMouse || trayMenu.visible
                        ? Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.075)
                        : "transparent"

                    border.width: trayMenu.visible ? 1 : 0
                    border.color: trayMenu.visible
                        ? WalTheme.accent
                        : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                IconImage {
                    id: trayIcon

                    anchors.centerIn: parent

                    width: root.iconSize
                    height: root.iconSize

                    source: trayItem.modelData.icon
                    asynchronous: true
                    mipmap: true

                    opacity: trayItem.modelData.status === Status.Passive
                        ? 0.55
                        : 1.0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                QsMenuAnchor {
                    id: trayMenu

                    menu: trayItem.modelData.menu

                    anchor {
                        item: trayItem
                        edges: Edges.Bottom | Edges.Left
                        gravity: Edges.Bottom | Edges.Right
                    }
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    function openMenu() {
                        if (!trayItem.modelData.hasMenu)
                            return

                        trayMenu.open()
                    }

                    onClicked: function(mouse) {
                        mouse.accepted = true

                        if (mouse.button === Qt.RightButton) {
                            openMenu()
                            return
                        }

                        if (mouse.button === Qt.MiddleButton) {
                            trayItem.modelData.secondaryActivate()
                            return
                        }

                        if (mouse.button === Qt.LeftButton) {
                            if (trayItem.modelData.onlyMenu) {
                                openMenu()
                                return
                            }

                            trayItem.modelData.activate()
                        }
                    }

                    onWheel: function(wheel) {
                        const xDelta = wheel.angleDelta.x
                        const yDelta = wheel.angleDelta.y

                        const horizontal = Math.abs(xDelta) > Math.abs(yDelta)
                        const delta = horizontal ? xDelta : yDelta

                        if (delta === 0)
                            return

                        trayItem.modelData.scroll(delta / 120, horizontal)
                        wheel.accepted = true
                    }
                }
            }
        }
    }
}