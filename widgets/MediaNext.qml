import QtQuick
import "../components"

BarActionPill {
    id: root

    MediaPlayerState {
        id: mediaState
    }

    visible: mediaState.hasTrackTitle && mediaState.player.canGoNext

    icon: ""

    actionWidth: 34
    iconSize: 12

    onClicked: {
        if (mediaState.hasPlayer && mediaState.player.canGoNext)
            mediaState.player.next()
    }
}
