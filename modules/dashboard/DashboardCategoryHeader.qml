import QtQuick

import "../../components"
import "../../theme"

Card {
    id: root

    property string title: "To-do list"
    property int itemCount: 0

    width: parent ? parent.width : 390
    height: 28

    cardRadius: 0
    cardColor: "transparent"
    cardBorderWidth: 0
    cardBorderColor: "transparent"

    Row {
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        spacing: 10

        TitleText {
            text: root.title
            font.pixelSize: 15

            width: Math.max(0, parent.width - 84)
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
        }

        MetaText {
            text: root.itemCount === 1 ? "1 item" : root.itemCount + " items"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
