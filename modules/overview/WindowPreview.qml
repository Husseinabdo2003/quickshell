import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland

import "../../components"
import "../../theme"
import "../../services"

Card {
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

    readonly property bool canScreencopy: root.hasWindow
        && ShellState.overviewOpen
        && root.captureHandle !== null
        && root.captureHandle !== undefined
        && root.width > 2
        && root.height > 2

    cardRadius: 3
    cardColor: Qt.rgba(0, 0, 0, 0.30)

    cardBorderWidth: hasWindow && (window.urgent || window.activated) ? 1 : 0
    cardBorderColor: hasWindow && window.urgent
        ? WalTheme.accent
        : hasWindow && window.activated
            ? WalTheme.accent
            : Qt.rgba(0, 0, 0, 0.38)

    opacity: isDragging ? 0.76 : 1
    scale: isDragging ? 0.96 : 1
    z: isDragging ? 100 : 2

    Behavior on scale {
        NumberAnimation {
            duration: Animations.fast
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
        live: root.canScreencopy
        paintCursor: false
        visible: root.canScreencopy && thumbnail.hasContent
        constraintSize: Qt.size(
            Math.max(1, Math.round(root.width)),
            Math.max(1, Math.round(root.height))
        )
    }

    Card {
        anchors.fill: parent

        visible: !root.canScreencopy || !thumbnail.hasContent

        cardRadius: root.cardRadius
        cardColor: Qt.rgba(0, 0, 0, 0.22)
        cardBorderWidth: 0

        Card {
            width: Math.max(24, Math.min(parent.width, parent.height) * 0.42)
            height: width

            anchors.centerIn: parent

            cardRadius: Math.round(width / 3)
            cardColor: alpha(WalTheme.accent, 0.16)
            cardBorderColor: alpha(WalTheme.accent, 0.34)

            HeadingText {
                anchors.centerIn: parent

                text: root.appName.length > 0
                    ? root.appName.charAt(0).toUpperCase()
                    : "W"

                font.pixelSize: Math.max(
                    18,
                    Math.min(parent.width, parent.height) * 0.28
                )
            }
        }
    }

    Rectangle {
        anchors.fill: parent

        color: root.hasWindow && window.activated
            ? alpha(WalTheme.accent, 0.06)
            : "transparent"

        radius: root.cardRadius
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

            ShellState.setDraggedWindow(
                address,
                root.windowTitle,
                root.workspaceName
            )

            ShellState.updateDragPosition(globalPos.x, globalPos.y)
        }

        onPositionChanged: function(mouse) {
            if (!root.hasWindow)
                return

            const globalPos = root.mapToGlobal(mouse.x, mouse.y)
            ShellState.updateDragPosition(globalPos.x, globalPos.y)

            if (
                Math.abs(mouse.x - startX) > 8
                || Math.abs(mouse.y - startY) > 8
            ) {
                moved = true
            }
        }

        onReleased: function(mouse) {
            if (!root.hasWindow)
                return

            const globalPos = root.mapToGlobal(mouse.x, mouse.y)
            ShellState.updateDragPosition(globalPos.x, globalPos.y)

            if (mouse.button === Qt.MiddleButton) {
                Hyprland.dispatch(
                    "closewindow address:"
                    + root.normalizedAddress(root.window.address)
                )

                ShellState.clearDraggedWindow()
                root.x = 0
                root.y = 0
                return
            }

            if (!moved) {
                if (
                    root.window.workspace
                    && String(root.window.workspace.name).startsWith("special")
                ) {
                    const specialName = String(root.window.workspace.name).replace(
                        "special:",
                        ""
                    )

                    Hyprland.dispatch("togglespecialworkspace " + specialName)
                    ShellState.closeOverview()
                    root.x = 0
                    root.y = 0
                    return
                }

                Hyprland.dispatch(
                    "focuswindow address:"
                    + root.normalizedAddress(root.window.address)
                )

                ShellState.closeOverview()
                root.x = 0
                root.y = 0
                return
            }

            ShellState.requestDragRelease()

            root.x = 0
            root.y = 0
        }
    }
}