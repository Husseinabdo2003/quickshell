import QtQuick

import "../theme"

Rectangle {
    id: root

    property int cardRadius: 30
    property int cardBorderWidth: 1

    property color cardColor: Theme.pillBg
    property color cardBorderColor: WalTheme.border

    default property alias content: contentHost.data

    radius: cardRadius
    color: cardColor

    border.width: cardBorderWidth
    border.color: cardBorderColor

    clip: true

    Item {
        id: contentHost

        anchors.fill: parent
    }
}