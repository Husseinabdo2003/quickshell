import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

import "../../services"

PanelWindow {
    id: root

    anchors {
        bottom: true
    }

    margins {
        bottom: 100
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true

    implicitWidth: 230
    implicitHeight: ShellState.volumeOsdOpen ? 46 : 0

    color: "transparent"
    visible: ShellState.volumeOsdOpen

    property real maxVolume: 2.55

    property var sink: Pipewire.defaultAudioSink
    property bool ready: sink !== null && sink.audio !== null
    property int volume: ready ? Math.round(sink.audio.volume * 100) : 0
    property bool muted: ready ? sink.audio.muted : false

    readonly property int sliderMaximum: Math.round(root.maxVolume * 100)
    readonly property int shownVolume: root.muted ? 0 : root.volume
    readonly property bool overThreshold: root.volume > 100

    PwObjectTracker {
        objects: sink !== null ? [sink] : []
    }

    IpcHandler {
        target: "volumeOsd"

        function show(): void {
            root.show()
        }

        function raise(): void {
            if (root.ready) {
                root.sink.audio.volume = Math.min(
                    root.sink.audio.volume + 0.05,
                    root.maxVolume
                )

                root.show()
            }
        }

        function lower(): void {
            if (root.ready) {
                root.sink.audio.volume = Math.max(
                    root.sink.audio.volume - 0.05,
                    0
                )

                root.show()
            }
        }

        function toggleMute(): void {
            if (root.ready) {
                root.sink.audio.muted = !root.sink.audio.muted
                root.show()
            }
        }
    }

    OsdPanel {
        anchors.fill: parent

        icon: root.muted ? "󰝟" : ""
        value: root.shownVolume
        minimum: 0
        maximum: root.sliderMaximum
        valueText: root.shownVolume + "%"
        muted: root.muted
        overThreshold: root.overThreshold
    }

    Timer {
        id: hideTimer

        interval: 1000
        repeat: false

        onTriggered: {
            ShellState.volumeOsdOpen = false
        }
    }

    function show() {
        ShellState.volumeOsdOpen = true
        hideTimer.restart()
    }

    Connections {
        target: Pipewire.defaultAudioSink !== null
            ? Pipewire.defaultAudioSink.audio
            : null

        function onVolumeChanged() {
            root.show()
        }

        function onMutedChanged() {
            root.show()
        }
    }
}
