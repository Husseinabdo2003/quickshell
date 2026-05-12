import QtQuick

import "../theme"

Rectangle {
    id: root

    property string text: ""
    property bool danger: false
    property bool accent: true
    property bool muted: false

    property int horizontalPadding: 14
    property int badgeHeight: 22
    property int badgeRadius: badgeHeight / 2
    property int fontSize: 10

    width: badgeText.implicitWidth + horizontalPadding
    height: badgeHeight

    radius: badgeRadius

    color: {
        if (danger)
            return WalTheme.urgentAlpha

        if (accent)
            return WalTheme.accentAlpha

        if (muted)
            return Qt.rgba(1, 1, 1, 0.06)

        return WalTheme.accentAlpha
    }

    border.width: 0
    border.color: "transparent"

    Text {
        id: badgeText

        anchors.centerIn: parent

        text: root.text
        color: root.muted ? WalTheme.fgMuted : WalTheme.fg

        font.pixelSize: root.fontSize
        font.bold: true

        elide: Text.ElideRight
    }
}