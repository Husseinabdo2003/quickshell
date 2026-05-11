import Quickshell
import QtQuick
import Quickshell.Io

import "../../theme"
import "../dashboard"

PanelWindow {
    id: barWindow

    anchors {
        left: true
        top: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: "transparent"

    Rectangle {
        id: barRoot

        anchors.fill: parent
        color: "transparent"

        LeftSection {
            id: leftSection
        }

        CenterSection {
            id: centerSection
        }

        RightSection {
            id: rightSection
        }

        Dashboard {
            id: dashboard

            anchorWindow: barWindow
            attachItem: centerSection
        }
    }
}