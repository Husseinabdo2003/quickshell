import QtQuick
import Quickshell
import Quickshell.Io

import "../../services"
import "../../theme"

PanelWindow {
    id: root

    property bool opened: false
    property bool animating: false
    property bool addOpen: false
    property string activeCategory: "uni"

    // Main sizing / placement
    readonly property int attachX: 0
    readonly property int attachY: 18
    readonly property int bodyWidth: 420
    readonly property int bodyHeight: 635

    // Top extension dimensions to make it feel like part of the bar
    readonly property int extensionWidth: 250
    readonly property int extensionHeight: 82

    visible: opened || animating

    anchors {
        top: true
        left: true
    }

    implicitWidth: bodyWidth + 20
    implicitHeight: bodyHeight + 120

    color: "transparent"

    function filteredItems() {
        return DashboardData.items.filter(function(item) {
            return item.category === root.activeCategory
        })
    }

    Timer {
        id: animationStopper
        interval: 280
        repeat: false

        onTriggered: {
            root.animating = false
        }
    }

    // This is the top-left "extension" piece.
    // It makes the dashboard feel like it grows from the bar corner.
    Rectangle {
        id: topExtension

        x: root.attachX
        y: root.opened ? root.attachY : -root.extensionHeight - 30

        width: root.extensionWidth
        height: root.extensionHeight

        radius: 26
        color: Qt.rgba(0.03, 0.05, 0.06, 0.94)

        border.width: 1
        border.color: WalTheme.border

        z: 1

        Behavior on y {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }

    // Main body overlaps the extension slightly so it looks like one shape.
    Rectangle {
        id: panel

        x: root.attachX
        y: root.opened ? root.attachY + 40 : -root.bodyHeight - 40

        width: root.bodyWidth
        height: root.bodyHeight

        radius: 34
        color: Qt.rgba(0.03, 0.05, 0.06, 0.94)

        border.width: 1
        border.color: WalTheme.border

        clip: true
        z: 2

        Behavior on y {
            NumberAnimation {
                duration: 260
                easing.type: Easing.OutCubic
            }
        }

        Column {
            id: contentColumn

            anchors.fill: parent
            anchors.margins: 20
            spacing: 13

            Row {
                width: parent.width
                height: 34

                Text {
                    text: "Dashboard"
                    color: WalTheme.fg
                    font.pixelSize: 24
                    font.bold: true
                    width: parent.width - 92
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 88
                    height: 30
                    radius: 15

                    color: root.addOpen ? WalTheme.urgentAlpha : WalTheme.accentAlpha
                    border.width: 1
                    border.color: root.addOpen ? WalTheme.urgent : WalTheme.accent

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
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: WalTheme.border
                opacity: 0.8
            }

            Row {
                width: parent.width
                height: 34
                spacing: 8

                DashboardTab {
                    label: "Uni"
                    selected: root.activeCategory === "uni"
                    onClicked: root.activeCategory = "uni"
                }

                DashboardTab {
                    label: "To-do"
                    selected: root.activeCategory === "todo"
                    onClicked: root.activeCategory = "todo"
                }

                DashboardTab {
                    label: "Projects"
                    selected: root.activeCategory === "projects"
                    onClicked: root.activeCategory = "projects"
                }

                DashboardTab {
                    label: "Exams"
                    selected: root.activeCategory === "exams"
                    onClicked: root.activeCategory = "exams"
                }
            }

            Row {
                width: parent.width
                height: 22

                Text {
                    text: root.activeCategory === "uni" ? "University"
                        : root.activeCategory === "todo" ? "To-do list"
                        : root.activeCategory === "projects" ? "Projects"
                        : "Exams"

                    color: WalTheme.fg
                    font.pixelSize: 16
                    font.bold: true
                    width: parent.width - 70
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
                height: parent.height - 150

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

                            itemType: item.type || ""
                            title: item.title || ""
                            course: item.course || ""
                            date: item.date || ""
                            priority: item.priority || ""
                            status: item.status || ""
                        }
                    }
                }
            }
        }

        // Add popup
        Rectangle {
            id: addPopup

            visible: root.addOpen
            opacity: root.addOpen ? 1 : 0

            anchors.centerIn: parent

            width: parent.width - 38
            height: 282

            radius: 30
            color: Qt.rgba(0.04, 0.06, 0.07, 0.98)

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
                        width: parent.width - 70
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

                        text: root.activeCategory === "exams" ? "exam"
                            : root.activeCategory === "projects" ? "project"
                            : root.activeCategory === "uni" ? "quiz"
                            : "task"
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
                            onClicked: root.addOpen = false
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
    }

    Process {
        id: addProcess
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
            animationStopper.restart()
        }

        function open() {
            root.animating = true
            root.opened = true
            DashboardData.load()
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