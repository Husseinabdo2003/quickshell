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

    // ── geometry ──────────────────────────────────────────────────────────
    // barHeight: how tall your top bar is.  The panel's top edge will tuck
    // a few pixels under the bar so the two shapes merge seamlessly.
    readonly property int barHeight:   30
    readonly property int tuckAmount:   6   // px hidden behind bar

    readonly property int bodyWidth:  420
    readonly property int bodyHeight: 635

    // ── positions ─────────────────────────────────────────────────────────
    // Open  → panel top sits tuckAmount px above barHeight (under the bar)
    // Closed → panel is fully above the screen top
    readonly property int panelOpenY:   barHeight - tuckAmount
    readonly property int panelClosedY: -(bodyHeight + 20)

    // ── window ────────────────────────────────────────────────────────────
    visible: opened || animating

    anchors {
        top:  true
        left: true
    }

    // Leave enough room for the panel plus the bar area above it
    implicitWidth:  bodyWidth + 20
    implicitHeight: bodyHeight + barHeight + 20

    color: "transparent"

    // ── helpers ───────────────────────────────────────────────────────────
    function filteredItems() {
        return DashboardData.items.filter(function(item) {
            return item.category === root.activeCategory
        })
    }

    Timer {
        id: animationStopper
        interval: 300
        repeat:   false
        onTriggered: root.animating = false
    }

    // ── connection bridge ─────────────────────────────────────────────────
    // A slim rectangle that "fills" the gap between the bar bottom and the
    // panel top on the left side.  It is the same color as the panel and has
    // no rounded corners, so the two shapes look like one solid piece.
    // It animates in sync with the panel (same easing / duration).
    Rectangle {
        id: bridge

        x: 0
        // Sit exactly at bar bottom; overlap bar by 2 px to kill any seam
        y: root.opened ? (root.barHeight - 2) : root.panelClosedY

        width:  root.tuckAmount + 2   // just wide enough to fill the corner
        height: root.tuckAmount + 4
        color:  Qt.rgba(0.03, 0.05, 0.06, 0.96)
        z: 3   // above panel so no seam shows between the two rects

        Behavior on y {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }
    }

    // ── main panel ────────────────────────────────────────────────────────
    Rectangle {
        id: panel

        x: 0
        y: root.opened ? root.panelOpenY : root.panelClosedY

        width:  root.bodyWidth
        height: root.bodyHeight

        // Flat top-left merges with the bar's bottom-left corner.
        // All other corners stay nicely rounded.
        topLeftRadius:     0
        topRightRadius:    28
        bottomLeftRadius:  34
        bottomRightRadius: 34

        color: Qt.rgba(0.03, 0.05, 0.06, 0.96)

        border.width: 1
        border.color: WalTheme.border

        clip: true
        z: 2

        Behavior on y {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        // ── content ───────────────────────────────────────────────────────
        Column {
            id: contentColumn

            // Extra top margin so content clears the tuck area that sits
            // behind the bar
            anchors.fill:    parent
            anchors.margins: 20
            anchors.topMargin: root.tuckAmount + 20
            spacing: 13

            // Header row ───────────────────────────────────────────────────
            Row {
                width:  parent.width
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
                    width:  88
                    height: 30
                    radius: 15

                    color:        root.addOpen ? WalTheme.urgentAlpha : WalTheme.accentAlpha
                    border.width: 1
                    border.color: root.addOpen ? WalTheme.urgent     : WalTheme.accent

                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text:  root.addOpen ? "Close" : "+ Add"
                        color: WalTheme.fg
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked:   root.addOpen = !root.addOpen
                    }
                }
            }

            // Divider ──────────────────────────────────────────────────────
            Rectangle {
                width:   parent.width
                height:  1
                color:   WalTheme.border
                opacity: 0.8
            }

            // Category tabs ────────────────────────────────────────────────
            Row {
                width:   parent.width
                height:  34
                spacing: 8

                DashboardTab {
                    label:    "Uni"
                    selected: root.activeCategory === "uni"
                    onClicked: root.activeCategory = "uni"
                }

                DashboardTab {
                    label:    "To-do"
                    selected: root.activeCategory === "todo"
                    onClicked: root.activeCategory = "todo"
                }

                DashboardTab {
                    label:    "Projects"
                    selected: root.activeCategory === "projects"
                    onClicked: root.activeCategory = "projects"
                }

                DashboardTab {
                    label:    "Exams"
                    selected: root.activeCategory === "exams"
                    onClicked: root.activeCategory = "exams"
                }
            }

            // Section label + count ────────────────────────────────────────
            Row {
                width:  parent.width
                height: 22

                Text {
                    text: root.activeCategory === "uni"      ? "University"
                        : root.activeCategory === "todo"     ? "To-do list"
                        : root.activeCategory === "projects" ? "Projects"
                        : "Exams"
                    color: WalTheme.fg
                    font.pixelSize: 16
                    font.bold: true
                    width: parent.width - 70
                }

                Text {
                    text:  root.filteredItems().length + " items"
                    color: WalTheme.fgMuted
                    font.pixelSize: 12
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Item list ────────────────────────────────────────────────────
            Flickable {
                id: itemList

                width:  parent.width
                height: parent.height - 150

                contentHeight:  listColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Column {
                    id: listColumn
                    width:   parent.width
                    spacing: 12

                    Repeater {
                        model: root.filteredItems().length

                        UniCard {
                            width: listColumn.width

                            property var filtered: root.filteredItems()
                            property var item:     filtered[index] || ({})

                            itemType: item.type     || ""
                            title:    item.title    || ""
                            course:   item.course   || ""
                            date:     item.date     || ""
                            priority: item.priority || ""
                            status:   item.status   || ""
                        }
                    }
                }
            }
        }

        // ── Add popup ─────────────────────────────────────────────────────
        Rectangle {
            id: addPopup

            visible: root.addOpen
            opacity: root.addOpen ? 1 : 0

            anchors.centerIn: parent

            width:  parent.width - 38
            height: 282
            radius: 30

            color:        Qt.rgba(0.04, 0.06, 0.07, 0.98)
            border.width: 1
            border.color: WalTheme.accent

            Column {
                anchors.fill:    parent
                anchors.margins: 18
                spacing: 10

                Row {
                    width:  parent.width
                    height: 28

                    Text {
                        text:  "Add new item"
                        color: WalTheme.fg
                        font.pixelSize: 18
                        font.bold: true
                        width: parent.width - 70
                    }

                    Text {
                        text:  root.activeCategory
                        color: WalTheme.accent
                        font.pixelSize: 12
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    width:   parent.width
                    spacing: 8

                    DashboardInput {
                        id:    typeInput
                        width: 86
                        label: "type"

                        text: root.activeCategory === "exams"    ? "exam"
                            : root.activeCategory === "projects" ? "project"
                            : root.activeCategory === "uni"      ? "quiz"
                            : "task"
                    }

                    DashboardInput {
                        id:    titleInput
                        width: parent.width - 94
                        label: "title"
                    }
                }

                Row {
                    width:   parent.width
                    spacing: 8

                    DashboardInput {
                        id:    courseInput
                        width: 128
                        label: "course/context"
                    }

                    DashboardInput {
                        id:    dateInput
                        width: 122
                        label: "date"
                        text:  "2026-"
                    }

                    DashboardInput {
                        id:    priorityInput
                        width: parent.width - 266
                        label: "priority"
                        text:  "medium"
                    }
                }

                DashboardInput {
                    id:    statusInput
                    width: parent.width
                    label: "status"
                    text:  "upcoming"
                }

                Row {
                    width:   parent.width
                    height:  42
                    spacing: 10

                    Rectangle {
                        width:  parent.width / 2 - 5
                        height: 42
                        radius: 18
                        color:        Qt.rgba(1, 1, 1, 0.06)
                        border.width: 1
                        border.color: WalTheme.border

                        Text {
                            anchors.centerIn: parent
                            text:  "Cancel"
                            color: WalTheme.fgMuted
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked:    root.addOpen = false
                        }
                    }

                    Rectangle {
                        width:  parent.width / 2 - 5
                        height: 42
                        radius: 18
                        color:        WalTheme.accentAlpha
                        border.width: 1
                        border.color: WalTheme.accent

                        Text {
                            anchors.centerIn: parent
                            text:  "Add"
                            color: WalTheme.fg
                            font.pixelSize: 13
                            font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor

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
                                titleInput.text    = ""
                                root.addOpen       = false
                            }
                        }
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }
        }
    }

    // ── process + IPC ────────────────────────────────────────────────────
    Process {
        id:      addProcess
        command: []
        running: false

        onExited: DashboardData.load()
    }

    IpcHandler {
        target: "dashboard"

        function toggle() {
            root.animating = true
            root.opened    = !root.opened
            root.addOpen   = false
            DashboardData.load()
            animationStopper.restart()
        }

        function open() {
            root.animating = true
            root.opened    = true
            DashboardData.load()
            animationStopper.restart()
        }

        function close() {
            root.animating = true
            root.opened    = false
            root.addOpen   = false
            animationStopper.restart()
        }
    }
}
