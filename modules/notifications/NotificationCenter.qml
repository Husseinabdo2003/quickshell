import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

import "../../theme"
import "../../services"
import "../../components"

PanelWindow {
    id: root

    property bool animating: false

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: 58
        right: 14
        bottom: 14
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true

    implicitWidth: 372
    color: "transparent"
    visible: ShellState.notificationCenterOpen || root.animating

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: ShellState.notificationCenterOpen

        onCleared: {
            root.closeCenter()
        }
    }

    IpcHandler {
        target: "notificationCenter"

        function toggle(): void {
            root.toggleCenter()
        }

        function open(): void {
            root.openCenter()
        }

        function close(): void {
            root.closeCenter()
        }

        function clear(): void {
            NotificationService.clearAll()
        }
    }

    Timer {
        id: animationStopper

        interval: Animations.panel
        repeat: false

        onTriggered: {
            root.animating = false
        }
    }

    function toggleCenter() {
        if (ShellState.notificationCenterOpen)
            root.closeCenter()
        else
            root.openCenter()
    }

    function openCenter() {
        root.animating = true
        ShellState.notificationCenterOpen = true
        NotificationService.rebuildGroups()
        animationStopper.restart()
    }

    function closeCenter() {
        root.animating = true
        ShellState.notificationCenterOpen = false
        animationStopper.restart()
    }

    Card {
        anchors.fill: parent

        cardRadius: 30
        cardColor: Theme.pillBg
        cardBorderColor: WalTheme.border
        cardBorderWidth: 1

        opacity: ShellState.notificationCenterOpen ? 1 : 0
        x: ShellState.notificationCenterOpen ? 0 : width + 32

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.popupFade
                easing.type: Easing.OutCubic
            }
        }

        Behavior on x {
            NumberAnimation {
                duration: Animations.panel
                easing.type: Easing.OutCubic
            }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Row {
                width: parent.width
                height: 34

                HeadingText {
                    id: titleText

                    anchors.verticalCenter: parent.verticalCenter

                    text: "Notifications"
                    font.pixelSize: 17
                }

                Item {
                    width: parent.width - titleText.implicitWidth - clearButton.width
                    height: 1
                }

                ActionButton {
                    id: clearButton

                    width: 74
                    height: 28

                    text: "Clear all"
                    muted: true
                    buttonRadius: 14
                    fontSize: Theme.fontSize

                    onClicked: {
                        NotificationService.clearAll()
                    }
                }
            }

            Divider {
                width: parent.width
                lineOpacity: 0.45
            }

            MetaText {
                visible: NotificationService.appGroups.length === 0

                anchors.horizontalCenter: parent.horizontalCenter

                text: "No notifications"
                font.pixelSize: Theme.fontSize
                opacity: 0.82
            }

            Flickable {
                id: flick

                width: parent.width
                height: parent.height - 60

                contentHeight: groupsColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: groupsColumn

                    width: parent.width
                    spacing: 14

                    Repeater {
                        model: NotificationService.appGroups

                        NotificationGroupCard {
                            required property var modelData

                            width: groupsColumn.width

                            groupData: modelData
                            expanded: NotificationService.expandedGroupKey === modelData.key

                            onToggleRequested: {
                                NotificationService.toggleGroup(modelData.key)
                            }

                            onClearRequested: {
                                NotificationService.clearGroup(modelData.key)
                            }

                            onDismissRequested: function(notification) {
                                NotificationService.dismiss(notification)
                            }
                        }
                    }
                }
            }
        }
    }
}