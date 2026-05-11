import Quickshell
import QtQuick

import "../components"

BarPill {
    label: "  Apps"

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            Quickshell.execDetached(["bash", "-c", "rofi -show drun -show-icons"])
        }
    }
}