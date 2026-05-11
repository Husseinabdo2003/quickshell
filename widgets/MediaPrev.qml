import QtQuick
import Quickshell.Services.Mpris

import "../components"

BarPill {
    id: root

    function bestPlayer() {
        const players = Mpris.players.values

        if (!players || players.length === 0)
            return null

        for (let i = 0; i < players.length; i++) {
            const p = players[i]

            if (p && p.isPlaying && p.trackTitle && String(p.trackTitle).length > 0)
                return p
        }

        for (let i = 0; i < players.length; i++) {
            const p = players[i]

            if (p && p.trackTitle && String(p.trackTitle).length > 0)
                return p
        }

        return players[0]
    }

    property var player: bestPlayer()
    property bool usable: player !== null && player.canGoPrevious

    label: ""
    strong: usable
    visible: player !== null

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.usable)
                root.player.previous()
        }
    }
}