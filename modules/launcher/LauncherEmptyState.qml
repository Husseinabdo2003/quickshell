import QtQuick

import "../../components"
import "../../theme"

Card {
    id: root

    cardRadius: 20
    cardColor: Theme.pillBg
    cardBorderColor: WalTheme.border

    Column {
        anchors.centerIn: parent
        spacing: 8

        HeadingText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "No apps found"
            font.pixelSize: 16
        }

        MetaText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Try another search or category."
            font.pixelSize: 12
        }
    }
}