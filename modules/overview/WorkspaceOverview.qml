pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

import "../../components"
import "../../theme"
import "../../services"

Scope {
    id: root

    PanelWindow {
        id: overviewWindow

        visible: ShellState.overviewOpen

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        exclusiveZone: 0
        focusable: true

        property int columns: 5

        property int panelMaxWidth: 1508
        property real panelWidthRatio: 0.82

        property int backgroundPadding: 10
        property int workspaceSpacing: 7

        property int headerHeight: 23
        property int specialRowTopGap: 0

        property int panelRadius: 12

        property int panelWidth: Math.min(
            panelMaxWidth,
            Math.round(overviewWindow.width * panelWidthRatio)
        )

        property int contentWidth: panelWidth - backgroundPadding * 2

        property int tileWidth: Math.floor(
            (contentWidth - workspaceSpacing * (columns - 1)) / columns
        )

        property int tileHeight: Math.round(tileWidth * 0.55)

        property int panelHeight: backgroundPadding * 2
            + tileHeight
            + workspaceSpacing
            + headerHeight
            + specialRowTopGap
            + tileHeight

        function alpha(color, opacity) {
            return Qt.rgba(color.r, color.g, color.b, opacity)
        }

        function workspaceByName(name) {
            return Hyprland.workspaces.values.find(ws =>
                String(ws.name) === String(name)
            ) || null
        }

        function normalWorkspaceNames() {
            const names = ["1", "2", "3", "4", "5"]

            Hyprland.workspaces.values
                .filter(ws => !String(ws.name).startsWith("special"))
                .sort((a, b) => Number(a.id) - Number(b.id))
                .forEach(ws => {
                    const name = String(ws.name)

                    if (!names.includes(name))
                        names.push(name)
                })

            return names.slice(0, columns)
        }

        function specialWorkspaceNames() {
            const names = OverviewConfig.pinnedSpecialWorkspaces.slice()

            Hyprland.workspaces.values
                .filter(ws => String(ws.name).startsWith("special"))
                .map(ws => String(ws.name))
                .forEach(name => {
                    if (!names.includes(name))
                        names.push(name)
                })

            return names.slice(0, columns)
        }

        function specialWorkspaceLabel(name) {
            return OverviewConfig.specialWorkspaceLabel(String(name))
        }

        function windowsForWorkspaceName(workspaceName) {
            return Hyprland.toplevels.values.filter(w =>
                w && w.workspace && String(w.workspace.name) === String(workspaceName)
            )
        }

        Rectangle {
            anchors.fill: parent

            color: Qt.rgba(0, 0, 0, 0.34)

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    ShellState.closeOverview()
                }
            }
        }

        Card {
            id: panel

            width: overviewWindow.panelWidth
            height: overviewWindow.panelHeight

            anchors.centerIn: parent

            cardRadius: overviewWindow.panelRadius
            cardColor: Qt.rgba(0.018, 0.055, 0.052, 0.88)
            cardBorderColor: overviewWindow.alpha(WalTheme.border, 0.86)

            opacity: ShellState.overviewOpen ? 1 : 0
            scale: ShellState.overviewOpen ? 1 : 0.975

            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.popupFade
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Animations.normal
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }

            Column {
                anchors.fill: parent
                anchors.margins: overviewWindow.backgroundPadding

                spacing: overviewWindow.workspaceSpacing

                Row {
                    width: overviewWindow.contentWidth
                    height: overviewWindow.tileHeight
                    spacing: overviewWindow.workspaceSpacing

                    Repeater {
                        model: overviewWindow.normalWorkspaceNames()

                        WorkspacePreview {
                            required property var modelData

                            previewWidth: overviewWindow.tileWidth
                            previewHeight: overviewWindow.tileHeight

                            workspaceName: String(modelData)
                            displayName: overviewWindow.specialWorkspaceLabel(modelData)
                            workspace: overviewWindow.workspaceByName(modelData)
                            windows: overviewWindow.windowsForWorkspaceName(modelData)
                        }
                    }
                }

                Card {
                    width: overviewWindow.contentWidth
                    height: overviewWindow.headerHeight

                    cardRadius: 3
                    cardColor: Qt.rgba(0.03, 0.11, 0.10, 0.62)
                    cardBorderColor: overviewWindow.alpha(WalTheme.border, 0.74)

                    TitleText {
                        anchors {
                            left: parent.left
                            leftMargin: 9
                            verticalCenter: parent.verticalCenter
                        }

                        text: "Special Workspaces"
                        font.pixelSize: Theme.fontSize
                    }
                }

                Item {
                    width: overviewWindow.contentWidth
                    height: overviewWindow.specialRowTopGap
                    visible: height > 0
                }

                Row {
                    width: overviewWindow.contentWidth
                    height: overviewWindow.tileHeight
                    spacing: overviewWindow.workspaceSpacing

                    Repeater {
                        model: overviewWindow.specialWorkspaceNames()

                        WorkspacePreview {
                            required property var modelData

                            previewWidth: overviewWindow.tileWidth
                            previewHeight: overviewWindow.tileHeight

                            workspaceName: String(modelData)
                            workspace: overviewWindow.workspaceByName(modelData)
                            windows: overviewWindow.windowsForWorkspaceName(modelData)
                        }
                    }
                }
            }
        }
    }
}