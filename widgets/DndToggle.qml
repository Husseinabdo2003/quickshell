import QtQuick

import "../components"
import "../services"

BarActionPill {
    icon: ShellState.doNotDisturb ? "󰂛" : "󰂚"

    onClicked: {
        ShellState.toggleDoNotDisturb()
    }
}
