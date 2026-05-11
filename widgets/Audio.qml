import QtQuick
import Quickshell.Services.Pipewire

import "../components"
import "../theme"

BarPill {
    id: root

    property real maxVolume: 2.55

    property var sink: Pipewire.defaultAudioSink
    property bool ready: sink !== null && sink.audio !== null
    property int volume: ready ? Math.round(sink.audio.volume * 100) : 0
    property bool muted: ready ? sink.audio.muted : false

    PwObjectTracker {
        objects: sink !== null ? [sink] : []
    }

    label: !ready ? "  N/A"
           : muted ? "󰝟  0%"
           : "  " + volume + "%"

    strong: muted || volume >= 100

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (ready)
                sink.audio.muted = !sink.audio.muted
        }

        onWheel: function(wheel) {
            if (!ready)
                return

            if (wheel.angleDelta.y > 0)
                sink.audio.volume = Math.min(sink.audio.volume + 0.05, root.maxVolume)
            else
                sink.audio.volume = Math.max(sink.audio.volume - 0.05, 0)
        }
    }
}