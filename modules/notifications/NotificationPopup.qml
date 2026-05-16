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
        Math.min(root.activeCardCount(), root.maxVisibleCards) * (root.cardHeight + root.cardGap)
    )

    color: "transparent"
    visible: root.popupCards.length > 0

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
            property bool removedByStack: false

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
                if (card.closing || card.removedByStack)
                    return

                card.closing = true
                card.opened = false
                autoHideTimer.stop()
                removeTimer.restart()
            }

            Component.onCompleted: {
                Qt.callLater(function() {
                    if (!card.removedByStack) {
                        card.opened = true
                        autoHideTimer.restart()
                    }
                })
            }
        }
    }

    function activeCardCount() {
        let count = 0

        for (let i = 0; i < root.popupCards.length; i++) {
            const card = root.popupCards[i]

            if (card && !card.closing && !card.removedByStack)
                count += 1
        }

        return count
    }

    function addNotification(notification) {
        if (!notification)
            return

        const card = popupCardComponent.createObject(stackArea, {
            notification: notification,
            targetY: 0,
            opened: false,
            closing: false,
            removedByStack: false
        })

        if (card === null)
            return

        card.removeRequested.connect(function(cardObject) {
            root.removeCard(cardObject)
        })

        root.popupCards = [card].concat(root.popupCards)

        root.relayoutCards()

        root.trimOverflow()
    }

    function trimOverflow() {
        const visibleCards = root.popupCards.filter(function(card) {
            return card && !card.closing && !card.removedByStack
        })

        while (visibleCards.length > root.maxVisibleCards) {
            const oldCard = visibleCards.pop()

            if (oldCard)
                oldCard.close()
        }
    }

    function relayoutCards() {
        let visibleIndex = 0

        for (let i = 0; i < root.popupCards.length; i++) {
            const card = root.popupCards[i]

            if (!card || card.removedByStack)
                continue

            if (card.closing) {
                card.z = 0
                continue
            }

            card.targetY = visibleIndex * (root.cardHeight + root.cardGap)
            card.z = root.popupCards.length - visibleIndex

            visibleIndex += 1
        }
    }

    function removeCard(card) {
        if (!card || card.removedByStack)
            return

        card.removedByStack = true

        const index = root.popupCards.indexOf(card)

        if (index >= 0) {
            const nextCards = root.popupCards.slice()
            nextCards.splice(index, 1)
            root.popupCards = nextCards
        }

        root.relayoutCards()

        try {
            card.destroy()
        } catch (error) {
            console.log("Popup notification destroy failed:", error)
        }
    }
}