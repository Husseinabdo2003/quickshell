import Quickshell
import QtQuick

import "../components"

BarInfoPill {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    value: Qt.formatDateTime(clock.date, "hh:mm AP")
    strong: true
}