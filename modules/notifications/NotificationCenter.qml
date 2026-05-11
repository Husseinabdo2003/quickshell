import Quickshell
import QtQuick
import Quickshell.Io

import "../../theme"
import "../../services"

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
        bottom: true
    }

    margins {
        top: 52
        right: 14
        bottom: 14
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true

    implicitWidth: 360
    color: "transparent"
    visible: ShellState.notificationCenterOpen

    IpcHandler {
        target: "notificationCenter"

        function toggle(): void {
            ShellState.notificationCenterOpen = !ShellState.notificationCenterOpen
            NotificationService.rebuildGroups()
        }

        function open(): void {
            ShellState.notificationCenterOpen = true
            NotificationService.rebuildGroups()
        }

        function close(): void {
            ShellState.notificationCenterOpen = false
        }

        function clear(): void {
            NotificationService.clearAll()
        }
    }

    Rectangle {
        anchors.fill: parent

        radius: 30
        color: Theme.pillBg

        border.width: 1
        border.color: Theme.border

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Row {
                width: parent.width
                height: 32

                Text {
                    id: titleText

                    anchors.verticalCenter: parent.verticalCenter

                    text: "Notifications"
                    color: Theme.textStrong
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                }

                Item {
                    width: parent.width - titleText.width - clearButton.width
                    height: 1
                }

                Rectangle {
                    id: clearButton

                    width: 68
                    height: 28
                    radius: Theme.radius

                    color: Theme.pillBg
                    border.width: 1
                    border.color: Theme.border

                    Text {
                        anchors.centerIn: parent

                        text: "Clear"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            NotificationService.clearAll()
                        }
                    }
                }
            }

            Text {
                visible: NotificationService.appGroups.length === 0

                anchors.horizontalCenter: parent.horizontalCenter

                text: "No notifications"
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            Flickable {
                width: parent.width
                height: parent.height - 42

                contentHeight: groupsColumn.implicitHeight
                clip: true

                Column {
                    id: groupsColumn

                    width: parent.width
                    spacing: 14

                    Repeater {
                        model: NotificationService.appGroups

                        Column {
                            id: group

                            required property var modelData

                            property bool expanded: NotificationService.expandedGroupKey === modelData.key
                            property var latest: modelData.latest

                            width: groupsColumn.width
                            spacing: 8

                            Row {
                                width: parent.width
                                height: 28

                                Text {
                                    width: parent.width - groupButtons.width

                                    anchors.verticalCenter: parent.verticalCenter

                                    text: group.modelData.name + "  " + group.modelData.items.length
                                    color: Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Row {
                                    id: groupButtons

                                    width: 54
                                    height: parent.height
                                    spacing: 6

                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 999

                                        color: Theme.pillBg
                                        border.width: 1
                                        border.color: Theme.border

                                        Text {
                                            anchors.centerIn: parent

                                            text: group.expanded ? "" : ""
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 10
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                NotificationService.toggleGroup(group.modelData.key)
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 999

                                        color: Theme.pillBg
                                        border.width: 1
                                        border.color: Theme.border

                                        Text {
                                            anchors.centerIn: parent

                                            text: ""
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 10
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                NotificationService.clearGroup(group.modelData.key)
                                            }
                                        }
                                    }
                                }
                            }

                            Repeater {
                                model: group.expanded ? group.modelData.items : [group.latest]

                                Rectangle {
                                    id: notificationCard

                                    required property var modelData

                                    width: group.width
                                    height: Math.max(86, notificationContent.implicitHeight + 26)

                                    radius: 22
                                    color: Theme.pillBg

                                    border.width: 1
                                    border.color: Theme.border

                                    Column {
                                        id: notificationContent

                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 5

                                        Row {
                                            width: parent.width
                                            height: 18

                                            Text {
                                                width: parent.width - 28

                                                text: notificationCard.modelData.summary || ""
                                                color: Theme.textStrong
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 13
                                                font.bold: true
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                width: 24

                                                text: ""
                                                color: Theme.textMuted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 11
                                                horizontalAlignment: Text.AlignRight

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor

                                                    onClicked: {
                                                        NotificationService.dismiss(notificationCard.modelData)
                                                    }
                                                }
                                            }
                                        }

                                        Text {
                                            width: parent.width

                                            text: notificationCard.modelData.body || ""
                                            color: Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 12
                                            textFormat: Text.PlainText
                                            wrapMode: Text.WordWrap
                                            maximumLineCount: group.expanded ? 3 : 2
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton
                                        cursorShape: Qt.PointingHandCursor

                                        onClicked: {
                                            if (!group.expanded)
                                                NotificationService.toggleGroup(group.modelData.key)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}