import QtQuick

import "../theme"

Rectangle {
    id: root

    property string icon: "×"
    property string tooltip: ""

    property bool accent: false
    property bool danger: false
    property bool muted: false

    property int buttonSize: 30
    property int buttonRadius: buttonSize / 2
    property int iconSize: 15

    signal clicked()

    width: buttonSize
    height: buttonSize

    radius: buttonRadius

    color: {
        if (danger)
            return mouseArea.containsMouse ? WalTheme.urgent : WalTheme.urgentAlpha

        if (accent)
            return mouseArea.containsMouse ? WalTheme.accent : WalTheme.accentAlpha

        if (muted)
            return mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(1, 1, 1, 0.05)

        return mouseArea.containsMouse ? WalTheme.accentAlpha : Qt.rgba(1, 1, 1, 0.04)
    }

    border.width: 1

    border.color: {
        if (danger)
            return WalTheme.urgent

        if (accent)
            return WalTheme.accent

        return WalTheme.border
    }

    scale: mouseArea.pressed ? 0.94 : 1.0

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Animations.press
            easing.type: Easing.OutCubic
        }
    }

    Text {
        anchors.centerIn: parent

        text: root.icon
        color: root.muted ? WalTheme.fgMuted : WalTheme.fg

        font.pixelSize: root.iconSize
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked()
        }
    }
}