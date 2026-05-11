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
        top: 54
        right: 14
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true

    implicitWidth: cardWidth
    implicitHeight: Math.max(1, popupCards.length * (cardHeight + cardGap))

    color: "transparent"
    visible: popupCards.length > 0

    property int cardWidth: 295
    property int cardHeight: 88
    property int cardGap: 8
    property int maxVisibleCards: 6

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
        id: notificationCardComponent

        Rectangle {
            id: card

            property var notification: null
            property real targetY: 0
            property bool opened: false
            property bool closing: false

            signal closeRequested(var cardObject)
            signal removeRequested(var cardObject)

            width: root.cardWidth
            height: root.cardHeight

            x: opened && !closing ? 0 : root.width + 28
            y: targetY
            opacity: opened && !closing ? 1 : 0

            radius: 16
            color: Theme.pillBg

            border.width: 1
            border.color: Theme.border

            Behavior on x {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }

            Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Rectangle {
                    id: appIcon

                    width: 34
                    height: 34
                    radius: 12

                    anchors.verticalCenter: parent.verticalCenter

                    color: Theme.accent

                    Text {
                        anchors.centerIn: parent

                        text: card.notification && card.notification.appName && card.notification.appName.length > 0
                              ? card.notification.appName[0].toUpperCase()
                              : "N"

                        color: Theme.textStrong
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                    }
                }

                Column {
                    width: parent.width - appIcon.width - closeButton.width - 20
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Text {
                        width: parent.width

                        text: card.notification ? card.notification.appName || "Notification" : ""
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width

                        text: card.notification ? card.notification.summary || "" : ""
                        color: Theme.textStrong
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width

                        text: card.notification ? card.notification.body || "" : ""
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        textFormat: Text.PlainText
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    id: closeButton

                    width: 22
                    height: 22
                    radius: 999

                    anchors.top: parent.top

                    color: Theme.pillBg

                    border.width: 1
                    border.color: Theme.border

                    Text {
                        anchors.centerIn: parent

                        text: ""
                        color: Theme.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            card.closeRequested(card)
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    card.closeRequested(card)
                }
            }

            Timer {
                id: autoHideTimer

                interval: 4500
                repeat: false

                onTriggered: {
                    card.closeRequested(card)
                }
            }

            Timer {
                id: removeTimer

                interval: 240
                repeat: false

                onTriggered: {
                    card.removeRequested(card)
                }
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
        const card = notificationCardComponent.createObject(stackArea, {
            notification: notification,
            targetY: 0,
            opened: false,
            closing: false
        })

        if (card === null)
            return

        card.closeRequested.connect(function(cardObject) {
            cardObject.close()
        })

        card.removeRequested.connect(function(cardObject) {
            root.removeCard(cardObject)
        })

        root.popupCards = [card].concat(root.popupCards)

        root.relayoutCards()

        if (root.popupCards.length > root.maxVisibleCards) {
            root.popupCards[root.popupCards.length - 1].close()
        }
    }

    function relayoutCards() {
        for (let i = 0; i < root.popupCards.length; i++) {
            root.popupCards[i].targetY = i * (root.cardHeight + root.cardGap)
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