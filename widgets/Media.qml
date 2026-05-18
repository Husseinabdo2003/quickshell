import QtQuick
import "../components"

BarMediaPill {
    id: root

    MediaPlayerState {
        id: mediaState
    }

    visible: mediaState.hasPlayer && mediaState.trackText.length > 0

    icon: mediaState.hasPlayer && mediaState.player.isPlaying ? "" : ""
    text: mediaState.trackText
    playing: mediaState.hasPlayer && mediaState.player.isPlaying
    interactive: mediaState.hasPlayer && mediaState.player.canTogglePlaying

    maxCharacters: 45
    iconSize: 12

    onClicked: {
        if (mediaState.hasPlayer && mediaState.player.canTogglePlaying)
            mediaState.player.togglePlaying()
    }
}
