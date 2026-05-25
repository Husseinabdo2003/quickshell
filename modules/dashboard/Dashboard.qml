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
    readonly property int popupHeight: anchorWindow && anchorWindow.screen
        ? Math.max(panelHeight + 60, anchorWindow.screen.height - Theme.barHeight - gapFromBar)
        : panelHeight + 60

    readonly property int openDuration: 240
    readonly property int closeDuration: 220

    readonly property int openY: 0
    readonly property int closedY: -panelHeight - 34

    implicitWidth: anchorWindow ? anchorWindow.width : panelWidth
    implicitHeight: popupHeight

    visible: root.windowAlive
    color: "transparent"

    anchor.window: anchorWindow
    anchor.rect.x: 0
    anchor.rect.y: Theme.barHeight + gapFromBar
    anchor.rect.width: anchorWindow ? anchorWindow.width : panelWidth
    anchor.rect.height: popupHeight

    grabFocus: root.addOpen && ShellState.dashboardOpen

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

        onDoneFailed: function(exitCode) {
            console.log("Dashboard done failed:", exitCode)
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

        focusTimer.restart()
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

    function itemCountFor(category) {
        return dashboardState.filteredItemsFor(DashboardData.items, category).length
    }

    function highPriorityCount() {
        return dashboardState.highPriorityItems(DashboardData.items).length
    }

    function centeredAddPopupX() {
        return Math.max(
            0,
            Math.round((root.implicitWidth - root.addPopupWidth) / 2)
        )
    }

    function pointInside(item, x, y) {
        return item.visible
            && x >= item.x
            && x <= item.x + item.width
            && y >= item.y
            && y <= item.y + item.height
    }

    function closeFromOutside() {
        if (dashboardActions.busy)
            return

        ShellState.closeDashboard()
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

    Timer {
        id: focusTimer

        interval: Animations.instant
        repeat: false

        onTriggered: {
            if (!ShellState.dashboardOpen)
                return

            if (root.addOpen)
                addPopup.focusTitle()
            else
                panel.forceActiveFocus()
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
        focus: true

        layer.enabled: true
        layer.smooth: true

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.closeFromOutside()
                event.accepted = true
                return
            }
        }

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
                itemCount: root.itemCountFor("all")
                highPriorityCount: root.highPriorityCount()

                onAddClicked: {
                    if (dashboardActions.busy)
                        return

                    root.addOpen = !root.addOpen

                    if (root.addOpen)
                        focusTimer.restart()
                }
            }

            Divider {
                width: parent.width
            }

            DashboardTabs {
                width: parent.width
                activeCategory: dashboardState.activeCategory
                enabled: !dashboardActions.busy
                allCount: root.itemCountFor("all")
                todoCount: root.itemCountFor("todo")
                projectsCount: root.itemCountFor("projects")
                examsCount: root.itemCountFor("exams")

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
                height: Math.max(0, parent.height - 156)

                activeCategory: dashboardState.activeCategory
                items: root.filteredItems()
                busy: dashboardActions.busy

                onRemoveRequested: function(itemId) {
                    dashboardActions.removeItem(itemId)
                }

                onDoneRequested: function(itemId, done) {
                    dashboardActions.setDone(itemId, done)
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

        onCloseRequested: {
            root.closeFromOutside()
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

    MouseArea {
        anchors.fill: parent
        enabled: ShellState.dashboardOpen
        z: 1000

        onPressed: function(mouse) {
            if (
                root.pointInside(panel, mouse.x, mouse.y)
                || root.pointInside(addPopup, mouse.x, mouse.y)
            ) {
                mouse.accepted = false
                return
            }

            root.closeFromOutside()
            mouse.accepted = true
        }
    }

    Component.onCompleted: {
        panel.y = root.closedY
        panel.opacity = 0.0
        panel.scale = 0.985
    }
}
