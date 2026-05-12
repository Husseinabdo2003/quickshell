import QtQuick

import "../theme"

Rectangle {
    id: root

    property bool danger: false
    property bool accent: true

    property int stripWidth: 7
    property int stripRadius: 4

    width: stripWidth
    radius: stripRadius

    color: danger ? WalTheme.urgent : WalTheme.accent
}