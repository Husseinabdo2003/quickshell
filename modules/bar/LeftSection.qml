import QtQuick

import "../../theme"
import "../../widgets"

Item {
    id: root

    clip: true
    implicitWidth: Math.min(innerRow.implicitWidth, 400)
    implicitHeight: innerRow.implicitHeight

    Row {
        id: innerRow

        spacing: Theme.spacing

        DndToggle {}

        Keyboard {}

        Workspaces {}

        Tray {}
    }
}
