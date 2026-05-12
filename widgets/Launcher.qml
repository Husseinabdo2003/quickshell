import QtQuick

import "../components"

BarActionPill {
    icon: "󰣇"
    command: "pgrep -x rofi >/dev/null && pkill -x rofi || rofi -show drun -show-icons"

    actionWidth: 38
    iconSize: 14
}