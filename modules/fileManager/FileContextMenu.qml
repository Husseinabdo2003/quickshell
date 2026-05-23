import QtQuick

import "../../theme"

Rectangle {
    id: root

    property bool opened: false
    property bool hasSelection: false
    property bool canPaste: false
    property bool inTrash: false
    property bool busy: false
    property int menuWidth: 188
    property int rowHeight: 30
    readonly property int visibleActionRows: 4 + (hasSelection ? 4 : 0)
    readonly property int visibleDividerRows: (hasSelection ? 1 : 0) + ((hasSelection || inTrash) ? 1 : 0)
    readonly property int visibleRows: visibleActionRows + visibleDividerRows
    readonly property int menuHeight: 10
        + (visibleActionRows * rowHeight)
        + visibleDividerRows
        + (Math.max(0, visibleRows - 1) * menuColumn.spacing)

    signal openRequested()
    signal newFolderRequested()
    signal copyRequested()
    signal cutRequested()
    signal pasteRequested()
    signal renameRequested()
    signal trashRequested()
    signal emptyTrashRequested()
    signal reloadRequested()

    function openAt(posX, posY) {
        const margin = 8
        const nextX = Math.max(margin, Math.min(posX, parent.width - root.width - margin))
        let nextY = posY

        if (posY + root.menuHeight > parent.height - margin)
            nextY = posY - root.menuHeight

        root.x = nextX
        root.y = Math.max(margin, Math.min(nextY, parent.height - root.menuHeight - margin))
        root.opened = true
    }

    function close() {
        root.opened = false
    }

    width: menuWidth
    height: menuHeight
    radius: 10
    z: 40

    visible: opened
    opacity: opened ? 1.0 : 0.0

    color: WalTheme.surfaceAlpha
    border.width: 1
    border.color: WalTheme.border

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            mouse.accepted = true
        }
    }

    Column {
        id: menuColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 5
        spacing: 2

        MenuItem {
            text: "Open"
            icon: ""
            enabled: root.hasSelection
            visible: root.hasSelection

            onTriggered: {
                root.close()
                root.openRequested()
            }
        }

        MenuItem {
            text: "New Folder"
            icon: ""
            enabled: !root.busy && !root.inTrash

            onTriggered: {
                root.close()
                root.newFolderRequested()
            }
        }

        DividerLine {
            visible: root.hasSelection
        }

        MenuItem {
            text: "Copy"
            icon: ""
            enabled: root.hasSelection && !root.busy
            visible: root.hasSelection

            onTriggered: {
                root.close()
                root.copyRequested()
            }
        }

        MenuItem {
            text: "Cut"
            icon: ""
            enabled: root.hasSelection && !root.busy
            visible: root.hasSelection

            onTriggered: {
                root.close()
                root.cutRequested()
            }
        }

        MenuItem {
            text: "Paste"
            icon: ""
            enabled: root.canPaste && !root.busy && !root.inTrash

            onTriggered: {
                root.close()
                root.pasteRequested()
            }
        }

        MenuItem {
            text: "Rename"
            icon: ""
            enabled: root.hasSelection && !root.busy && !root.inTrash
            visible: root.hasSelection

            onTriggered: {
                root.close()
                root.renameRequested()
            }
        }

        DividerLine {
            visible: root.hasSelection || root.inTrash
        }

        MenuItem {
            text: root.inTrash ? "Empty Trash" : "Move to Trash"
            icon: ""
            danger: true
            enabled: root.inTrash ? !root.busy : root.hasSelection && !root.busy

            onTriggered: {
                root.close()

                if (root.inTrash)
                    root.emptyTrashRequested()
                else
                    root.trashRequested()
            }
        }

        MenuItem {
            text: "Reload"
            icon: ""
            enabled: !root.busy

            onTriggered: {
                root.close()
                root.reloadRequested()
            }
        }
    }

    component DividerLine: Rectangle {
        width: parent.width
        height: 1
        color: WalTheme.border
        opacity: 0.65
    }

    component MenuItem: Rectangle {
        id: item

        property string text: ""
        property string icon: ""
        property bool danger: false

        signal triggered()

        width: parent.width
        height: root.rowHeight
        radius: 7

        color: itemMouse.containsMouse && item.enabled
            ? Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.075)
            : "transparent"
        opacity: item.enabled ? 1.0 : 0.42

        Row {
            anchors.fill: parent
            anchors.leftMargin: 9
            anchors.rightMargin: 9
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter

                width: 18

                text: item.icon
                color: item.danger ? WalTheme.urgent : WalTheme.fgMuted

                font.family: Theme.iconFontFamily
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                width: parent.width - 26

                text: item.text
                color: item.danger ? WalTheme.urgent : WalTheme.fg

                font.family: Theme.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: itemMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: item.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: {
                if (item.enabled)
                    item.triggered()
            }
        }
    }
}
