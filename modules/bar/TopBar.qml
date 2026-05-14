import Quickshell
import QtQuick

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

    Item {
        id: barRoot

        anchors.fill: parent

        LeftSection {
            id: leftSection

            anchors.left: parent.left
            anchors.leftMargin: Theme.margin
            anchors.verticalCenter: parent.verticalCenter
        }

        CenterSection {
            id: centerSection

            anchors.centerIn: parent
        }

        RightSection {
            id: rightSection

            anchors.right: parent.right
            anchors.rightMargin: Theme.margin
            anchors.verticalCenter: parent.verticalCenter
        }

        Dashboard {
            id: dashboard

            anchorWindow: barWindow
            attachItem: leftSection
        }
    }
}