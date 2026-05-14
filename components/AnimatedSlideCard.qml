import QtQuick

import "../theme"

Card {
    id: root

    property bool opened: false

    property real openX: 0
    property real closedX: 0

    property real openY: 0
    property real closedY: 0

    property real openOpacity: 1.0
    property real closedOpacity: 0.0

    property real openScale: 1.0
    property real closedScale: 1.0

    property int openDuration: Animations.panel
    property int closeDuration: Animations.panel

    property int openFadeDuration: Animations.popupFade
    property int closeFadeDuration: Animations.popupFade

    property int popupRadius: 30
    property color popupColor: Theme.pillBg
    property color popupBorderColor: WalTheme.border
    property int popupBorderWidth: 1

    x: root.opened ? root.openX : root.closedX
    y: root.opened ? root.openY : root.closedY

    opacity: root.opened ? root.openOpacity : root.closedOpacity
    scale: root.opened ? root.openScale : root.closedScale

    enabled: root.opened

    cardRadius: root.popupRadius
    cardColor: root.popupColor
    cardBorderColor: root.popupBorderColor
    cardBorderWidth: root.popupBorderWidth

    layer.enabled: true
    layer.smooth: true

    Behavior on x {
        NumberAnimation {
            duration: root.opened ? root.openDuration : root.closeDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on y {
        NumberAnimation {
            duration: root.opened ? root.openDuration : root.closeDuration
            easing.type: Easing.OutCubic
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: root.opened ? root.openFadeDuration : root.closeFadeDuration
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