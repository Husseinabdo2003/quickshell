import QtQuick
import Quickshell.Io

import "../components"
import "../theme"

BarPill {
    id: root

    property int cpuUsage: 0
    property bool ready: false

    property real lastIdle: 0
    property real lastTotal: 0

    minPillWidth: 72

    label: ready ? "  " + cpuUsage + "%" : "  --%"
    strong: ready && cpuUsage >= 70

    textColor: ready && cpuUsage >= 85 ? Theme.accent : Theme.text

    Process {
        id: cpuProc

        command: ["sh", "-c", "head -n 1 /proc/stat"]

        stdout: SplitParser {
            onRead: function(data) {
                if (!data)
                    return

                const parts = data.trim().split(/\s+/)

                if (parts.length < 8 || parts[0] !== "cpu")
                    return

                const user = Number(parts[1])
                const nice = Number(parts[2])
                const system = Number(parts[3])
                const idle = Number(parts[4])
                const iowait = Number(parts[5])
                const irq = Number(parts[6])
                const softirq = Number(parts[7])
                const steal = parts.length > 8 ? Number(parts[8]) : 0

                const idleAll = idle + iowait
                const total = user + nice + system + idle + iowait + irq + softirq + steal

                if (root.lastTotal > 0) {
                    const totalDiff = total - root.lastTotal
                    const idleDiff = idleAll - root.lastIdle

                    if (totalDiff > 0) {
                        root.cpuUsage = Math.max(0, Math.min(100, Math.round((1 - idleDiff / totalDiff) * 100)))
                        root.ready = true
                    }
                }

                root.lastTotal = total
                root.lastIdle = idleAll
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: cpuProc.exec(["sh", "-c", "head -n 1 /proc/stat"])
    }

    Component.onCompleted: cpuProc.exec(["sh", "-c", "head -n 1 /proc/stat"])
}