import QtQuick

import "../theme"

BarPill {
    id: root

    property string icon: ""
    property string text: ""
    property bool playing: false
    property bool interactive: true

    property int maxCharacters: 45
    property int iconSize: 13

    signal clicked()

    readonly property string clippedText: text.length > maxCharacters
        ? text.substring(0, maxCharacters) + "…"
        : text

    visible: text.length > 0

    label: ""
    minPillWidth: contentRow.implicitWidth + horizontalPadding * 2
    horizontalPadding: 12

    pillColor: Theme.pillBg
    pillBorderColor: WalTheme.border

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: root.icon
            color: root.playing
                ? WalTheme.accent
                : WalTheme.fgMuted

            opacity: root.playing ? 1.0 : 0.55

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: root.iconSize
            font.bold: true
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: root.clippedText
            color: root.playing
                ? WalTheme.fg
                : WalTheme.fgMuted

            opacity: root.playing ? 1.0 : 0.55

            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: false

            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent

        enabled: root.interactive
        hoverEnabled: false
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: {
            root.clicked()
        }
    }
}