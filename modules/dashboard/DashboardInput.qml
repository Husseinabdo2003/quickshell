import QtQuick

import "../../theme"

Rectangle {
    id: root

    property alias text: input.text
    property string label: ""

    function forceInputFocus() {
        input.forceActiveFocus()
    }

    height: 42
    radius: 16

    color: input.activeFocus
        ? Qt.rgba(1, 1, 1, 0.10)
        : WalTheme.surfaceAlpha

    border.width: 1
    border.color: input.activeFocus
        ? WalTheme.accent
        : WalTheme.border

    Column {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 5
        anchors.bottomMargin: 4
        spacing: 1

        Text {
            text: root.label
            color: WalTheme.fgMuted
            font.pixelSize: 9
        }

        TextInput {
            id: input

            width: parent.width

            color: WalTheme.fg
            font.pixelSize: 12

            clip: true
            selectByMouse: true
            cursorVisible: activeFocus
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor

        onClicked: {
            input.forceActiveFocus()
        }
    }
}