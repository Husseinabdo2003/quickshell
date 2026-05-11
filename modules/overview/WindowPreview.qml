import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland

import "../../theme"
import "../../services"

Rectangle {
    id: root

    property var window: null

    property bool hasWindow: window !== null && window !== undefined

    property string appName: {
        if (!hasWindow)
            return "Window"

        if (window.appId && String(window.appId).length > 0)
            return String(window.appId)

        if (window.class && String(window.class).length > 0)
            return String(window.class)

        if (window.initialClass && String(window.initialClass).length > 0)
            return String(window.initialClass)

        return "Window"
    }

    property string windowTitle: {
        if (!hasWindow)
            return "Untitled"

        return window.title && String(window.title).length > 0
            ? String(window.title)
            : "Untitled"
    }

    property string workspaceName: {
        if (!hasWindow || !window.workspace)
            return ""

        return String(window.workspace.name)
    }

    property bool isDragging: dragArea.drag.active

    property var captureHandle: {
        if (!hasWindow)
            return null

        if (window.wayland)
            return window.wayland

        if (window.handle)
            return window.handle

        return null
    }

    radius: 3
    color: Qt.rgba(0, 0, 0, 0.30)
    clip: true

    border.width: hasWindow && (window.urgent || window.activated) ? 1 : 0
    border.color: hasWindow && window.urgent
        ? Theme.accent
        : hasWindow && window.activated
            ? Theme.accent
            : Qt.rgba(0, 0, 0, 0.38)

    opacity: isDragging ? 0.76 : 1
    scale: isDragging ? 0.96 : 1
    z: isDragging ? 100 : 2

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    function alpha(color, opacity) {
        return Qt.rgba(color.r, color.g, color.b, opacity)
    }

    function normalizedAddress(address) {
        const raw = String(address || "")

        if (raw.length === 0)
            return ""

        if (raw.startsWith("0x"))
            return raw

        return "0x" + raw
    }

    ScreencopyView {
        id: thumbnail

        anchors.fill: parent
        anchors.margins: 1

        captureSource: root.captureHandle
        live: root.hasWindow && ShellState.overviewOpen
        paintCursor: false
        visible: root.hasWindow && thumbnail.hasContent
        constraintSize: Qt.size(root.width, root.height)
    }

    Rectangle {
        anchors.fill: parent
        visible: !root.hasWindow || !thumbnail.hasContent

        color: Qt.rgba(0, 0, 0, 0.22)

        Rectangle {
            width: Math.min(parent.width, parent.height) * 0.42
            height: width
            radius: width / 3

            anchors.centerIn: parent

            color: alpha(Theme.accent, 0.16)

            border.width: 1
            border.color: alpha(Theme.accent, 0.34)

            Text {
                anchors.centerIn: parent

                text: root.appName.length > 0
                    ? root.appName.charAt(0).toUpperCase()
                    : "W"

                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Math.max(28, Math.min(parent.width, parent.height) * 0.28)
                font.bold: true
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.hasWindow && window.activated
            ? alpha(Theme.accent, 0.06)
            : "transparent"
        radius: root.radius
    }

    MouseArea {
        id: dragArea

        anchors.fill: parent
        enabled: root.hasWindow
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        drag.target: root
        drag.axis: Drag.XAndYAxis
        drag.threshold: 8

        property bool moved: false
        property real startX: 0
        property real startY: 0

        onPressed: function(mouse) {
            if (!root.hasWindow)
                return

            moved = false
            startX = mouse.x
            startY = mouse.y

            const globalPos = root.mapToGlobal(mouse.x, mouse.y)
            const address = root.normalizedAddress(root.window.address)

            ShellState.setDraggedWindow(address, root.windowTitle, root.workspaceName)
            ShellState.updateDragPosition(globalPos.x, globalPos.y)
        }

        onPositionChanged: function(mouse) {
            if (!root.hasWindow)
                return

            const globalPos = root.mapToGlobal(mouse.x, mouse.y)
            ShellState.updateDragPosition(globalPos.x, globalPos.y)

            if (Math.abs(mouse.x - startX) > 8 || Math.abs(mouse.y - startY) > 8) {
                moved = true
            }
        }

        onReleased: function(mouse) {
            if (!root.hasWindow)
                return

            const globalPos = root.mapToGlobal(mouse.x, mouse.y)
            ShellState.updateDragPosition(globalPos.x, globalPos.y)

            if (mouse.button === Qt.MiddleButton) {
                Hyprland.dispatch("closewindow address:" + root.normalizedAddress(root.window.address))
                ShellState.clearDraggedWindow()
                root.x = 0
                root.y = 0
                return
            }

            if (!moved) {
                if (root.window.workspace && String(root.window.workspace.name).startsWith("special")) {
                    const specialName = String(root.window.workspace.name).replace("special:", "")
                    Hyprland.dispatch("togglespecialworkspace " + specialName)
                    ShellState.closeOverview()
                    root.x = 0
                    root.y = 0
                    return
                } else if (root.window.workspace) {
                    Hyprland.dispatch("workspace " + root.window.workspace.name)
                }

                Hyprland.dispatch("focuswindow address:" + root.normalizedAddress(root.window.address))
                ShellState.closeOverview()
            } else {
                ShellState.requestDragRelease()
            }

            root.x = 0
            root.y = 0
        }

        onCanceled: {
            ShellState.clearDraggedWindow()
            root.x = 0
            root.y = 0
        }
    }
}
