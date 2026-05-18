import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: root

    readonly property var player: bestPlayer()
    readonly property bool hasPlayer: player !== null
    readonly property bool hasTrackTitle: root.trackTitle.length > 0

    readonly property string trackTitle: {
        if (!root.hasPlayer || !root.player.trackTitle)
            return ""

        return String(root.player.trackTitle).trim()
    }

    readonly property string trackArtist: {
        if (!root.hasPlayer)
            return ""

        if (root.player.trackArtist && String(root.player.trackArtist).trim().length > 0)
            return String(root.player.trackArtist).trim()

        if (root.player.trackArtists && root.player.trackArtists.length > 0)
            return root.player.trackArtists.join(", ")

        return ""
    }

    readonly property string playerName: {
        if (!root.hasPlayer)
            return ""

        if (root.player.identity && String(root.player.identity).trim().length > 0)
            return String(root.player.identity).trim()

        if (root.player.name && String(root.player.name).trim().length > 0)
            return String(root.player.name).trim()

        return "Media"
    }

    readonly property string trackText: {
        if (root.trackArtist.length > 0 && root.trackTitle.length > 0)
            return root.trackArtist + " - " + root.trackTitle

        if (root.trackTitle.length > 0)
            return root.trackTitle

        return root.playerName
    }

    function bestPlayer() {
        const players = Mpris.players.values

        if (!players || players.length === 0)
            return null

        for (let i = 0; i < players.length; i++) {
            const player = players[i]

            if (root.isUsablePlayingPlayer(player))
                return player
        }

        for (let i = 0; i < players.length; i++) {
            const player = players[i]

            if (root.isUsablePlayer(player))
                return player
        }

        return players[0]
    }

    function isUsablePlayer(player) {
        return player
            && player.trackTitle
            && String(player.trackTitle).trim().length > 0
    }

    function isUsablePlayingPlayer(player) {
        return root.isUsablePlayer(player) && player.isPlaying
    }
}
