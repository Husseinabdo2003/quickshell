import QtQuick

import "../../components"
import "../../theme"

Card {
    id: root

    property string itemId: ""
    property string itemType: ""
    property string title: ""
    property string course: ""
    property string date: ""
    property string priority: ""
    property string status: ""
    property bool busy: false

    signal removeRequested(string itemId)

    height: 88

    cardRadius: 30
    cardColor: Theme.pillBg
    cardBorderColor: WalTheme.border

    opacity: root.busy ? 0.65 : 1.0

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        AccentStrip {
            height: Math.max(0, parent.height - 10)
            danger: root.priority === "high"
            accent: root.priority !== "high"

            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: Math.max(0, parent.width - 72)
            anchors.verticalCenter: parent.verticalCenter
            spacing: 7

            Row {
                width: parent.width
                spacing: 8

                Badge {
                    text: root.itemType.toUpperCase()
                    danger: root.priority === "high"
                    accent: root.priority !== "high"
                    badgeHeight: 22
                    badgeRadius: 11
                    fontSize: 10
                    horizontalPadding: 14
                }

                TitleText {
                    width: Math.max(0, parent.width - 96)

                    text: root.title
                    font.pixelSize: 15
                    elide: Text.ElideRight
                }
            }

            Row {
                width: parent.width
                spacing: 10

                MetaText {
                    text: root.course
                    width: Math.max(0, parent.width * 0.40)
                    elide: Text.ElideRight
                }

                MetaText {
                    text: root.date
                    elide: Text.ElideRight
                }

                MetaText {
                    text: root.status
                    width: Math.max(0, parent.width * 0.25)
                    elide: Text.ElideRight
                }
            }
        }

        IconButton {
            buttonSize: 34
            buttonRadius: 17
            iconSize: 18

            icon: "×"
            danger: true

            enabled: !root.busy
            opacity: root.busy ? 0.45 : 1.0

            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                if (!root.busy)
                    root.removeRequested(root.itemId)
            }
        }
    }
}