import QtQuick
import "../../theme"

Rectangle {
    id: root

    property string label: ""
    property int count: 0
    property bool selected: false

    signal clicked()

    width: 86
    height: 32
    radius: 16

    color: selected ? WalTheme.accentAlpha : mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : Qt.rgba(1, 1, 1, 0.04)

    border.width: 1
    border.color: selected ? WalTheme.accent : WalTheme.border

    Row {
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: root.label
            color: selected ? WalTheme.fg : WalTheme.fgMuted

            font.pixelSize: 11
            font.bold: selected
            elide: Text.ElideRight
        }

        Rectangle {
            width: Math.max(18, countText.implicitWidth + 8)
            height: 18
            radius: 9

            anchors.verticalCenter: parent.verticalCenter

            color: root.selected ? Qt.rgba(0, 0, 0, 0.18) : Qt.rgba(1, 1, 1, 0.06)

            Text {
                id: countText

                anchors.centerIn: parent

                text: root.count + ""
                color: root.selected ? WalTheme.fg : WalTheme.fgMuted

                font.pixelSize: 9
                font.bold: true
            }
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked()
        }
    }
}
