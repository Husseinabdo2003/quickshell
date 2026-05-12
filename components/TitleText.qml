import QtQuick

import "../theme"

Text {
    id: root

    property bool muted: false
    property bool accent: false
    property bool danger: false

    color: {
        if (danger)
            return WalTheme.urgent

        if (accent)
            return WalTheme.accent

        if (muted)
            return WalTheme.fgMuted

        return WalTheme.fg
    }

    font.pixelSize: 15
    font.bold: true

    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}