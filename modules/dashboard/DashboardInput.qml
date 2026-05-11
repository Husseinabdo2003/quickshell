import QtQuick
import "../../theme"

Rectangle {
    id: root

    property alias text: input.text
    property string label: ""

    height: 42
    radius: 16

    color: WalTheme.surfaceAlpha
    border.width: 1
    border.color: WalTheme.border

    Column {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 4
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
        }
    }
}
