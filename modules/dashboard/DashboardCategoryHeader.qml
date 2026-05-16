import QtQuick

import "../../components"

Row {
    id: root

    property string title: "To-do list"
    property int itemCount: 0

    width: parent ? parent.width : 390
    height: 24

    TitleText {
        text: root.title
        font.pixelSize: 16

        width: Math.max(0, parent.width - 80)
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
    }

    MetaText {
        text: root.itemCount + " items"

        anchors.verticalCenter: parent.verticalCenter
    }
}