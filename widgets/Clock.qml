import Quickshell
import QtQuick

import "../components"

BarPill {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    label: Qt.formatDateTime(clock.date, "hh:mm AP")
    strong: true
}