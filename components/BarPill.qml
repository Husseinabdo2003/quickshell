import QtQuick
import "../theme"

Rectangle {
    id: root

    property string label: "Pill"
    property bool strong: false
    property color textColor: strong ? Theme.textStrong : Theme.text
    property int horizontalPadding: 24
    property int minPillWidth: 0

    height: Theme.pillHeight
    width: Math.max(textItem.implicitWidth + horizontalPadding, minPillWidth)

    radius: Theme.radius
    color: Theme.pillBg

    border.width: 1
    border.color: Theme.border

    Text {
        id: textItem
        anchors.centerIn: parent

        text: root.label
        color: root.textColor
        font.pixelSize: Theme.fontSize
        font.bold: root.strong
        font.family: Theme.fontFamily
    }
}