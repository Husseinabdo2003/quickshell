import QtQuick

import "../../theme"
import "../../widgets"

Item {
    id: root

    property real availableWidth: parent ? parent.width : 9999

    clip: true
    implicitWidth: innerRow.implicitWidth
    implicitHeight: innerRow.implicitHeight

    Row {
        id: innerRow

        spacing: Theme.spacing

        Cpu {
            visible: root.availableWidth > 520
        }

        Ram {
            visible: root.availableWidth > 420
        }

        Network {}

        Audio {}

        Battery {}

        Power {}
    }
}
