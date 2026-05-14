import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

import "../../components"
import "../../theme"
import "../../services"

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true

    color: "transparent"
    visible: ShellState.launcherOpen

    readonly property int launcherWidth: 620
    readonly property int launcherHeight: 560

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: ShellState.launcherOpen

        onCleared: {
            if (ShellState.launcherOpen)
                ShellState.closeLauncher()
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            ShellState.toggleLauncher()
        }

        function open(): void {
            ShellState.openLauncher()
        }

        function close(): void {
            ShellState.closeLauncher()
        }
    }

    LauncherState {
        id: launcherState
    }

    Timer {
        id: focusTimer

        interval: Animations.instant
        repeat: false

        onTriggered: {
            searchBox.forceInputFocus()
        }
    }

    Connections {
        target: ShellState

        function onLauncherOpenChanged() {
            if (ShellState.launcherOpen) {
                launcherState.reset()
                focusTimer.restart()
            }
        }
    }

    function closeLauncher() {
        ShellState.closeLauncher()
    }

    function launchApp(app) {
        if (!app)
            return

        root.closeLauncher()

        try {
            app.execute()
        } catch (error) {
            if (app.command && app.command.length > 0)
                Quickshell.execDetached(app.command)
        }
    }

    function launchSelected() {
        if (launcherState.filteredApps.length === 0)
            return

        root.launchApp(launcherState.filteredApps[launcherState.selectedIndex])
    }

    function updateListPosition() {
        Qt.callLater(function() {
            launcherList.ensureSelectedVisible()
        })
    }

    PopupBackdrop {
        opened: ShellState.launcherOpen
        dimOpacity: 0.58
        animationDuration: Animations.popupFade

        onClicked: {
            root.closeLauncher()
        }
    }

    AnimatedPopupCard {
        id: panel

        width: root.launcherWidth
        height: root.launcherHeight

        anchors.centerIn: parent

        opened: ShellState.launcherOpen

        openedScale: 1.0
        closedScale: 0.94

        openDuration: Animations.popupFade
        closeDuration: Animations.popupFade

        popupRadius: 34
        popupColor: Theme.pillBg
        popupBorderColor: WalTheme.border

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
        }

        Rectangle {
            anchors.fill: parent
            radius: panel.cardRadius

            color: Qt.rgba(0, 0, 0, 0.22)
            border.width: 0
        }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            LauncherHeader {
                width: parent.width
                resultCount: launcherState.filteredApps.length

                onCloseRequested: {
                    root.closeLauncher()
                }
            }

            SearchBox {
                id: searchBox

                width: parent.width
                height: 50

                placeholder: "Search apps, tools, settings..."

                text: launcherState.query

                onTextChanged: {
                    launcherState.query = text
                    launcherState.selectedIndex = 0
                    launcherState.updateFilteredApps()
                    root.updateListPosition()
                }

                onAccepted: {
                    root.launchSelected()
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Escape) {
                        root.closeLauncher()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Down) {
                        launcherState.moveDown()
                        root.updateListPosition()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Up) {
                        launcherState.moveUp()
                        root.updateListPosition()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.launchSelected()
                        event.accepted = true
                        return
                    }
                }
            }

            LauncherCategories {
                width: parent.width

                activeCategory: launcherState.activeCategory

                onCategorySelected: function(category) {
                    launcherState.setCategory(category)
                    searchBox.forceInputFocus()
                    root.updateListPosition()
                }
            }

            LauncherList {
                id: launcherList

                width: parent.width
                height: parent.height - 140

                apps: launcherState.filteredApps
                selectedIndex: launcherState.selectedIndex

                onAppClicked: function(app) {
                    root.launchApp(app)
                }
            }
        }
    }
}