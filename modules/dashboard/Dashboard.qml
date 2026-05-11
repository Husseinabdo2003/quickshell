import QtQuick
import Quickshell
import Quickshell.Io

import "../../services"
import "../../theme"

PopupWindow {
    id: root

    property var anchorWindow
    property var attachItem

    property bool opened: false
    property bool animating: false
    property bool addOpen: false
    property string activeCategory: "todo"

    readonly property int panelWidth: 430
    readonly property int panelHeight: 610
    readonly property int addPopupWidth: 430
    readonly property int addPopupHeight: 292
    readonly property int addPopupY: 170
    readonly property int gapFromBar: 6

    implicitWidth: anchorWindow ? anchorWindow.width : panelWidth
    implicitHeight: panelHeight + 40

    visible: opened || animating
    color: "transparent"

    anchor.window: anchorWindow
    anchor.rect.x: 0
    anchor.rect.y: Theme.barHeight + gapFromBar
    anchor.rect.width: anchorWindow ? anchorWindow.width : panelWidth
    anchor.rect.height: panelHeight

    grabFocus: true

    function filteredItems() {
        return DashboardData.items.filter(function(item) {
            return item.category === root.activeCategory
        })
    }

    function categoryTitle() {
        if (root.activeCategory === "todo")
            return "To-do list"

        if (root.activeCategory === "projects")
            return "Projects"

        return "Exams"
    }

    function defaultType() {
        if (root.activeCategory === "exams")
            return "exam"

        if (root.activeCategory === "projects")
            return "project"

        return "task"
    }

    Timer {
        id: animationStopper

        interval: 260
        repeat: false

        onTriggered: {
            root.animating = false
        }
    }

    Rectangle {
        id: panel

        x: (root.implicitWidth - root.panelWidth) / 2
        y: root.opened ? 0 : -height - 24

        width: root.panelWidth
        height: root.panelHeight

        radius: 30
        color: Qt.rgba(0.025, 0.035, 0.04, 0.96)

        border.width: 1
        border.color: WalTheme.border

        clip: true

        Behavior on y {
            NumberAnimation {
                duration: 240
                easing.type: Easing.OutCubic
            }
        }

        Column {
            id: contentColumn

            anchors.fill: parent
            anchors.margins: 20

            spacing: 14

            Row {
                width: parent.width
                height: 34

                Text {
                    text: "Dashboard"
                    color: WalTheme.fg
                    font.pixelSize: 24
                    font.bold: true

                    width: parent.width - 100
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 92
                    height: 30
                    radius: 15

                    color: root.addOpen
                        ? WalTheme.urgentAlpha
                        : WalTheme.accentAlpha

                    border.width: 1
                    border.color: root.addOpen
                        ? WalTheme.urgent
                        : WalTheme.accent

                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent

                        text: root.addOpen ? "Close" : "+ Add"
                        color: WalTheme.fg
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.addOpen = !root.addOpen

                            if (root.addOpen) {
                                titleInput.forceInputFocus()
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1

                color: WalTheme.border
                opacity: 0.75
            }

            Row {
                width: parent.width
                height: 34
                spacing: 8

                DashboardTab {
                    label: "To-do"
                    selected: root.activeCategory === "todo"

                    onClicked: {
                        root.activeCategory = "todo"
                    }
                }

                DashboardTab {
                    label: "Projects"
                    selected: root.activeCategory === "projects"

                    onClicked: {
                        root.activeCategory = "projects"
                    }
                }

                DashboardTab {
                    label: "Exams"
                    selected: root.activeCategory === "exams"

                    onClicked: {
                        root.activeCategory = "exams"
                    }
                }
            }

            Row {
                width: parent.width
                height: 24

                Text {
                    text: root.categoryTitle()

                    color: WalTheme.fg
                    font.pixelSize: 16
                    font.bold: true

                    width: parent.width - 80
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.filteredItems().length + " items"
                    color: WalTheme.fgMuted
                    font.pixelSize: 12

                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Flickable {
                id: itemList

                width: parent.width
                height: parent.height - 146

                contentHeight: listColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Column {
                    id: listColumn

                    width: parent.width
                    spacing: 12

                    Repeater {
                        model: root.filteredItems().length

                        UniCard {
                            width: listColumn.width

                            property var filtered: root.filteredItems()
                            property var item: filtered[index] || ({})

                            itemId: item.id || ""
                            itemType: item.type || ""
                            title: item.title || ""
                            course: item.course || ""
                            date: item.date || ""
                            priority: item.priority || ""
                            status: item.status || ""

                            onRemoveRequested: function(itemId) {
                                removeProcess.command = [
                                    Quickshell.env("HOME") + "/.config/hypr/scripts/dashboard-remove.lua",
                                    itemId
                                ]

                                removeProcess.running = true
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: addPopup

        visible: root.addOpen
        opacity: root.addOpen ? 1 : 0
        z: 100

        x: (root.implicitWidth - root.addPopupWidth) / 2
        y: root.addPopupY

        width: root.addPopupWidth
        height: root.addPopupHeight

        radius: 28
        color: Qt.rgba(0.035, 0.045, 0.055, 0.985)

        border.width: 1
        border.color: WalTheme.accent

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            Row {
                width: parent.width
                height: 28

                Text {
                    text: "Add new item"
                    color: WalTheme.fg
                    font.pixelSize: 18
                    font.bold: true

                    width: parent.width - 80
                }

                Text {
                    text: root.activeCategory
                    color: WalTheme.accent
                    font.pixelSize: 12
                    font.bold: true

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
                    text: root.defaultType()
                }

                DashboardInput {
                    id: titleInput

                    width: parent.width - 94
                    label: "title"
                }
            }

            Row {
                width: parent.width
                spacing: 8

                DashboardInput {
                    id: courseInput

                    width: 128
                    label: "course/context"
                }

                DashboardInput {
                    id: dateInput

                    width: 122
                    label: "date"
                    text: "2026-"
                }

                DashboardInput {
                    id: priorityInput

                    width: parent.width - 266
                    label: "priority"
                    text: "medium"
                }
            }

            DashboardInput {
                id: statusInput

                width: parent.width
                label: "status"
                text: "upcoming"
            }

            Row {
                width: parent.width
                height: 42
                spacing: 10

                Rectangle {
                    width: parent.width / 2 - 5
                    height: 42
                    radius: 18

                    color: Qt.rgba(1, 1, 1, 0.06)

                    border.width: 1
                    border.color: WalTheme.border

                    Text {
                        anchors.centerIn: parent

                        text: "Cancel"
                        color: WalTheme.fgMuted
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.addOpen = false
                        }
                    }
                }

                Rectangle {
                    width: parent.width / 2 - 5
                    height: 42
                    radius: 18

                    color: WalTheme.accentAlpha

                    border.width: 1
                    border.color: WalTheme.accent

                    Text {
                        anchors.centerIn: parent

                        text: "Add"
                        color: WalTheme.fg
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (titleInput.text.trim().length === 0)
                                return

                            addProcess.command = [
                                Quickshell.env("HOME") + "/.config/hypr/scripts/dashboard-add.lua",
                                root.activeCategory,
                                typeInput.text,
                                titleInput.text,
                                courseInput.text,
                                dateInput.text,
                                priorityInput.text,
                                statusInput.text
                            ]

                            addProcess.running = true

                            titleInput.text = ""
                            root.addOpen = false
                        }
                    }
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 140
                easing.type: Easing.OutCubic
            }
        }
    }

    Process {
        id: addProcess

        command: []
        running: false

        onExited: {
            DashboardData.load()
        }
    }

    Process {
        id: removeProcess

        command: []
        running: false

        onExited: {
            DashboardData.load()
        }
    }

    IpcHandler {
        target: "dashboard"

        function toggle() {
            root.animating = true
            root.opened = !root.opened
            root.addOpen = false

            DashboardData.load()

            if (root.visible)
                root.anchor.updateAnchor()

            animationStopper.restart()
        }

        function open() {
            root.animating = true
            root.opened = true

            DashboardData.load()

            if (root.visible)
                root.anchor.updateAnchor()

            animationStopper.restart()
        }

        function close() {
            root.animating = true
            root.opened = false
            root.addOpen = false

            animationStopper.restart()
        }
    }
}