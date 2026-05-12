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

    signal removeRequested(string itemId)

    height: 88

    cardRadius: 30
    cardColor: Theme.pillBg
    cardBorderColor: WalTheme.border

    Row {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        AccentStrip {
            height: parent.height - 10
            danger: root.priority === "high"
            accent: root.priority !== "high"

            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: parent.width - 72
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
                    width: parent.width - 96

                    text: root.title
                    font.pixelSize: 15
                }
            }

            Row {
                width: parent.width
                spacing: 10

                MetaText {
                    text: root.course
                    width: parent.width * 0.40
                }

                MetaText {
                    text: root.date
                }

                MetaText {
                    text: root.status
                    width: parent.width * 0.25
                }
            }
        }

        IconButton {
            buttonSize: 34
            buttonRadius: 17
            iconSize: 18

            icon: "×"
            danger: true

            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                root.removeRequested(root.itemId)
            }
        }
    }
}