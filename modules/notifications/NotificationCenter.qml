import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

import "../../theme"
import "../../services"
import "../../components"

PanelWindow {
    id: root

    property bool windowAlive: false

    readonly property int panelWidth: 372
    readonly property int openDuration: 220
    readonly property int closeDuration: 200

    readonly property int openX: 0
    readonly property int closedX: panelWidth + 32

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
    focusable: true

    implicitWidth: root.panelWidth
    color: "transparent"

    visible: root.windowAlive

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: ShellState.notificationCenterOpen

        onCleared: {
            if (ShellState.notificationCenterOpen)
                ShellState.closeNotificationCenter()
        }
    }

    IpcHandler {
        target: "notificationCenter"

        function toggle(): void {
            ShellState.toggleNotificationCenter()
        }

        function open(): void {
            ShellState.openNotificationCenter()
        }

        function close(): void {
            ShellState.closeNotificationCenter()
        }

        function clear(): void {
            NotificationService.clearAll()
        }
    }

    Connections {
        target: ShellState

        function onNotificationCenterOpenChanged() {
            if (ShellState.notificationCenterOpen)
                root.openCenterAnimation()
            else
                root.closeCenterAnimation()
        }
    }

    function safeRebuildGroups() {
        try {
            if (NotificationService.rebuildGroups)
                NotificationService.rebuildGroups()
        } catch (error) {
            console.log("Notification center rebuild failed:", error)
        }
    }

    function openCenterAnimation() {
        closeHideTimer.stop()

        root.windowAlive = true
        root.safeRebuildGroups()

        panel.x = root.closedX
        panel.opacity = 0.0
        panel.scale = 0.985

        slideAnimation.stop()
        opacityAnimation.stop()
        scaleAnimation.stop()

        slideAnimation.duration = root.openDuration
        slideAnimation.to = root.openX

        opacityAnimation.duration = 120
        opacityAnimation.to = 1.0

        scaleAnimation.duration = root.openDuration
        scaleAnimation.to = 1.0

        slideAnimation.start()
        opacityAnimation.start()
        scaleAnimation.start()

        Qt.callLater(function() {
            panel.forceActiveFocus()
        })
    }

    function closeCenterAnimation() {
        slideAnimation.stop()
        opacityAnimation.stop()
        scaleAnimation.stop()

        slideAnimation.duration = root.closeDuration
        slideAnimation.to = root.closedX

        opacityAnimation.duration = root.closeDuration
        opacityAnimation.to = 0.0

        scaleAnimation.duration = root.closeDuration
        scaleAnimation.to = 0.985

        slideAnimation.start()
        opacityAnimation.start()
        scaleAnimation.start()

        closeHideTimer.restart()
    }

    Timer {
        id: closeHideTimer

        interval: root.closeDuration + 40
        repeat: false

        onTriggered: {
            if (!ShellState.notificationCenterOpen)
                root.windowAlive = false
        }
    }

    Card {
        id: panel

        anchors.top: parent.top
        anchors.bottom: parent.bottom

        width: root.panelWidth

        x: root.closedX
        opacity: 0.0
        scale: 0.985

        enabled: ShellState.notificationCenterOpen
        focus: true

        cardRadius: 30
        cardColor: Theme.pillBg
        cardBorderColor: WalTheme.border
        cardBorderWidth: 1

        layer.enabled: true
        layer.smooth: true

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                ShellState.closeNotificationCenter()
                event.accepted = true
                return
            }
        }

        NumberAnimation {
            id: slideAnimation

            target: panel
            property: "x"

            duration: root.openDuration
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            id: opacityAnimation

            target: panel
            property: "opacity"

            duration: 120
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            id: scaleAnimation

            target: panel
            property: "scale"

            duration: root.openDuration
            easing.type: Easing.OutCubic
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
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
                    width: Math.max(
                        0,
                        parent.width - titleText.implicitWidth - clearButton.width
                    )

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

                    enabled: NotificationService.appGroups.length > 0
                    opacity: enabled ? 1.0 : 0.45

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
                height: Math.max(0, parent.height - 60)

                contentHeight: groupsColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick

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

    Component.onCompleted: {
        root.windowAlive = ShellState.notificationCenterOpen

        panel.x = ShellState.notificationCenterOpen
            ? root.openX
            : root.closedX

        panel.opacity = ShellState.notificationCenterOpen ? 1.0 : 0.0
        panel.scale = ShellState.notificationCenterOpen ? 1.0 : 0.985
    }
}