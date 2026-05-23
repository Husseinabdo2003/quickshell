import QtQuick

import "../../theme"

Rectangle {
    id: root

    property string name: ""
    property string path: ""
    property string kind: "file"
    property string sizeText: ""
    property string modifiedText: ""
    property bool selected: false
    property int iconColumnWidth: 22
    property int sizeColumnWidth: 82
    property int dateColumnWidth: 132
    property int columnGap: 12
    property int horizontalInset: 10

    signal opened(string path, string kind)
    signal selectedPath(string path)
    signal contextRequested(string path, real sceneX, real sceneY)

    height: 34
    radius: 6

    color: {
        if (root.selected)
            return WalTheme.accentAlpha

        return mouseArea.containsMouse
            ? Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.055)
            : "transparent"
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: root.horizontalInset
        anchors.rightMargin: root.horizontalInset
        spacing: root.columnGap

        Text {
            anchors.verticalCenter: parent.verticalCenter

            width: root.iconColumnWidth

            text: root.kind === "directory" ? "" : root.kind === "link" ? "" : ""
            color: root.selected
                ? WalTheme.fg
                : root.kind === "directory"
                    ? WalTheme.accent
                    : WalTheme.fgMuted

            font.family: Theme.iconFontFamily
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width
                - root.iconColumnWidth
                - root.sizeColumnWidth
                - root.dateColumnWidth
                - (root.columnGap * 3)

            text: root.name
            color: WalTheme.fg

            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: root.kind === "directory"

            elide: Text.ElideMiddle
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            width: root.sizeColumnWidth

            text: root.sizeText
            color: root.selected ? WalTheme.fg : WalTheme.fgMuted

            font.family: Theme.fontFamily
            font.pixelSize: 11

            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            width: root.dateColumnWidth

            text: root.modifiedText
            color: root.selected ? WalTheme.fg : WalTheme.fgMuted

            font.family: Theme.fontFamily
            font.pixelSize: 11

            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            root.selectedPath(root.path)

            if (mouse.button === Qt.RightButton) {
                const scenePoint = root.mapToItem(null, mouse.x, mouse.y)
                root.contextRequested(root.path, scenePoint.x, scenePoint.y)
            }
        }

        onDoubleClicked: {
            root.opened(root.path, root.kind)
        }
    }
}
