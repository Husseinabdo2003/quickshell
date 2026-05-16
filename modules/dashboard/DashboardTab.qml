import QtQuick
import "../../theme"

Rectangle {
    id: root

    property string label: ""
    property bool selected: false

    signal clicked()

    width: 86
    height: 32
    radius: 16

    color: selected ? WalTheme.accentAlpha : Qt.rgba(1, 1, 1, 0.04)

    border.width: 1
    border.color: selected ? WalTheme.accent : WalTheme.border

    Text {
        anchors.centerIn: parent

        text: root.label
        color: selected ? WalTheme.fg : WalTheme.fgMuted

        font.pixelSize: 12
        font.bold: selected
        elide: Text.ElideRight
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked()
        }
    }
}