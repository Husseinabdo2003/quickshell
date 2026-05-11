import QtQuick

import "../../theme"
import "../../widgets"

Row {
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: Theme.margin

    spacing: Theme.spacing

    Workspaces {}

    Tray {}
}