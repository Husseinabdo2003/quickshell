pragma Singleton
import QtQuick

QtObject {
    property bool powerMenuOpen: false
    property bool controlCenterOpen: false
    property bool notificationCenterOpen: false

    property bool volumeOsdOpen: false
    property bool brightnessOsdOpen: false
    property bool lockOsdOpen: false

    property bool overviewOpen: false

    property string draggedWindowAddress: ""
    property string draggedWindowTitle: ""
    property string draggedWindowWorkspace: ""

    property real dragGlobalX: -1
    property real dragGlobalY: -1
    property bool dragReleaseRequested: false

    function openOverview() {
        overviewOpen = true
    }

    function closeOverview() {
        overviewOpen = false
        clearDraggedWindow()
    }

    function toggleOverview() {
        overviewOpen = !overviewOpen

        if (!overviewOpen) {
            clearDraggedWindow()
        }
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