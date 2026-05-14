import QtQuick

import "../components"
import "../theme"

Card {
    id: root

    property bool opened: false

    property real openedOpacity: 1.0
    property real closedOpacity: 0.0

    property real openedScale: 1.0
    property real closedScale: 0.92

    property int openDuration: Animations.panel
    property int closeDuration: Animations.popupFade

    property int popupRadius: 30
    property color popupColor: Theme.pillBg
    property color popupBorderColor: WalTheme.border

    cardRadius: popupRadius
    cardColor: popupColor
    cardBorderColor: popupBorderColor

    opacity: opened ? openedOpacity : closedOpacity
    scale: opened ? openedScale : closedScale

    enabled: opened

    layer.enabled: true
    layer.smooth: true

    Behavior on opacity {
        NumberAnimation {
            duration: root.opened ? root.openDuration : root.closeDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.opened ? root.openDuration : root.closeDuration
            easing.type: Easing.OutCubic
        }
    }
}