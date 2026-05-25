import QtQuick

import "../../components"
import "../../theme"

Item {
    id: root

    property bool addOpen: false
    property bool busy: false
    property int itemCount: 0
    property int highPriorityCount: 0

    signal addClicked()

    width: parent ? parent.width : 390
    height: 38

    Row {
        anchors.left: parent.left
        anchors.right: highBadge.visible ? highBadge.left : addButton.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        HeadingText {
            text: "Dashboard"
            font.pixelSize: 18

            width: Math.max(0, parent.width - countBadge.width - parent.spacing)
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
        }

        Badge {
            id: countBadge

            anchors.verticalCenter: parent.verticalCenter

            text: root.itemCount === 1 ? "1 task" : root.itemCount + " tasks"
            accent: true
            badgeHeight: 22
            badgeRadius: 11
            fontSize: 10
            horizontalPadding: 12
        }
    }

    Badge {
        id: highBadge

        visible: root.highPriorityCount > 0
        anchors.right: addButton.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        text: root.highPriorityCount + " high"
        danger: true
        badgeHeight: 22
        badgeRadius: 11
        fontSize: 10
        horizontalPadding: 12
    }

    ActionButton {
        id: addButton

        width: 92
        height: 30

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        text: root.busy
            ? "Working"
            : root.addOpen
                ? "Close"
                : "+ Add"

        accent: !root.addOpen && !root.busy
        danger: root.addOpen && !root.busy
        muted: root.busy

        buttonRadius: 15
        fontSize: 12

        enabled: !root.busy
        opacity: root.busy ? 0.65 : 1.0

        onClicked: {
            root.addClicked()
        }
    }
}
