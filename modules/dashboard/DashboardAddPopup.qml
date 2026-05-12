import QtQuick
import Quickshell

import "../../components"
import "../../theme"

PopupPanel {
    id: root

    property string activeCategory: "todo"
    property string defaultType: "task"

    signal cancelRequested()
    signal addRequested(
        string type,
        string title,
        string course,
        string date,
        string priority,
        string status
    )

    width: 430
    height: 292

    openY: 170
    closedY: 170

    panelRadius: 28
    animationDuration: 140

    panelColor: Theme.pillBg
    panelBorderColor: WalTheme.accent

    opacity: opened ? 1 : 0
    visible: opened

    z: 100

    function focusTitle() {
        titleInput.forceInputFocus()
    }

    function clearAfterAdd() {
        titleInput.text = ""
    }

    function submit() {
        if (titleInput.text.trim().length === 0)
            return

        root.addRequested(
            typeInput.text,
            titleInput.text,
            courseInput.text,
            dateInput.text,
            priorityInput.text,
            statusInput.text
        )

        root.clearAfterAdd()
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 18

        spacing: 10

        Row {
            width: parent.width
            height: 28

            TitleText {
                text: "Add new item"
                font.pixelSize: 18

                width: parent.width - 80
            }

            MetaText {
                text: root.activeCategory
                accentText: true
                boldText: true

                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            width: parent.width
            spacing: 8

            DashboardInput {
                id: typeInput

                width: 86
                label: "type"
                text: root.defaultType

                onAccepted: {
                    titleInput.forceInputFocus()
                }
            }

            DashboardInput {
                id: titleInput

                width: parent.width - 94
                label: "title"

                onAccepted: {
                    courseInput.forceInputFocus()
                }
            }
        }

        Row {
            width: parent.width
            spacing: 8

            DashboardInput {
                id: courseInput

                width: 128
                label: "course/context"

                onAccepted: {
                    dateInput.forceInputFocus()
                }
            }

            DashboardInput {
                id: dateInput

                width: 122
                label: "date"
                text: "2026-"

                onAccepted: {
                    priorityInput.forceInputFocus()
                }
            }

            DashboardInput {
                id: priorityInput

                width: parent.width - 266
                label: "priority"
                text: "medium"

                onAccepted: {
                    statusInput.forceInputFocus()
                }
            }
        }

        DashboardInput {
            id: statusInput

            width: parent.width
            label: "status"
            text: "upcoming"

            onAccepted: {
                root.submit()
            }
        }

        Row {
            width: parent.width
            height: 42
            spacing: 10

            ActionButton {
                width: parent.width / 2 - 5
                height: 42

                text: "Cancel"
                muted: true
                buttonRadius: 18
                fontSize: 13

                onClicked: {
                    root.cancelRequested()
                }
            }

            ActionButton {
                width: parent.width / 2 - 5
                height: 42

                text: "Add"
                accent: true
                buttonRadius: 18
                fontSize: 13

                onClicked: {
                    root.submit()
                }
            }
        }
    }
}