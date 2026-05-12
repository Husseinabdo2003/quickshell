import QtQuick
import Quickshell

import "../theme"

BarPill {
    id: root

    property string icon: ""
    property string command: ""

    property int actionWidth: 34
    property int iconSize: 13

    signal clicked()

    label: ""
    minPillWidth: actionWidth
    horizontalPadding: 0

    pillColor: mouseArea.containsMouse
        ? Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.055)
        : Theme.pillBg

    pillBorderColor: WalTheme.border

    Behavior on pillColor {
        ColorAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Text {
        anchors.centerIn: parent

        text: root.icon
        color: WalTheme.fg

        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: root.iconSize
        font.bold: true
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked()

            if (root.command.length > 0) {
                Quickshell.execDetached([
                    "bash",
                    "-lc",
                    root.command
                ])
            }
        }
    }
}