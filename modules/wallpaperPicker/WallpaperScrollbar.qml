import QtQuick

import "../../theme"

Rectangle {
    id: root

    property real contentWidthValue: 0
    property real viewportWidthValue: 1
    property real contentXValue: 0

    visible: contentWidthValue > viewportWidthValue

    height: 4
    radius: 999

    color: Qt.rgba(
        WalTheme.fg.r,
        WalTheme.fg.g,
        WalTheme.fg.b,
        0.10
    )

    Rectangle {
        height: parent.height
        radius: 999
        color: WalTheme.accent

        width: root.contentWidthValue > 0
            ? Math.max(80, parent.width * root.viewportWidthValue / root.contentWidthValue)
            : 80

        x: root.contentWidthValue > root.viewportWidthValue
            ? (parent.width - width) * root.contentXValue / (root.contentWidthValue - root.viewportWidthValue)
            : 0

        Behavior on x {
            NumberAnimation {
                duration: 90
                easing.type: Easing.OutCubic
            }
        }
    }
}