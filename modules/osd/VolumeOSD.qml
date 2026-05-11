import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

import "../../theme"
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
                root.sink.audio.volume = Math.min(root.sink.audio.volume + 0.05, root.maxVolume)
                root.show()
            }
        }

        function lower(): void {
            if (root.ready) {
                root.sink.audio.volume = Math.max(root.sink.audio.volume - 0.05, 0)
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

    Rectangle {
        anchors.fill: parent

        radius: 16
        color: Theme.pillBg

        border.width: 1
        border.color: Theme.border

        Row {
            anchors.centerIn: parent
            spacing: 9

            Item {
                width: 24
                height: 24

                Text {
                    anchors.centerIn: parent

                    text: root.muted ? "󰝟" : ""
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                }
            }

            Rectangle {
                width: 115
                height: 5

                anchors.verticalCenter: parent.verticalCenter

                radius: 999
                color: Theme.border

                Rectangle {
                    height: parent.height
                    width: parent.width * Math.min(root.volume, root.maxVolume * 100) / (root.maxVolume * 100)

                    radius: 999
                    color: Theme.accent
                }
            }

            Item {
                width: 42
                height: 24

                Text {
                    anchors.centerIn: parent

                    text: root.muted ? "0%" : root.volume + "%"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }
            }
        }
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
        target: Pipewire.defaultAudioSink !== null ? Pipewire.defaultAudioSink.audio : null

        function onVolumeChanged() {
            root.show()
        }

        function onMutedChanged() {
            root.show()
        }
    }
}