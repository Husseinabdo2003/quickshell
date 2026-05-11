import QtQuick
import Quickshell.Io

import "../components"
import "../theme"

BarPill {
    id: root

    property int ramUsage: 0
    property bool ready: false

    minPillWidth: 72

    label: ready ? "  " + ramUsage + "%" : "  --%"
    strong: ready && ramUsage >= 70

    textColor: ready && ramUsage >= 85 ? Theme.accent : Theme.text

    Process {
        id: ramProc

        command: ["sh", "-c", "free | awk '/Mem:/ {printf \"%d\", ($3/$2) * 100}'"]

        stdout: SplitParser {
            onRead: function(data) {
                if (!data)
                    return

                const value = Number(data.trim())

                if (isNaN(value))
                    return

                root.ramUsage = Math.max(0, Math.min(100, Math.round(value)))
                root.ready = true
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: ramProc.exec(["sh", "-c", "free | awk '/Mem:/ {printf \"%d\", ($3/$2) * 100}'"])
    }

    Component.onCompleted: ramProc.exec(["sh", "-c", "free | awk '/Mem:/ {printf \"%d\", ($3/$2) * 100}'"])
}