import QtQuick
import Quickshell.Services.Mpris

import "../components"

BarActionPill {
    id: root

    function bestPlayer() {
        const players = Mpris.players.values

        if (!players || players.length === 0)
            return null

        for (let i = 0; i < players.length; i++) {
            const p = players[i]

            if (
                p
                && p.isPlaying
                && p.trackTitle
                && String(p.trackTitle).length > 0
            ) {
                return p
            }
        }

        for (let i = 0; i < players.length; i++) {
            const p = players[i]

            if (
                p
                && p.trackTitle
                && String(p.trackTitle).length > 0
            ) {
                return p
            }
        }

        return null
    }

    property var player: bestPlayer()

    visible: player !== null
        && player.trackTitle
        && String(player.trackTitle).length > 0
        && player.canGoPrevious

    icon: ""

    actionWidth: 34
    iconSize: 12

    onClicked: {
        if (root.player && root.player.canGoPrevious)
            root.player.previous()
    }
}