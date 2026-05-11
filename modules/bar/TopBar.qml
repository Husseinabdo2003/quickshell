import Quickshell
import QtQuick

import "../../theme"

PanelWindow {
    anchors {
        left: true
        top: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        LeftSection {}
        CenterSection {}
        RightSection {}
    }
}