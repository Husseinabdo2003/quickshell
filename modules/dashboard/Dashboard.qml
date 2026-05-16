import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "../../components"
import "../../services"
import "../../theme"

PopupWindow {
    id: root

    property var anchorWindow
    property var attachItem

    property bool addOpen: false
    property bool windowAlive: false

    readonly property int panelWidth: 430
    readonly property int panelHeight: 610
    readonly property int addPopupWidth: 430
    readonly property int gapFromBar: 6
    readonly property int leftMargin: Theme.margin

    readonly property int openDuration: 240
    readonly property int closeDuration: 220

    readonly property int openY: 0
    readonly property int closedY: -panelHeight - 34

    implicitWidth: anchorWindow ? anchorWindow.width : panelWidth
    implicitHeight: panelHeight + 60

    visible: root.windowAlive
    color: "transparent"

    anchor.window: anchorWindow
    anchor.rect.x: 0
    anchor.rect.y: Theme.barHeight + gapFromBar
    anchor.rect.width: anchorWindow ? anchorWindow.width : panelWidth
    anchor.rect.height: panelHeight + 60

    grabFocus: false

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: ShellState.dashboardOpen

        onCleared: {
            if (ShellState.dashboardOpen)
                ShellState.closeDashboard()
        }
    }

    DashboardState {
        id: dashboardState
    }

    DashboardActions {
        id: dashboardActions

        onAddFinished: {
            addPopup.clearAfterAdd()
            root.addOpen = false
        }

        onRemoveFinished: {
        }

        onAddFailed: function(exitCode) {
            console.log("Dashboard add failed:", exitCode)
        }

        onRemoveFailed: function(exitCode) {
            console.log("Dashboard remove failed:", exitCode)
        }
    }

    IpcHandler {
        target: "dashboard"

        function toggle(): void {
            ShellState.toggleDashboard()
        }

        function open(): void {
            ShellState.openDashboard()
        }

        function close(): void {
            ShellState.closeDashboard()
        }

        function reload(): void {
            DashboardData.load()
        }
    }

    Connections {
        target: ShellState

        function onDashboardOpenChanged() {
            if (ShellState.dashboardOpen)
                root.openDashboardAnimation()
            else
                root.closeDashboardAnimation()
        }
    }

    function safeUpdateAnchor() {
        try {
            if (root.visible && root.anchor && root.anchor.updateAnchor)
                root.anchor.updateAnchor()
        } catch (error) {
            console.log("Dashboard anchor update failed:", error)
        }
    }

    function openDashboardAnimation() {
        closeHideTimer.stop()

        root.windowAlive = true
        root.addOpen = false

        DashboardData.load()
        root.safeUpdateAnchor()

        panel.y = root.closedY
        panel.opacity = 0.0
        panel.scale = 0.985

        slideAnimation.stop()
        opacityAnimation.stop()
        scaleAnimation.stop()

        slideAnimation.duration = root.openDuration
        slideAnimation.to = root.openY

        opacityAnimation.duration = 120
        opacityAnimation.to = 1.0

        scaleAnimation.duration = root.openDuration
        scaleAnimation.to = 1.0

        slideAnimation.start()
        opacityAnimation.start()
        scaleAnimation.start()
    }

    function closeDashboardAnimation() {
        root.addOpen = false

        slideAnimation.stop()
        opacityAnimation.stop()
        scaleAnimation.stop()

        slideAnimation.duration = root.closeDuration
        slideAnimation.to = root.closedY

        opacityAnimation.duration = root.closeDuration
        opacityAnimation.to = 0.0

        scaleAnimation.duration = root.closeDuration
        scaleAnimation.to = 0.985

        slideAnimation.start()
        opacityAnimation.start()
        scaleAnimation.start()

        closeHideTimer.restart()
    }

    function filteredItems() {
        return dashboardState.filteredItems(DashboardData.items)
    }

    function centeredAddPopupX() {
        return Math.max(
            0,
            Math.round((root.implicitWidth - root.addPopupWidth) / 2)
        )
    }

    Timer {
        id: closeHideTimer

        interval: root.closeDuration + 40
        repeat: false

        onTriggered: {
            if (!ShellState.dashboardOpen)
                root.windowAlive = false
        }
    }

    Card {
        id: panel

        x: root.leftMargin
        y: root.closedY

        width: root.panelWidth
        height: root.panelHeight

        cardRadius: 30
        cardColor: Theme.pillBg
        cardBorderColor: WalTheme.border

        opacity: 0
        scale: 0.985

        enabled: ShellState.dashboardOpen

        layer.enabled: true
        layer.smooth: true

        NumberAnimation {
            id: slideAnimation

            target: panel
            property: "y"

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
            id: contentColumn

            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            DashboardHeader {
                width: parent.width
                addOpen: root.addOpen
                busy: dashboardActions.busy

                onAddClicked: {
                    if (dashboardActions.busy)
                        return

                    root.addOpen = !root.addOpen

                    if (root.addOpen) {
                        Qt.callLater(function() {
                            addPopup.focusTitle()
                        })
                    }
                }
            }

            Divider {
                width: parent.width
            }

            DashboardTabs {
                width: parent.width
                activeCategory: dashboardState.activeCategory
                enabled: !dashboardActions.busy

                onCategorySelected: function(category) {
                    dashboardState.activeCategory = category
                }
            }

            DashboardCategoryHeader {
                width: parent.width

                title: dashboardState.categoryTitle
                itemCount: root.filteredItems().length
            }

            DashboardList {
                id: dashboardList

                width: parent.width
                height: Math.max(0, parent.height - 146)

                activeCategory: dashboardState.activeCategory
                items: root.filteredItems()
                busy: dashboardActions.busy

                onRemoveRequested: function(itemId) {
                    dashboardActions.removeItem(itemId)
                }
            }
        }
    }

    DashboardAddPopup {
        id: addPopup

        opened: root.addOpen && ShellState.dashboardOpen

        x: root.centeredAddPopupX()

        activeCategory: dashboardState.addCategory
        defaultType: dashboardState.defaultType
        busy: dashboardActions.busy

        onCancelRequested: {
            if (!dashboardActions.busy)
                root.addOpen = false
        }

        onAddRequested: function(type, title, course, date, priority, status) {
            dashboardActions.addItem(
                dashboardState.addCategory,
                type,
                title,
                course,
                date,
                priority,
                status
            )
        }
    }

    Component.onCompleted: {
        panel.y = root.closedY
        panel.opacity = 0.0
        panel.scale = 0.985
    }
}