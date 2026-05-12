pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland

import "../../components"
import "../../theme"
import "../../services"

Card {
    id: root

    required property string workspaceName
    property var workspace: null
    property var windows: []

    property var validWindows: windows.filter(w => w !== null && w !== undefined)
    property string displayName: root.targetName()

    property bool isSpecial: workspaceName.startsWith("special")
    property bool isFocused: workspace !== null && workspace.focused

    property real previewWidth: 292
    property real previewHeight: 165
    property int contentPadding: 5
    property int tileGap: 5

    property real contentX: contentPadding
    property real contentY: contentPadding
    property real contentWidth: Math.max(1, width - contentPadding * 2)
    property real contentHeight: Math.max(1, height - contentPadding * 2)

    property bool manualDropHover: {
        if (ShellState.draggedWindowAddress.length === 0)
            return false

        const p = root.mapFromGlobal(ShellState.dragGlobalX, ShellState.dragGlobalY)
        return p.x >= 0 && p.x <= root.width && p.y >= 0 && p.y <= root.height
    }

    width: previewWidth
    height: previewHeight

    cardRadius: 4
    cardColor: manualDropHover
        ? alpha(WalTheme.accent, 0.18)
        : isFocused
            ? alpha(WalTheme.accent, 0.11)
            : Qt.rgba(0, 0, 0, 0.24)

    cardBorderWidth: manualDropHover || isFocused ? 2 : 1
    cardBorderColor: manualDropHover
        ? WalTheme.accent
        : isFocused
            ? alpha(WalTheme.accent, 0.80)
            : alpha(WalTheme.border, 0.72)

    function alpha(color, opacity) {
        return Qt.rgba(color.r, color.g, color.b, opacity)
    }

    function targetName() {
        return root.isSpecial
            ? root.workspaceName.replace("special:", "")
            : root.workspaceName
    }

    function normalizedAddress(address) {
        const raw = String(address || "")

        if (raw.length === 0)
            return ""

        if (raw.startsWith("0x"))
            return raw

        return "0x" + raw
    }

    onManualDropHoverChanged: {
        if (
            manualDropHover
            && ShellState.dragReleaseRequested
            && ShellState.draggedWindowAddress.length > 0
        ) {
            moveWindowToWorkspace(ShellState.draggedWindowAddress)
        }
    }

    Connections {
        target: ShellState

        function onDragReleaseRequestedChanged() {
            if (
                ShellState.dragReleaseRequested
                && root.manualDropHover
                && ShellState.draggedWindowAddress.length > 0
            ) {
                root.moveWindowToWorkspace(ShellState.draggedWindowAddress)
            }
        }
    }

    function tileColumns(count) {
        if (count <= 1)
            return 1

        if (count <= 4)
            return 2

        return 3
    }

    function tileRows(count) {
        return Math.ceil(Math.min(count, 6) / tileColumns(count))
    }

    function tileX(index, count) {
        const gap = root.tileGap
        const half = Math.floor((root.contentWidth - gap) / 2)

        if (count <= 1)
            return root.contentX

        if (count === 2)
            return root.contentX + (index === 0 ? 0 : half + gap)

        if (count === 3)
            return root.contentX + (index === 0 ? 0 : half + gap)

        if (count <= 4)
            return root.contentX + (index % 2 === 0 ? 0 : half + gap)

        const column = index % 3
        return root.contentX + column * (tileWidth(index, count) + gap)
    }

    function tileY(index, count) {
        const gap = root.tileGap
        const half = Math.floor((root.contentHeight - gap) / 2)

        if (count <= 2)
            return root.contentY

        if (count === 3)
            return root.contentY + (index < 2 ? 0 : half + gap)

        if (count <= 4)
            return root.contentY + (index < 2 ? 0 : half + gap)

        const row = Math.floor(index / 3)
        return root.contentY + row * (tileHeight(index, count) + gap)
    }

    function tileWidth(index, count) {
        const gap = root.tileGap

        if (count === 1)
            return root.contentWidth

        if (count === 3 && index === 0)
            return Math.floor((root.contentWidth - gap) / 2)

        return Math.floor(
            (root.contentWidth - gap * (tileColumns(count) - 1))
            / tileColumns(count)
        )
    }

    function tileHeight(index, count) {
        const gap = root.tileGap

        if (count <= 2)
            return root.contentHeight

        if (count === 3 && index === 0)
            return root.contentHeight

        return Math.floor(
            (root.contentHeight - gap * (tileRows(count) - 1))
            / tileRows(count)
        )
    }

    function activateWorkspace() {
        if (root.isSpecial) {
            Hyprland.dispatch("togglespecialworkspace " + root.targetName())
        } else {
            Hyprland.dispatch("workspace " + root.workspaceName)
        }

        ShellState.closeOverview()
    }

    function moveWindowToWorkspace(address) {
        const targetAddress = root.normalizedAddress(address)

        if (!targetAddress || targetAddress.length === 0) {
            ShellState.clearDraggedWindow()
            return
        }

        if (root.isSpecial) {
            Hyprland.dispatch(
                "movetoworkspacesilent special:"
                + root.targetName()
                + ",address:"
                + targetAddress
            )
        } else {
            Hyprland.dispatch(
                "movetoworkspacesilent "
                + root.workspaceName
                + ",address:"
                + targetAddress
            )
        }

        ShellState.clearDraggedWindow()
        Hyprland.refreshWorkspaces()
        Hyprland.refreshToplevels()
    }

    MouseArea {
        anchors.fill: parent
        z: 0
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (ShellState.draggedWindowAddress.length === 0)
                root.activateWorkspace()
        }
    }

    Item {
        anchors.fill: parent
        z: 1

        Repeater {
            model: root.validWindows.slice(0, 6)

            Item {
                required property var modelData
                required property int index

                x: root.tileX(index, root.validWindows.length)
                y: root.tileY(index, root.validWindows.length)
                width: root.tileWidth(index, root.validWindows.length)
                height: root.tileHeight(index, root.validWindows.length)

                WindowPreview {
                    width: parent.width
                    height: parent.height
                    window: modelData
                }
            }
        }
    }

    Card {
        visible: root.validWindows.length === 0

        anchors.fill: parent
        anchors.margins: root.contentPadding
        z: 1

        cardRadius: 3
        cardColor: Qt.rgba(0, 0, 0, 0.16)
        cardBorderWidth: 0

        TitleText {
            anchors.centerIn: parent

            text: root.displayName
            muted: true
            font.pixelSize: Theme.fontSize

            opacity: 0.42
        }
    }

    Badge {
        visible: root.validWindows.length > 6
        z: 3

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 7

        text: "+" + (root.validWindows.length - 6)
        muted: false
        accent: false
        badgeHeight: 24
        badgeRadius: 12
        fontSize: Theme.fontSize - 1
        horizontalPadding: 14
    }

    TitleText {
        z: 4

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 7

        visible: root.manualDropHover || root.isFocused

        text: root.displayName
        font.pixelSize: Theme.fontSize - 1

        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.75)
    }
}