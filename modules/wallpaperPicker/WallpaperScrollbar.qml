import QtQuick

import "../../theme"

Rectangle {
    id: root

    property real contentWidthValue: 0
    property real viewportWidthValue: 1
    property real contentXValue: 0

    readonly property real safeContentWidth: Math.max(0, root.contentWidthValue)
    readonly property real safeViewportWidth: Math.max(1, root.viewportWidthValue)
    readonly property real maxContentX: Math.max(0, root.safeContentWidth - root.safeViewportWidth)
    readonly property real safeContentX: Math.max(0, Math.min(root.contentXValue, root.maxContentX))

    visible: root.safeContentWidth > root.safeViewportWidth

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

        width: root.safeContentWidth > 0
            ? Math.min(parent.width, Math.max(80, parent.width * root.safeViewportWidth / root.safeContentWidth))
            : 80

        x: root.safeContentWidth > root.safeViewportWidth
            ? (parent.width - width) * root.safeContentX / (root.safeContentWidth - root.safeViewportWidth)
            : 0

        Behavior on x {
            NumberAnimation {
                duration: 90
                easing.type: Easing.OutCubic
            }
        }
    }
}