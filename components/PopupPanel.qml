import QtQuick

import "../theme"

Rectangle {
    id: root

    property bool opened: false

    property real openY: 0
    property real closedY: -height - 24

    property int panelRadius: 30
    property int animationDuration: Animations.panel

    property color panelColor: Theme.pillBg
    property color panelBorderColor: WalTheme.border
    property int panelBorderWidth: 1

    default property alias content: contentHost.data

    y: opened ? openY : closedY

    radius: panelRadius
    color: panelColor

    border.width: panelBorderWidth
    border.color: panelBorderColor

    clip: true

    Behavior on y {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }

    Item {
        id: contentHost

        anchors.fill: parent
    }
}