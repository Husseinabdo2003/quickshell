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
    readonly property bool done: String(root.status || "").toLowerCase().trim() === "done"

    signal removeRequested(string itemId)
    signal doneRequested(string itemId, bool done)

    height: 84

    cardRadius: 24
    cardColor: Theme.pillBg
    cardBorderColor: root.done ? Qt.rgba(1, 1, 1, 0.16) : root.priority === "high" ? WalTheme.urgent : WalTheme.border

    opacity: root.busy ? 0.65 : root.done ? 0.72 : 1.0

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Rectangle {
            width: 30
            height: 30
            radius: 15

            anchors.verticalCenter: parent.verticalCenter

            color: root.done
                ? WalTheme.accentAlpha
                : Qt.rgba(1, 1, 1, 0.04)

            border.width: 1
            border.color: root.done
                ? WalTheme.accent
                : root.priority === "high"
                    ? WalTheme.urgent
                    : WalTheme.border

            Text {
                anchors.centerIn: parent

                text: root.done ? "✓" : ""
                color: WalTheme.fg

                font.pixelSize: 15
                font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (!root.busy)
                        root.doneRequested(root.itemId, !root.done)
                }
            }
        }

        Column {
            width: Math.max(0, parent.width - 78)
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

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
                    muted: root.done
                    font.strikeout: root.done
                    elide: Text.ElideRight
                }
            }

            Row {
                width: parent.width
                spacing: 10

                MetaText {
                    text: root.course.length > 0 ? root.course : "General"
                    width: Math.max(0, parent.width * 0.40)
                    elide: Text.ElideRight
                }

                MetaText {
                    text: root.date.length > 0 ? root.date : "No date"
                    elide: Text.ElideRight
                }

                MetaText {
                    text: root.status.length > 0 ? root.status : "upcoming"
                    width: Math.max(0, parent.width * 0.25)
                    accentText: root.done
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
