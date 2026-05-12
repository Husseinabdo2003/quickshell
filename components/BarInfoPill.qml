import QtQuick
import Quickshell

import "../theme"

BarPill {
    id: root

    property string icon: ""
    property string value: ""
    property string fullLabel: ""

    property bool interactive: false
    property string command: ""

    property color normalColor: Theme.pillBg
    property color hoverColor: Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.055)

    signal clicked()
    signal wheelMoved(var wheel)

    label: fullLabel.length > 0
        ? fullLabel
        : icon.length > 0
            ? icon + "  " + value
            : value

    pillColor: mouseArea.containsMouse && root.interactive
        ? hoverColor
        : normalColor

    pillBorderColor: WalTheme.border

    Behavior on pillColor {
        ColorAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        enabled: root.interactive || root.command.length > 0

        hoverEnabled: enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

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

        onWheel: function(wheel) {
            root.wheelMoved(wheel)
        }
    }
}