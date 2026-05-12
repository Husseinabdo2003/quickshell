import QtQuick

import "../theme"

Text {
    id: root

    property bool boldText: false
    property bool accentText: false
    property bool dangerText: false

    color: {
        if (dangerText)
            return WalTheme.urgent

        if (accentText)
            return WalTheme.accent

        return WalTheme.fgMuted
    }

    font.pixelSize: 12
    font.bold: boldText

    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}