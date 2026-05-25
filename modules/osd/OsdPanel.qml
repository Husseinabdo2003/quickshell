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
    property bool overThreshold: false

    readonly property real safeMinimum: Math.min(root.minimum, root.maximum)
    readonly property real safeMaximum: Math.max(root.minimum, root.maximum)
    readonly property real safeValue: Math.max(
        root.safeMinimum,
        Math.min(root.value, root.safeMaximum)
    )

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

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
            }
        }

        Slider {
            value: root.safeValue
            minimum: root.safeMinimum
            maximum: root.safeMaximum

            sliderWidth: 115
            sliderHeight: 5

            fillColor: root.overThreshold
                ? WalTheme.urgent
                : root.muted
                    ? WalTheme.fgMuted
                    : WalTheme.accent

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
                color: root.overThreshold ? WalTheme.urgent : WalTheme.fg
            }
        }
    }
}
