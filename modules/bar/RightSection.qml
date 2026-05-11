import QtQuick

import "../../theme"
import "../../components"
import "../../widgets"

Row {
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.rightMargin: Theme.margin

    spacing: Theme.spacing

    Cpu {}

    Ram {}

    Network {}

    Audio {}

    Battery {}

    Keyboard {}

    Power {}
}
