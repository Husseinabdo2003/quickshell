import QtQuick

import "../../theme"

Rectangle {
    id: root

    property string itemId: ""
    property string itemType: ""
    property string title: ""
    property string course: ""
    property string date: ""
    property string priority: ""
    property string status: ""

    signal removeRequested(string itemId)

    height: 88

    radius: 30
    color: Qt.rgba(0.055, 0.02, 0.045, 0.82)

    border.width: 1
    border.color: WalTheme.border

    Row {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            width: 7
            height: parent.height - 10
            radius: 4

            color: root.priority === "high"
                ? WalTheme.urgent
                : WalTheme.accent

            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: parent.width - 72
            anchors.verticalCenter: parent.verticalCenter
            spacing: 7

            Row {
                width: parent.width
                spacing: 8

                Rectangle {
                    width: typeText.implicitWidth + 14
                    height: 22
                    radius: 11

                    color: root.priority === "high"
                        ? WalTheme.urgentAlpha
                        : WalTheme.accentAlpha

                    Text {
                        id: typeText

                        anchors.centerIn: parent
                        text: root.itemType.toUpperCase()

                        color: WalTheme.fg
                        font.pixelSize: 10
                        font.bold: true
                    }
                }

                Text {
                    width: parent.width - typeText.implicitWidth - 32

                    text: root.title
                    color: WalTheme.fg

                    font.pixelSize: 15
                    font.bold: true

                    elide: Text.ElideRight
                }
            }

            Row {
                width: parent.width
                spacing: 10

                Text {
                    text: root.course
                    color: WalTheme.fgMuted

                    font.pixelSize: 12
                    width: parent.width * 0.40

                    elide: Text.ElideRight
                }

                Text {
                    text: root.date
                    color: WalTheme.fgMuted

                    font.pixelSize: 12
                }

                Text {
                    text: root.status
                    color: WalTheme.fgMuted

                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }
        }

        Rectangle {
            width: 34
            height: 34
            radius: 17

            color: deleteMouse.containsMouse
                ? WalTheme.urgentAlpha
                : Qt.rgba(1, 1, 1, 0.05)

            border.width: 1
            border.color: deleteMouse.containsMouse
                ? WalTheme.urgent
                : WalTheme.border

            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent

                text: "×"
                color: WalTheme.fg

                font.pixelSize: 18
                font.bold: true
            }

            MouseArea {
                id: deleteMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.removeRequested(root.itemId)
                }
            }
        }
    }
}