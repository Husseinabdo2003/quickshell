import QtQuick
import Quickshell.Services.Mpris

import "../components"

BarMediaPill {
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

        return players[0]
    }

    property var player: bestPlayer()
    property bool hasPlayer: player !== null

    property string artist: {
        if (!hasPlayer)
            return ""

        if (player.trackArtist && String(player.trackArtist).length > 0)
            return String(player.trackArtist)

        if (player.trackArtists && player.trackArtists.length > 0)
            return player.trackArtists.join(", ")

        return ""
    }

    property string title: {
        if (!hasPlayer)
            return ""

        if (player.trackTitle && String(player.trackTitle).length > 0)
            return String(player.trackTitle)

        return ""
    }

    property string playerName: {
        if (!hasPlayer)
            return ""

        if (player.identity && String(player.identity).length > 0)
            return String(player.identity)

        if (player.name && String(player.name).length > 0)
            return String(player.name)

        return "Media"
    }

    property string trackText: {
        if (artist.length > 0 && title.length > 0)
            return artist + " - " + title

        if (title.length > 0)
            return title

        return playerName
    }

    visible: hasPlayer && trackText.length > 0

    icon: hasPlayer && player.isPlaying ? "" : ""
    text: trackText
    playing: hasPlayer && player.isPlaying
    interactive: hasPlayer && player.canTogglePlaying

    maxCharacters: 45
    iconSize: 12

    onClicked: {
        if (root.hasPlayer && root.player.canTogglePlaying)
            root.player.togglePlaying()
    }
}