import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

import "../../components"
import "../../theme"
import "../../services"

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true

    color: "transparent"
    visible: ShellState.clipboardOpen

    readonly property int pickerWidth: 620
    readonly property int pickerHeight: 540

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: ShellState.clipboardOpen

        onCleared: {
            if (ShellState.clipboardOpen)
                ShellState.closeClipboard()
        }
    }

    IpcHandler {
        target: "clipboard"

        function toggle(): void {
            if (ShellState.clipboardOpen)
                ShellState.closeClipboard()
            else
                root.openCopyMode()
        }

        function open(): void {
            root.openCopyMode()
        }

        function close(): void {
            ShellState.closeClipboard()
        }

        function reload(): void {
            clipboardState.load()
        }

        function deleteMode(): void {
            root.openDeleteMode()
        }

        function copyMode(): void {
            root.openCopyMode()
        }

        function deleteAll(): void {
            clipboardState.deleteAll()
        }
    }

    ClipboardState {
        id: clipboardState
    }

    Timer {
        id: focusTimer

        interval: Animations.instant
        repeat: false

        onTriggered: {
            searchBox.forceInputFocus()
        }
    }

    Connections {
        target: ShellState

        function onClipboardOpenChanged() {
            if (ShellState.clipboardOpen) {
                clipboardState.reset()
                focusTimer.restart()
            }
        }
    }

    function openCopyMode() {
        clipboardState.mode = "copy"

        if (ShellState.clipboardOpen) {
            clipboardState.reset()
            focusTimer.restart()
        } else {
            ShellState.openClipboard()
        }
    }

    function openDeleteMode() {
        clipboardState.mode = "delete"

        if (ShellState.clipboardOpen) {
            clipboardState.reset()
            focusTimer.restart()
        } else {
            ShellState.openClipboard()
        }
    }

    function closePicker() {
        ShellState.closeClipboard()
    }

    function runSelectedAction() {
        clipboardState.runSelectedAction()
    }

    function updateListPosition() {
        Qt.callLater(function() {
            clipboardList.ensureSelectedVisible()
        })
    }

    PopupBackdrop {
        opened: ShellState.clipboardOpen
        dimOpacity: 0.58
        animationDuration: Animations.popupFade

        onClicked: {
            root.closePicker()
        }
    }

    AnimatedPopupCard {
        id: panel

        width: root.pickerWidth
        height: root.pickerHeight

        anchors.centerIn: parent

        opened: ShellState.clipboardOpen

        openedScale: 1.0
        closedScale: 0.94

        openDuration: Animations.popupFade
        closeDuration: Animations.popupFade

        popupRadius: 34
        popupColor: Theme.pillBg
        popupBorderColor: clipboardState.deleteMode
            ? WalTheme.urgent
            : WalTheme.border

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
        }

        Rectangle {
            anchors.fill: parent
            radius: panel.cardRadius

            color: Qt.rgba(0, 0, 0, 0.22)
            border.width: 0
        }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Row {
                width: parent.width
                height: 34
                spacing: 10

                HeadingText {
                    id: titleText

                    anchors.verticalCenter: parent.verticalCenter

                    text: clipboardState.deleteMode
                        ? "Delete Clipboard"
                        : "Clipboard"

                    font.pixelSize: 18
                }

                MetaText {
                    id: shortcutText

                    anchors.verticalCenter: parent.verticalCenter

                    text: clipboardState.deleteMode
                        ? "SUPER + SHIFT + V"
                        : "SUPER + V"

                    font.pixelSize: 11
                    opacity: 0.75
                }

                Item {
                    width: Math.max(
                        0,
                        parent.width
                            - titleText.implicitWidth
                            - shortcutText.implicitWidth
                            - countBadge.width
                            - deleteAllButton.width
                            - modeBadge.width
                            - closeButton.width
                            - parent.spacing * 6
                    )

                    height: 1
                }

                Badge {
                    id: countBadge

                    anchors.verticalCenter: parent.verticalCenter

                    text: clipboardState.filteredItems.length + ""
                    accent: true
                    badgeHeight: 24
                    badgeRadius: 12
                    fontSize: 11
                    horizontalPadding: 12
                }

                ActionButton {
                    id: deleteAllButton

                    visible: clipboardState.deleteMode

                    width: visible ? 82 : 0
                    height: 28

                    text: "Delete all"
                    muted: true
                    buttonRadius: 14
                    fontSize: 11

                    onClicked: {
                        clipboardState.deleteAll()
                    }
                }

                Badge {
                    id: modeBadge

                    anchors.verticalCenter: parent.verticalCenter

                    text: clipboardState.deleteMode ? "Delete" : "Copy"
                    accent: !clipboardState.deleteMode
                    muted: clipboardState.deleteMode
                    badgeHeight: 24
                    badgeRadius: 12
                    fontSize: 10
                    horizontalPadding: 12
                }

                IconButton {
                    id: closeButton

                    anchors.verticalCenter: parent.verticalCenter

                    buttonSize: 28
                    buttonRadius: 14
                    iconSize: 11

                    icon: ""
                    muted: true

                    onClicked: {
                        root.closePicker()
                    }
                }
            }

            SearchBox {
                id: searchBox

                width: parent.width
                height: 50

                placeholder: clipboardState.deleteMode
                    ? "Search item to delete..."
                    : "Search clipboard history..."

                text: clipboardState.query

                onTextChanged: {
                    clipboardState.query = text
                    clipboardState.selectedIndex = 0
                    clipboardState.filterItems()
                    root.updateListPosition()
                }

                onAccepted: {
                    root.runSelectedAction()
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Escape) {
                        root.closePicker()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Down) {
                        clipboardState.moveDown()
                        root.updateListPosition()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Up) {
                        clipboardState.moveUp()
                        root.updateListPosition()
                        event.accepted = true
                        return
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.runSelectedAction()
                        event.accepted = true
                        return
                    }
                }
            }

            Card {
                id: listFrame

                width: parent.width
                height: parent.height - 96

                cardRadius: 24
                cardColor: Qt.rgba(0, 0, 0, 0.14)
                cardBorderColor: clipboardState.deleteMode
                    ? WalTheme.urgent
                    : WalTheme.border

                clip: true

                Flickable {
                    id: clipboardList

                    anchors.fill: parent
                    anchors.margins: 10
                    anchors.rightMargin: 18

                    contentWidth: width
                    contentHeight: listColumn.implicitHeight

                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.VerticalFlick

                    function ensureSelectedVisible() {
                        if (clipboardState.filteredItems.length === 0)
                            return

                        const itemHeight = 60
                        const targetY = clipboardState.selectedIndex * itemHeight
                        const bottomY = targetY + itemHeight

                        if (targetY < contentY) {
                            contentY = Math.max(0, targetY)
                            return
                        }

                        if (bottomY > contentY + height) {
                            contentY = Math.min(
                                Math.max(0, contentHeight - height),
                                bottomY - height
                            )
                        }
                    }

                    Column {
                        id: listColumn

                        width: clipboardList.width
                        spacing: 6

                        Repeater {
                            model: clipboardState.filteredItems

                            ClipboardItem {
                                required property var modelData
                                required property int index

                                width: listColumn.width

                                value: String(modelData)
                                selected: index === clipboardState.selectedIndex

                                onClicked: function(value) {
                                    if (clipboardState.deleteMode)
                                        clipboardState.deleteItem(value)
                                    else
                                        clipboardState.copyItem(value)
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    visible: clipboardList.contentHeight > clipboardList.height

                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.topMargin: 14
                    anchors.bottomMargin: 14
                    anchors.rightMargin: 8

                    width: 4
                    radius: 999
                    color: Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.08)

                    Rectangle {
                        width: parent.width
                        radius: 999
                        color: clipboardState.deleteMode
                            ? WalTheme.urgent
                            : WalTheme.accent

                        height: clipboardList.contentHeight > 0
                            ? Math.max(34, parent.height * clipboardList.height / clipboardList.contentHeight)
                            : 34

                        y: clipboardList.contentHeight > clipboardList.height
                            ? (parent.height - height) * clipboardList.contentY / (clipboardList.contentHeight - clipboardList.height)
                            : 0

                        Behavior on y {
                            NumberAnimation {
                                duration: Animations.fast
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Card {
                    visible: clipboardState.filteredItems.length === 0

                    anchors.fill: parent
                    anchors.margins: 10

                    cardRadius: 20
                    cardColor: Theme.pillBg
                    cardBorderColor: WalTheme.border

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        HeadingText {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: "No clipboard history"
                            font.pixelSize: 16
                        }

                        MetaText {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: "Copy something first."
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}