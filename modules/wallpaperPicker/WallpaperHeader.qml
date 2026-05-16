import QtQuick

import "../../components"

Row {
    id: root

    property int imageCount: 0
    property bool applying: false

    signal closeRequested()

    width: parent ? parent.width : 1000
    height: 32
    spacing: 12

    HeadingText {
        id: titleText

        text: root.applying ? "󰸉  Applying Wallpaper..." : "󰸉  Wallpapers"
        font.pixelSize: 20

        anchors.verticalCenter: parent.verticalCenter
    }

    Item {
        width: Math.max(
            0,
            parent.width
                - titleText.implicitWidth
                - countBadge.width
                - closeButton.width
                - 48
        )

        height: 1
    }

    Badge {
        id: countBadge

        text: root.applying ? "Working" : root.imageCount + " images"
        muted: !root.applying
        accent: root.applying
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

        enabled: !root.applying
        opacity: root.applying ? 0.45 : 1.0

        anchors.verticalCenter: parent.verticalCenter

        onClicked: {
            root.closeRequested()
        }
    }
}