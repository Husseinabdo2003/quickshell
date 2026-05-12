import QtQuick

import "../theme"

Rectangle {
    id: root

    property string label: ""
    property bool strong: false
    property color textColor: strong ? WalTheme.fg : WalTheme.fgMuted

    property int minPillWidth: 0
    property int horizontalPadding: 12
    property int pillHeight: Theme.pillHeight
    property int fontSize: Theme.fontSize

    property color pillColor: Theme.pillBg
    property color pillBorderColor: WalTheme.border

    default property alias content: contentHost.data

    height: pillHeight

    width: Math.max(
        minPillWidth,
        labelText.implicitWidth + horizontalPadding * 2
    )

    radius: Theme.radius
    color: pillColor

    border.width: 1
    border.color: pillBorderColor

    clip: true

    Text {
        id: labelText

        anchors.centerIn: parent

        text: root.label
        color: root.textColor

        font.family: Theme.fontFamily
        font.pixelSize: root.fontSize
        font.bold: root.strong

        elide: Text.ElideRight
    }

    Item {
        id: contentHost

        anchors.fill: parent
        z: 10
    }
}