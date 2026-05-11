pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import "../theme"

Rectangle {
    id: root

    readonly property int itemSize: 24
    readonly property int iconSize: 16
    readonly property int horizontalPadding: 8

    readonly property int itemCount: SystemTray.items.values.length
    readonly property color itemHoverBg: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.10)

    visible: itemCount > 0

    height: Theme.pillHeight
    width: visible ? trayRow.implicitWidth + horizontalPadding * 2 : 0

    radius: Theme.radius
    color: Theme.pillBg

    border.width: 1
    border.color: Theme.border

    Row {
        id: trayRow

        anchors.centerIn: parent
        spacing: 4

        Repeater {
            id: trayRepeater

            model: SystemTray.items

            delegate: MouseArea {
                id: trayItemBox

                required property SystemTrayItem modelData

                width: root.itemSize
                height: root.itemSize

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                function openMenu() {
                    if (!modelData.hasMenu)
                        return

                    trayMenu.open()
                }

                Rectangle {
                    anchors.fill: parent
                    radius: root.itemSize / 2
                    color: trayItemBox.containsMouse || trayMenu.visible
                        ? root.itemHoverBg
                        : "transparent"
                }

                IconImage {
                    id: trayIcon

                    anchors.centerIn: parent

                    width: root.iconSize
                    height: root.iconSize

                    source: trayItemBox.modelData.icon
                    asynchronous: true
                    mipmap: true
                }

                QsMenuAnchor {
                    id: trayMenu

                    menu: trayItemBox.modelData.menu

                    anchor {
                        item: trayItemBox
                        edges: Edges.Bottom | Edges.Left
                        gravity: Edges.Bottom | Edges.Right
                    }
                }

                onClicked: function(mouse) {
                    mouse.accepted = true

                    if (mouse.button === Qt.RightButton) {
                        openMenu()
                        return
                    }

                    if (mouse.button === Qt.LeftButton) {
                        if (modelData.onlyMenu) {
                            openMenu()
                            return
                        }

                        modelData.activate()
                        return
                    }

                    if (mouse.button === Qt.MiddleButton)
                        modelData.secondaryActivate()
                }

                onWheel: function(wheel) {
                    const xDelta = wheel.angleDelta.x
                    const yDelta = wheel.angleDelta.y
                    const horizontal = Math.abs(xDelta) > Math.abs(yDelta)
                    const delta = horizontal ? xDelta : yDelta

                    if (delta === 0)
                        return

                    modelData.scroll(delta / 120, horizontal)
                    wheel.accepted = true
                }
            }
        }
    }
}
