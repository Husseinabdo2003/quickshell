import QtQuick
import Quickshell.Hyprland

import "../theme"

Rectangle {
    id: root

    height: Theme.pillHeight
    width: workspacesRow.implicitWidth + 16

    radius: Theme.radius
    color: Theme.pillBg

    border.width: 1
    border.color: Theme.border

    Row {
        id: workspacesRow

        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: Hyprland.workspaces.values

            Rectangle {
                id: workspaceButton

                required property var modelData

                width: Math.max(workspaceText.implicitWidth + 16, 26)
                height: Theme.pillHeight - 8

                radius: Theme.radius
                color: modelData.urgent ? Theme.urgent
                     : modelData.focused ? Theme.accent
                     : "transparent"

                Text {
                    id: workspaceText

                    anchors.centerIn: parent

                    text: modelData.name
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: modelData.focused
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        modelData.activate()
                    }
                }
            }
        }
    }
}