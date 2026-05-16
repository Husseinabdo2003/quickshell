import QtQuick
import Quickshell

import "../../components"
import "../../theme"

PopupPanel {
    id: root

    property string activeCategory: "todo"
    property string defaultType: "task"
    property bool busy: false

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
    panelBorderColor: root.busy ? WalTheme.border : WalTheme.accent

    opacity: opened ? 1 : 0
    visible: opened

    z: 100

    onDefaultTypeChanged: {
        typeInput.text = root.defaultType
    }

    function focusTitle() {
        if (!root.busy)
            titleInput.forceInputFocus()
    }

    function clearAfterAdd() {
        typeInput.text = root.defaultType
        titleInput.text = ""
        courseInput.text = ""
        dateInput.text = "2026-"
        priorityInput.text = "medium"
        statusInput.text = "upcoming"
    }

    function submit() {
        if (root.busy)
            return

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
                text: root.busy ? "Adding item..." : "Add new item"
                font.pixelSize: 18

                width: Math.max(0, parent.width - 80)
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
                enabled: !root.busy

                onAccepted: {
                    titleInput.forceInputFocus()
                }
            }

            DashboardInput {
                id: titleInput

                width: Math.max(0, parent.width - 94)
                label: "title"
                enabled: !root.busy

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
                enabled: !root.busy

                onAccepted: {
                    dateInput.forceInputFocus()
                }
            }

            DashboardInput {
                id: dateInput

                width: 122
                label: "date"
                text: "2026-"
                enabled: !root.busy

                onAccepted: {
                    priorityInput.forceInputFocus()
                }
            }

            DashboardInput {
                id: priorityInput

                width: Math.max(0, parent.width - 266)
                label: "priority"
                text: "medium"
                enabled: !root.busy

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
            enabled: !root.busy

            onAccepted: {
                root.submit()
            }
        }

        Row {
            width: parent.width
            height: 42
            spacing: 10

            ActionButton {
                width: Math.max(0, parent.width / 2 - 5)
                height: 42

                text: "Cancel"
                muted: true
                buttonRadius: 18
                fontSize: 13
                enabled: !root.busy
                opacity: root.busy ? 0.5 : 1.0

                onClicked: {
                    root.cancelRequested()
                }
            }

            ActionButton {
                width: Math.max(0, parent.width / 2 - 5)
                height: 42

                text: root.busy ? "Adding..." : "Add"
                accent: true
                buttonRadius: 18
                fontSize: 13
                enabled: !root.busy
                opacity: root.busy ? 0.65 : 1.0

                onClicked: {
                    root.submit()
                }
            }
        }
    }
}