import QtQuick

import "../../components"

Row {
    id: root

    property int imageCount: 0

    signal closeRequested()

    width: parent ? parent.width : 1000
    height: 32
    spacing: 12

    HeadingText {
        id: titleText

        text: "󰸉  Wallpapers"
        font.pixelSize: 20

        anchors.verticalCenter: parent.verticalCenter
    }

    Item {
        width: parent.width
            - titleText.implicitWidth
            - countBadge.width
            - closeButton.width
            - 48
        height: 1
    }

    Badge {
        id: countBadge

        text: root.imageCount + " images"
        muted: true
        accent: false
        badgeHeight: 28
        badgeRadius: 14
        fontSize: 11
        horizontalPadding: 22

        anchors.verticalCenter: parent.verticalCenter
    }

    IconButton {
        id: closeButton

        buttonSize: 30
        buttonRadius: 15
        iconSize: 22

        icon: "×"
        muted: true

        anchors.verticalCenter: parent.verticalCenter

        onClicked: {
            root.closeRequested()
        }
    }
}