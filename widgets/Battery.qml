import QtQuick
import Quickshell.Services.UPower

import "../components"
import "../theme"

BarPill {
    id: root

    property var battery: UPower.displayDevice
    property bool ready: battery !== null && battery.ready
    property int percent: ready ? Math.round(battery.percentage * 100) : 0

    property bool charging: ready && battery.state === UPowerDeviceState.Charging
    property bool full: ready && battery.state === UPowerDeviceState.FullyCharged
    property bool critical: ready && percent <= 15
    property bool warning: ready && percent <= 30 && percent > 15

    label: !ready ? "BAT N/A"
           : charging ? "  " + percent + "%"
           : full ? "  " + percent + "%"
           : percent <= 15 ? "  " + percent + "%"
           : percent <= 30 ? "  " + percent + "%"
           : percent <= 55 ? "  " + percent + "%"
           : percent <= 80 ? "  " + percent + "%"
           : "  " + percent + "%"

    textColor: charging || full ? "#b8e0c0"
             : warning ? "#ffd166"
             : critical ? Theme.accent
             : Theme.text

    strong: charging || full || warning || critical
}