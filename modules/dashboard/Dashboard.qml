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

    property bool opened: false
    property bool animating: false
    property bool addOpen: false

    readonly property int panelWidth: 430
    readonly property int panelHeight: 610
    readonly property int addPopupWidth: 430
    readonly property int gapFromBar: 6
    readonly property int leftMargin: Theme.margin

    implicitWidth: anchorWindow ? anchorWindow.width : panelWidth
    implicitHeight: panelHeight + 40

    visible: opened || animating
    color: "transparent"

    anchor.window: anchorWindow
    anchor.rect.x: 0
    anchor.rect.y: Theme.barHeight + gapFromBar
    anchor.rect.width: anchorWindow ? anchorWindow.width : panelWidth
    anchor.rect.height: panelHeight

    grabFocus: false

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: root.opened
    }

    function filteredItems() {
        return dashboardState.filteredItems(DashboardData.items)
    }

    function centeredAddPopupX() {
        return Math.round((root.implicitWidth - root.addPopupWidth) / 2)
    }

    function toggleDashboard() {
        root.animating = true
        root.opened = !root.opened
        root.addOpen = false

        DashboardData.load()

        if (root.visible)
            root.anchor.updateAnchor()

        animationStopper.restart()
    }

    function openDashboard() {
        root.animating = true
        root.opened = true

        DashboardData.load()

        if (root.visible)
            root.anchor.updateAnchor()

        animationStopper.restart()
    }

    function closeDashboard() {
        root.animating = true
        root.opened = false
        root.addOpen = false

        animationStopper.restart()
    }

    Timer {
        id: animationStopper

        interval: Animations.slow
        repeat: false

        onTriggered: {
            root.animating = false
        }
    }

    DashboardState {
        id: dashboardState
    }

    DashboardActions {
        id: dashboardActions
    }

    PopupPanel {
        id: panel

        opened: root.opened

        x: root.leftMargin

        width: root.panelWidth
        height: root.panelHeight

        openY: 0
        closedY: -height - 24

        panelRadius: 30
        animationDuration: Animations.panel

        panelColor: Theme.pillBg
        panelBorderColor: WalTheme.border

        Column {
            id: contentColumn

            anchors.fill: parent
            anchors.margins: 20

            spacing: 14

            DashboardHeader {
                width: parent.width
                addOpen: root.addOpen

                onAddClicked: {
                    root.addOpen = !root.addOpen

                    if (root.addOpen)
                        addPopup.focusTitle()
                }
            }

            Divider {
                width: parent.width
            }

            DashboardTabs {
                width: parent.width
                activeCategory: dashboardState.activeCategory

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
                height: parent.height - 146

                activeCategory: dashboardState.activeCategory
                items: root.filteredItems()

                onRemoveRequested: function(itemId) {
                    dashboardActions.removeItem(itemId)
                }
            }
        }
    }

    DashboardAddPopup {
        id: addPopup

        opened: root.addOpen

        x: root.centeredAddPopupX()

        activeCategory: dashboardState.addCategory
        defaultType: dashboardState.defaultType

        onCancelRequested: {
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

            root.addOpen = false
        }
    }

    IpcHandler {
        target: "dashboard"

        function toggle() {
            root.toggleDashboard()
        }

        function open() {
            root.openDashboard()
        }

        function close() {
            root.closeDashboard()
        }
    }
}