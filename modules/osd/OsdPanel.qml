import QtQuick

import "../../components"
import "../../theme"

Card {
    id: root

    property string icon: ""
    property string valueText: ""
    property real value: 0
    property real minimum: 0
    property real maximum: 100
    property bool muted: false

    width: 230
    height: 46

    cardRadius: 16
    cardColor: Theme.pillBg
    cardBorderColor: WalTheme.border

    Row {
        anchors.centerIn: parent
        spacing: 9

        Item {
            width: 24
            height: 24

            Text {
                anchors.centerIn: parent

                text: root.icon
                color: root.muted ? WalTheme.fgMuted : WalTheme.fg

                font.family: Theme.fontFamily
                font.pixelSize: 16
            }
        }

        Slider {
            value: root.value
            minimum: root.minimum
            maximum: root.maximum

            sliderWidth: 115
            sliderHeight: 5

            fillColor: root.muted ? WalTheme.fgMuted : WalTheme.accent

            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: 42
            height: 24

            TitleText {
                anchors.centerIn: parent

                text: root.valueText
                font.pixelSize: Theme.fontSize

                muted: root.muted
            }
        }
    }
}