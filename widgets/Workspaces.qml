import QtQuick
import Quickshell
import Quickshell.Hyprland

import "../components"
import "../theme"

BarPill {
    id: root

    horizontalPadding: 8
    minPillWidth: workspacesRow.implicitWidth + horizontalPadding * 2

    label: ""

    function workspaceName(workspace) {
        return String(workspace.name || "")
    }

    function isSpecial(workspace) {
        return root.workspaceName(workspace).startsWith("special:")
    }

    function specialName(workspace) {
        const name = root.workspaceName(workspace)

        if (!name.startsWith("special:"))
            return ""

        return name.replace("special:", "")
    }

    function displayName(workspace) {
        const name = root.workspaceName(workspace)

        if (name === "special:music")
            return ""

        if (name === "special:terminal")
            return ""

        if (name === "special:notes")
            return "󰎞"

        if (name.startsWith("special:"))
            return "󰊠"

        return name
    }

    function workspaceWidth(workspace, textWidth) {
        if (root.isSpecial(workspace))
            return 32

        return Math.max(textWidth + 16, 26)
    }

    function activateWorkspace(workspace) {
        if (root.isSpecial(workspace)) {
            const name = root.specialName(workspace)

            if (name.length > 0) {
                Quickshell.execDetached([
                    "hyprctl",
                    "dispatch",
                    "togglespecialworkspace",
                    name
                ])
            }

            return
        }

        workspace.activate()
    }

    Row {
        id: workspacesRow

        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: Hyprland.workspaces.values

            Rectangle {
                id: workspaceButton

                required property var modelData

                width: root.workspaceWidth(modelData, workspaceText.implicitWidth)
                height: Theme.pillHeight - 8

                radius: Theme.radius

                color: modelData.urgent
                    ? WalTheme.urgent
                    : modelData.focused
                        ? WalTheme.accent
                        : mouseArea.containsMouse
                            ? Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.08)
                            : "transparent"

                border.width: root.isSpecial(modelData) ? 1 : 0
                border.color: root.isSpecial(modelData)
                    ? modelData.focused
                        ? WalTheme.fg
                        : WalTheme.border
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

                Text {
                    id: workspaceText

                    anchors.centerIn: parent

                    text: root.displayName(modelData)
                    color: WalTheme.fg

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: root.isSpecial(modelData) ? 13 : Theme.fontSize
                    font.bold: modelData.focused
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.activateWorkspace(modelData)
                    }
                }
            }
        }
    }
}