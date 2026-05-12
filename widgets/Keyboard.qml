import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

import "../components"

BarInfoPill {
    id: root

    property string layout: "EN"

    value: layout
    strong: true

    interactive: true

    function parseLayout(text) {
        const keymap = text.trim().toLowerCase()

        if (keymap.includes("arabic")) {
            root.layout = "AR"
        } else if (keymap.includes("english") || keymap.includes("us")) {
            root.layout = "EN"
        }
    }

    function refreshLayout() {
        if (!readLayoutProcess.running)
            readLayoutProcess.running = true
    }

    Process {
        id: readLayoutProcess

        command: [
            "bash",
            "-c",
            "hyprctl devices -j | jq -r '.keyboards[] | select(.active_keymap != null) | .active_keymap' | head -1"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseLayout(this.text)
            }
        }
    }

    Process {
        id: switchLayoutProcess

        command: [
            "bash",
            "-c",
            "hyprctl switchxkblayout all next >/dev/null"
        ]

        onRunningChanged: {
            if (!running)
                root.refreshLayout()
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "activelayout")
                root.refreshLayout()
        }
    }

    Component.onCompleted: {
        root.refreshLayout()
    }

    onClicked: {
        if (!switchLayoutProcess.running)
            switchLayoutProcess.running = true
    }
}