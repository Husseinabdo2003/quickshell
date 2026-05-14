pragma Singleton

import QtQuick

QtObject {
    id: root

    property bool powerMenuOpen: false
    property bool controlCenterOpen: false
    property bool notificationCenterOpen: false

    property bool launcherOpen: false
    property bool dashboardOpen: false
    property bool wallpaperPickerOpen: false
    property bool clipboardOpen: false

    property bool volumeOsdOpen: false
    property bool brightnessOsdOpen: false
    property bool lockOsdOpen: false
    property bool powerProfileOsdOpen: false

    property bool overviewOpen: false

    property string draggedWindowAddress: ""
    property string draggedWindowTitle: ""
    property string draggedWindowWorkspace: ""

    property real dragGlobalX: -1
    property real dragGlobalY: -1
    property bool dragReleaseRequested: false

    function closeAllPopups() {
        powerMenuOpen = false
        controlCenterOpen = false
        notificationCenterOpen = false

        launcherOpen = false
        dashboardOpen = false
        wallpaperPickerOpen = false
        clipboardOpen = false

        overviewOpen = false
        clearDraggedWindow()
    }

    function closePanelPopups() {
        powerMenuOpen = false
        controlCenterOpen = false
        notificationCenterOpen = false

        launcherOpen = false
        dashboardOpen = false
        wallpaperPickerOpen = false
        clipboardOpen = false

        overviewOpen = false
        clearDraggedWindow()
    }

    function openLauncher() {
        closePanelPopups()
        launcherOpen = true
    }

    function closeLauncher() {
        launcherOpen = false
    }

    function toggleLauncher() {
        if (launcherOpen)
            closeLauncher()
        else
            openLauncher()
    }

    function openDashboard() {
        closePanelPopups()
        dashboardOpen = true
    }

    function closeDashboard() {
        dashboardOpen = false
    }

    function toggleDashboard() {
        if (dashboardOpen)
            closeDashboard()
        else
            openDashboard()
    }

    function openPowerMenu() {
        closePanelPopups()
        powerMenuOpen = true
    }

    function closePowerMenu() {
        powerMenuOpen = false
    }

    function togglePowerMenu() {
        if (powerMenuOpen)
            closePowerMenu()
        else
            openPowerMenu()
    }

    function openNotificationCenter() {
        closePanelPopups()
        notificationCenterOpen = true
    }

    function closeNotificationCenter() {
        notificationCenterOpen = false
    }

    function toggleNotificationCenter() {
        if (notificationCenterOpen)
            closeNotificationCenter()
        else
            openNotificationCenter()
    }

    function openWallpaperPicker() {
        closePanelPopups()
        wallpaperPickerOpen = true
    }

    function closeWallpaperPicker() {
        wallpaperPickerOpen = false
    }

    function toggleWallpaperPicker() {
        if (wallpaperPickerOpen)
            closeWallpaperPicker()
        else
            openWallpaperPicker()
    }

    function openClipboard() {
        closePanelPopups()
        clipboardOpen = true
    }

    function closeClipboard() {
        clipboardOpen = false
    }

    function toggleClipboard() {
        if (clipboardOpen)
            closeClipboard()
        else
            openClipboard()
    }

    function openOverview() {
        closePanelPopups()
        overviewOpen = true
    }

    function closeOverview() {
        overviewOpen = false
        clearDraggedWindow()
    }

    function toggleOverview() {
        if (overviewOpen)
            closeOverview()
        else
            openOverview()
    }

    function showPowerProfileOsd() {
        powerProfileOsdOpen = false
        powerProfileOsdOpen = true
    }

    function hidePowerProfileOsd() {
        powerProfileOsdOpen = false
    }

    function setDraggedWindow(address, title, workspaceName) {
        draggedWindowAddress = address || ""
        draggedWindowTitle = title || ""
        draggedWindowWorkspace = workspaceName || ""
        dragReleaseRequested = false
    }

    function updateDragPosition(x, y) {
        dragGlobalX = x
        dragGlobalY = y
    }

    function requestDragRelease() {
        dragReleaseRequested = true
    }

    function clearDraggedWindow() {
        draggedWindowAddress = ""
        draggedWindowTitle = ""
        draggedWindowWorkspace = ""
        dragGlobalX = -1
        dragGlobalY = -1
        dragReleaseRequested = false
    }
}