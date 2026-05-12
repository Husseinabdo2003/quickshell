import QtQuick

import "../../theme"
import "../../widgets"

Row {
    id: root

    spacing: Theme.spacing

    Cpu {}

    Ram {}

    Network {}

    Audio {}

    Battery {}

    Keyboard {}

    Power {}
}