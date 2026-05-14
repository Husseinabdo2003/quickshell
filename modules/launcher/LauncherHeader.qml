import QtQuick

import "../../components"
import "../../theme"

Row {
    id: root

    property int resultCount: 0

    signal closeRequested()

    width: parent ? parent.width : 580
    height: 34
    spacing: 10

    HeadingText {
        id: heading

        anchors.verticalCenter: parent.verticalCenter

        text: "Launcher"
        font.pixelSize: 18
    }

    MetaText {
        id: shortcutText

        anchors.verticalCenter: parent.verticalCenter

        text: "SUPER + D"
        font.pixelSize: 11
        opacity: 0.75
    }

    Item {
        width: Math.max(
            0,
            parent.width
                - heading.implicitWidth
                - shortcutText.implicitWidth
                - countBadge.width
                - closeButton.width
                - parent.spacing * 4
        )

        height: 1
    }

    Badge {
        id: countBadge

        anchors.verticalCenter: parent.verticalCenter

        text: root.resultCount + ""
        accent: true

        badgeHeight: 24
        badgeRadius: 12
        fontSize: 11
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
            root.closeRequested()
        }
    }
}