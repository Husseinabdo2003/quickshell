import QtQuick
import Quickshell.Services.UPower

import "../components"
import "../theme"

BarInfoPill {
    id: root

    property var battery: UPower.displayDevice
    property bool ready: battery !== null && battery.ready
    property int percent: ready ? Math.round(battery.percentage * 100) : 0

    property bool charging: ready && battery.state === UPowerDeviceState.Charging
    property bool full: ready && battery.state === UPowerDeviceState.FullyCharged
    property bool critical: ready && percent <= 15
    property bool warning: ready && percent <= 30 && percent > 15

    icon: !ready
        ? "BAT"
        : charging
            ? ""
            : full
                ? ""
                : percent <= 15
                    ? ""
                    : percent <= 30
                        ? ""
                        : percent <= 55
                            ? ""
                            : percent <= 80
                                ? ""
                                : ""

    value: ready ? percent + "%" : "N/A"

    textColor: charging || full
        ? "#b8e0c0"
        : warning
            ? "#ffd166"
            : critical
                ? WalTheme.urgent
                : WalTheme.fg

    strong: charging || full || warning || critical
}