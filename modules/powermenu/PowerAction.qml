import QtQuick
import Quickshell

import "../../components"
import "../../theme"

Card {
    id: root

    property string icon: ""
    property string label: ""
    property string command: ""

    signal triggered()

    width: 105
    height: 124

    cardRadius: 24
    cardColor: Theme.pillBg

    cardBorderWidth: 1
    cardBorderColor: mouseArea.containsMouse
        ? WalTheme.accent
        : WalTheme.border

    scale: mouseArea.pressed ? 0.97 : 1.0

    Behavior on cardBorderColor {
        ColorAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Card {
            width: 44
            height: 44

            anchors.horizontalCenter: parent.horizontalCenter

            cardRadius: 17

            cardColor: mouseArea.containsMouse
                ? WalTheme.accentAlpha
                : WalTheme.surfaceAlpha

            cardBorderWidth: 1
            cardBorderColor: mouseArea.containsMouse
                ? WalTheme.accent
                : WalTheme.border

            Behavior on cardColor {
                ColorAnimation {
                    duration: Animations.fast
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on cardBorderColor {
                ColorAnimation {
                    duration: Animations.fast
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                anchors.centerIn: parent

                text: root.icon
                color: WalTheme.fg

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 21
                font.bold: true
            }
        }

        TitleText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.label
            font.pixelSize: Theme.fontSize
            color: WalTheme.fg
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
                Quickshell.execDetached(["bash", "-lc", root.command])
        }
    }
}