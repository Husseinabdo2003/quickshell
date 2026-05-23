import QtQuick

import "../theme"

Item {
    id: root

    property string label: ""
    property string sortKey: ""
    property string activeSortKey: ""
    property bool descending: false
    property bool alignRight: false

    signal requested(string sortKey)

    height: 22

    readonly property bool active: activeSortKey === sortKey

    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        text: root.active
            ? root.label + (root.descending ? " v" : " ^")
            : root.label

        color: root.active || mouseArea.containsMouse
            ? WalTheme.accent
            : WalTheme.fgMuted

        opacity: root.active ? 0.95 : 0.72

        font.family: Theme.fontFamily
        font.pixelSize: 10
        font.bold: root.active

        horizontalAlignment: root.alignRight ? Text.AlignRight : Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 1

        visible: root.active
        color: WalTheme.accent
        opacity: 0.45
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.requested(root.sortKey)
        }
    }
}
