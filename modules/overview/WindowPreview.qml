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

    property bool dragStarted: false
    property bool moved: false

    property real startX: 0
    property real startY: 0

    readonly property int minimumPreviewWidth: 24
    readonly property int minimumPreviewHeight: 18

    property string appName: root.safeAppName()
    property string windowTitle: root.safeTitle()
    property string workspaceName: root.safeWorkspaceName()

    property var captureHandle: root.safeCaptureHandle()

    readonly property bool canScreencopy: root.hasWindow
        && ShellState.overviewOpen
        && root.captureHandle !== null
        && root.captureHandle !== undefined
        && root.width >= root.minimumPreviewWidth
        && root.height >= root.minimumPreviewHeight
        && thumbnailHost.width >= root.minimumPreviewWidth
        && thumbnailHost.height >= root.minimumPreviewHeight
        && !root.dragStarted

    cardRadius: 3
    cardColor: Qt.rgba(0, 0, 0, 0.30)

    cardBorderWidth: root.isUrgent() || root.isActivated() ? 1 : 0

    cardBorderColor: root.isUrgent()
        ? WalTheme.accent
        : root.isActivated()
            ? WalTheme.accent
            : Qt.rgba(0, 0, 0, 0.38)

    opacity: root.dragStarted ? 0.76 : 1
    scale: root.dragStarted ? 0.96 : 1
    z: root.dragStarted ? 100 : 2

    Behavior on scale {
        NumberAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    function alpha(color, opacity) {
        return Qt.rgba(color.r, color.g, color.b, opacity)
    }

    function clean(value) {
        try {
            return String(value || "").trim()
        } catch (error) {
            return ""
        }
    }

    function normalizedAddress(address) {
        const raw = root.clean(address)

        if (raw.length === 0)
            return ""

        if (raw.startsWith("0x"))
            return raw

        return "0x" + raw
    }

    function safeValue(key) {
        if (!root.hasWindow)
            return ""

        try {
            const value = root.window[key]

            if (value === undefined || value === null)
                return ""

            return root.clean(value)
        } catch (error) {
            return ""
        }
    }

    function safeAppName() {
        const appId = root.safeValue("appId")

        if (appId.length > 0)
            return appId

        const className = root.safeValue("class")

        if (className.length > 0)
            return className

        const initialClass = root.safeValue("initialClass")

        if (initialClass.length > 0)
            return initialClass

        return "Window"
    }

    function safeTitle() {
        const title = root.safeValue("title")

        if (title.length > 0)
            return title

        return "Untitled"
    }

    function safeWorkspaceName() {
        if (!root.hasWindow)
            return ""

        try {
            if (root.window.workspace && root.window.workspace.name)
                return root.clean(root.window.workspace.name)
        } catch (error) {
        }

        return ""
    }

    function safeAddress() {
        if (!root.hasWindow)
            return ""

        return root.normalizedAddress(root.safeValue("address"))
    }

    function safeCaptureHandle() {
        if (!root.hasWindow)
            return null

        try {
            if (root.window.wayland)
                return root.window.wayland
        } catch (error) {
        }

        try {
            if (root.window.handle)
                return root.window.handle
        } catch (error) {
        }

        return null
    }

    function isUrgent() {
        if (!root.hasWindow)
            return false

        try {
            return Boolean(root.window.urgent)
        } catch (error) {
            return false
        }
    }

    function isActivated() {
        if (!root.hasWindow)
            return false

        try {
            return Boolean(root.window.activated)
        } catch (error) {
            return false
        }
    }

    function startDragIfNeeded(mouse) {
        if (root.dragStarted || !root.hasWindow)
            return

        const dx = mouse.x - root.startX
        const dy = mouse.y - root.startY
        const distance = Math.sqrt(dx * dx + dy * dy)

        if (distance < 8)
            return

        const address = root.safeAddress()

        if (address.length === 0)
            return

        root.dragStarted = true
        root.moved = true

        const globalPos = root.mapToGlobal(mouse.x, mouse.y)

        ShellState.setDraggedWindow(
            address,
            root.windowTitle,
            root.workspaceName
        )

        ShellState.updateDragPosition(globalPos.x, globalPos.y)
    }

    Item {
        id: thumbnailHost

        anchors.fill: parent
        anchors.margins: 1

        clip: true

        Loader {
            id: thumbnailLoader

            anchors.fill: parent

            active: root.canScreencopy

            sourceComponent: ScreencopyView {
                id: thumbnail

                width: Math.max(root.minimumPreviewWidth, thumbnailHost.width)
                height: Math.max(root.minimumPreviewHeight, thumbnailHost.height)

                captureSource: root.captureHandle
                live: root.canScreencopy

                paintCursor: false

                constraintSize: Qt.size(
                    Math.max(root.minimumPreviewWidth, Math.round(thumbnailHost.width)),
                    Math.max(root.minimumPreviewHeight, Math.round(thumbnailHost.height))
                )
            }
        }
    }

    Card {
        anchors.fill: parent

        visible: !root.canScreencopy || !thumbnailLoader.active

        cardRadius: root.cardRadius
        cardColor: Qt.rgba(0, 0, 0, 0.22)
        cardBorderWidth: 0

        Card {
            width: Math.max(24, Math.min(parent.width, parent.height) * 0.42)
            height: width

            anchors.centerIn: parent

            cardRadius: Math.round(width / 3)
            cardColor: root.alpha(WalTheme.accent, 0.16)
            cardBorderColor: root.alpha(WalTheme.accent, 0.34)

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

        color: root.isActivated()
            ? root.alpha(WalTheme.accent, 0.06)
            : "transparent"

        radius: root.cardRadius
    }

    MouseArea {
        id: dragArea

        anchors.fill: parent

        enabled: root.hasWindow
        cursorShape: root.dragStarted ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        property bool wasPressed: false

        onPressed: function(mouse) {
            if (!root.hasWindow)
                return

            root.moved = false
            root.dragStarted = false

            startX = mouse.x
            startY = mouse.y

            wasPressed = true

            mouse.accepted = true
        }

        onPositionChanged: function(mouse) {
            if (!root.hasWindow || !wasPressed)
                return

            if (mouse.buttons & Qt.LeftButton) {
                root.startDragIfNeeded(mouse)

                if (root.dragStarted) {
                    const globalPos = root.mapToGlobal(mouse.x, mouse.y)
                    ShellState.updateDragPosition(globalPos.x, globalPos.y)
                }

                mouse.accepted = true
            }
        }

        onReleased: function(mouse) {
            if (!root.hasWindow)
                return

            wasPressed = false

            const address = root.safeAddress()

            if (root.dragStarted) {
                const globalPos = root.mapToGlobal(mouse.x, mouse.y)
                ShellState.updateDragPosition(globalPos.x, globalPos.y)
                ShellState.requestDragRelease()

                root.dragStarted = false
                root.moved = false

                root.x = 0
                root.y = 0

                mouse.accepted = true
                return
            }

            if (mouse.button === Qt.MiddleButton) {
                if (address.length > 0) {
                    Hyprland.dispatch(
                        "closewindow address:" + address
                    )
                }

                ShellState.clearDraggedWindow()

                root.x = 0
                root.y = 0

                mouse.accepted = true
                return
            }

            if (mouse.button === Qt.LeftButton) {
                if (
                    root.workspaceName.length > 0
                    && root.workspaceName.startsWith("special")
                ) {
                    const specialName = root.workspaceName.replace(
                        "special:",
                        ""
                    )

                    Hyprland.dispatch("togglespecialworkspace " + specialName)
                    ShellState.closeOverview()

                    root.x = 0
                    root.y = 0

                    mouse.accepted = true
                    return
                }

                if (address.length > 0) {
                    Hyprland.dispatch(
                        "focuswindow address:" + address
                    )

                    ShellState.closeOverview()
                }

                root.x = 0
                root.y = 0

                mouse.accepted = true
                return
            }
        }

        onCanceled: {
            wasPressed = false
            root.dragStarted = false
            root.moved = false

            ShellState.clearDraggedWindow()

            root.x = 0
            root.y = 0
        }
    }
}