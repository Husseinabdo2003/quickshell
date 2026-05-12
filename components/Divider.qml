import QtQuick

import "../theme"

Rectangle {
    id: root

    property real lineOpacity: 0.75
    property color lineColor: WalTheme.border

    width: parent ? parent.width : 1
    height: 1

    color: lineColor
    opacity: lineOpacity
}