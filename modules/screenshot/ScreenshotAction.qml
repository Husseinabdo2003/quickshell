import QtQuick

import "../../components"
import "../../theme"

Card {
    id: root

    property string icon: ""
    property string label: ""
    property string shortcut: ""
    property string scriptMode: ""

    signal requested()

    width: 105
    height: 124

    cardRadius: 24
    cardColor: Theme.pillBg

    cardBorderWidth: 1
    cardBorderColor: mouseArea.containsMouse
        ? WalTheme.accent
        : WalTheme.border

    scale: mouseArea.pressed ? 0.97 : 1.0
    opacity: 1.0

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
            font.pixelSize: 14
            color: WalTheme.fg
        }

        MetaText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.shortcut

            font.pixelSize: 10
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.requested()
        }
    }
}
