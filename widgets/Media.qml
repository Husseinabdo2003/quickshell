import QtQuick
import Quickshell.Services.Mpris

import "../components"
import "../theme"

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

    property string clippedTrackText: trackText.length > 45
        ? trackText.substring(0, 45) + "…"
        : trackText

    visible: hasPlayer && trackText.length > 0

    label: clippedTrackText
    textColor: hasPlayer && !player.isPlaying ? Theme.textMuted : Theme.text
    strong: false

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.hasPlayer && root.player.canTogglePlaying)
                root.player.togglePlaying()
        }
    }
}