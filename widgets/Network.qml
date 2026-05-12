import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Networking

import "../components"
import "../theme"

BarInfoPill {
    id: root

    property var connectedDevice: Networking.devices.values.find(device => device.connected)
    property var connectedNetwork: connectedDevice && connectedDevice.networks
        ? connectedDevice.networks.values.find(network => network.connected)
        : null

    property real lastRx: 0
    property real lastTx: 0
    property real lastTime: 0

    property string downSpeed: "--"
    property string upSpeed: "--"

    property var speedCommand: [
        "sh",
        "-c",
        "iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i==\"dev\") {print $(i+1); exit}}'); " +
        "if [ -z \"$iface\" ]; then exit 1; fi; " +
        "rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null); " +
        "tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null); " +
        "printf \"%s %s\" \"$rx\" \"$tx\""
    ]

    readonly property string networkName: connectedDevice === undefined
        ? ""
        : connectedNetwork !== undefined && connectedNetwork !== null
            ? "  " + connectedNetwork.name
            : "󰈀  " + connectedDevice.name

    minPillWidth: 260

    fullLabel: connectedDevice === undefined
        ? "󰤭  Offline"
        : networkName + "  󰇚 " + downSpeed + "  󰕒 " + upSpeed

    strong: connectedDevice !== undefined
    interactive: true

    function formatSpeed(bytesPerSecond) {
        if (bytesPerSecond < 1024)
            return Math.round(bytesPerSecond) + "B"

        if (bytesPerSecond < 1024 * 1024)
            return (bytesPerSecond / 1024).toFixed(0) + "K"

        if (bytesPerSecond < 1024 * 1024 * 1024)
            return (bytesPerSecond / 1024 / 1024).toFixed(1) + "M"

        return (bytesPerSecond / 1024 / 1024 / 1024).toFixed(1) + "G"
    }

    function updateSpeed(data) {
        if (!data)
            return

        const parts = data.trim().split(/\s+/)

        if (parts.length < 2)
            return

        const rx = Number(parts[0])
        const tx = Number(parts[1])
        const now = Date.now()

        if (isNaN(rx) || isNaN(tx))
            return

        if (lastTime > 0) {
            const seconds = Math.max((now - lastTime) / 1000, 1)
            const rxRate = Math.max((rx - lastRx) / seconds, 0)
            const txRate = Math.max((tx - lastTx) / seconds, 0)

            downSpeed = formatSpeed(rxRate)
            upSpeed = formatSpeed(txRate)
        }

        lastRx = rx
        lastTx = tx
        lastTime = now
    }

    Process {
        id: netSpeedProc

        command: root.speedCommand

        stdout: SplitParser {
            onRead: function(data) {
                root.updateSpeed(data)
            }
        }
    }

    Timer {
        interval: 1000
        running: connectedDevice !== undefined
        repeat: true

        onTriggered: {
            netSpeedProc.exec(root.speedCommand)
        }
    }

    onConnectedDeviceChanged: {
        if (connectedDevice === undefined) {
            downSpeed = "--"
            upSpeed = "--"
            lastRx = 0
            lastTx = 0
            lastTime = 0
        } else {
            netSpeedProc.exec(root.speedCommand)
        }
    }

    Component.onCompleted: {
        if (connectedDevice !== undefined)
            netSpeedProc.exec(root.speedCommand)
    }

    onClicked: {
        Quickshell.execDetached([
            "bash",
            "-lc",
            "kitty -e nmtui"
        ])
    }
}