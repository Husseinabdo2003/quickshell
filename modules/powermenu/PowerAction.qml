import QtQuick
import Quickshell

import "../../components"
import "../../services"
import "../../theme"

Card {
    id: root

    property string icon: ""
    property string label: ""
    property string command: ""
    property bool danger: false

    signal triggered()

    width: 105
    height: 130

    cardRadius: 24

    cardColor: mouseArea.containsMouse
        ? WalTheme.surfaceAlpha
        : Theme.pillBg

    cardBorderColor: mouseArea.containsMouse
        ? WalTheme.accent
        : WalTheme.border

    cardBorderWidth: 1

    scale: mouseArea.pressed ? 0.97 : 1.0

    Behavior on cardColor {
        ColorAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Behavior on cardBorderColor {
        ColorAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 80
            easing.type: Easing.OutCubic
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 12

        Text {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.icon

            color: mouseArea.containsMouse
                ? WalTheme.accent
                : WalTheme.fg

            font.family: Theme.fontFamily
            font.pixelSize: 28
        }

        TitleText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.label
            font.pixelSize: Theme.fontSize

            accent: mouseArea.containsMouse
            danger: false
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.triggered()

            if (root.command.length > 0)
                Quickshell.execDetached(["bash", "-c", root.command])
        }
    }
}