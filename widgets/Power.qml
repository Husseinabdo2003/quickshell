import QtQuick

import "../components"
import "../services"

BarPill {
    label: ""
    strong: true

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            ShellState.powerMenuOpen = !ShellState.powerMenuOpen
        }
    }
}