import Quickshell
import QtQuick

import "../../theme"
import "../../services"

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }

    margins {
        top: 58
        right: 14
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true

    implicitWidth: cardWidth
    implicitHeight: Math.max(
        1,
        Math.min(popupCards.length, maxVisibleCards) * (cardHeight + cardGap)
    )

    color: "transparent"
    visible: popupCards.length > 0

    property int cardWidth: 322
    property int cardHeight: 88
    property int cardGap: 10
    property int maxVisibleCards: 5

    property var popupCards: []

    Connections {
        target: NotificationService

        function onPopupAdded(notification) {
            root.addNotification(notification)
        }
    }

    Item {
        id: stackArea

        width: root.cardWidth
        height: root.implicitHeight
    }

    Component {
        id: popupCardComponent

        NotificationCard {
            id: card

            property real targetY: 0
            property bool opened: false
            property bool closing: false

            signal removeRequested(var cardObject)

            width: root.cardWidth
            height: root.cardHeight

            compact: true
            expanded: false

            showAppIcon: true
            showAppName: true
            showCloseButton: true
            showTime: true

            notificationRadius: 26

            x: opened && !closing ? 0 : root.width + 34
            y: targetY

            opacity: opened && !closing ? 1 : 0
            scale: opened && !closing ? 1.0 : 0.975

            Behavior on x {
                NumberAnimation {
                    duration: Animations.popupSlide
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: Animations.layoutMove
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.popupFade
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Animations.popupFade
                    easing.type: Easing.OutCubic
                }
            }

            Timer {
                id: autoHideTimer

                interval: 5200
                repeat: false

                onTriggered: {
                    card.close()
                }
            }

            Timer {
                id: removeTimer

                interval: Animations.popupSlide + 20
                repeat: false

                onTriggered: {
                    card.removeRequested(card)
                }
            }

            onCloseRequested: {
                card.close()
            }

            function close() {
                if (card.closing)
                    return

                card.closing = true
                card.opened = false
                removeTimer.restart()
            }

            Component.onCompleted: {
                Qt.callLater(function() {
                    card.opened = true
                    autoHideTimer.restart()
                })
            }
        }
    }

    function addNotification(notification) {
        const card = popupCardComponent.createObject(stackArea, {
            notification: notification,
            targetY: 0,
            opened: false,
            closing: false
        })

        if (card === null)
            return

        card.removeRequested.connect(function(cardObject) {
            root.removeCard(cardObject)
        })

        root.popupCards = [card].concat(root.popupCards)

        root.relayoutCards()

        if (root.popupCards.length > root.maxVisibleCards)
            root.popupCards[root.popupCards.length - 1].close()
    }

    function relayoutCards() {
        for (let i = 0; i < root.popupCards.length; i++) {
            const card = root.popupCards[i]

            card.targetY = i * (root.cardHeight + root.cardGap)
            card.z = root.popupCards.length - i
        }
    }

    function removeCard(card) {
        const index = root.popupCards.indexOf(card)

        if (index >= 0) {
            const nextCards = root.popupCards.slice()
            nextCards.splice(index, 1)
            root.popupCards = nextCards
        }

        card.destroy()
        root.relayoutCards()
    }
}