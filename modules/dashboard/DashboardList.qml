import QtQuick

import "../../components"
import "../../theme"

Flickable {
    id: root

    property var items: []
    property string activeCategory: "all"
    property bool busy: false
    property string expandedSection: ""

    signal removeRequested(string itemId)
    signal doneRequested(string itemId, bool done)

    clip: true

    contentWidth: width
    contentHeight: contentColumn.implicitHeight

    boundsBehavior: Flickable.StopAtBounds

    function safeItems() {
        if (Array.isArray(root.items))
            return root.items

        return []
    }

    function isOverview() {
        return root.activeCategory === "all"
    }

    function normalizedPriority(item) {
        if (!item || item.priority === undefined || item.priority === null)
            return ""

        try {
            return String(item.priority).toLowerCase().trim()
        } catch (error) {
            return ""
        }
    }

    function normalizedCategory(item) {
        if (!item || item.category === undefined || item.category === null)
            return ""

        try {
            return String(item.category).toLowerCase().trim()
        } catch (error) {
            return ""
        }
    }

    function normalizedStatus(item) {
        if (!item || item.status === undefined || item.status === null)
            return ""

        try {
            return String(item.status).toLowerCase().trim()
        } catch (error) {
            return ""
        }
    }

    function isDone(item) {
        return root.normalizedStatus(item) === "done"
    }

    function sortedItems(items) {
        const list = Array.isArray(items) ? items.slice() : []

        list.sort(function(a, b) {
            const aDone = root.isDone(a)
            const bDone = root.isDone(b)

            if (aDone !== bDone)
                return aDone ? 1 : -1

            return 0
        })

        return list
    }

    function highPriorityItems() {
        return root.safeItems().filter(function(item) {
            return root.normalizedPriority(item) === "high" && !root.isDone(item)
        })
    }

    function categoryItems(category) {
        return root.safeItems().filter(function(item) {
            return root.normalizedCategory(item) === category
                && (root.normalizedPriority(item) !== "high" || root.isDone(item))
        })
    }

    function hasAnyItems() {
        return root.safeItems().length > 0
    }

    function toggleSection(sectionId) {
        root.expandedSection = root.expandedSection === sectionId ? "" : sectionId
    }

    onActiveCategoryChanged: {
        root.expandedSection = ""
    }

    Column {
        id: contentColumn

        width: root.width
        spacing: 12

        Item {
            width: parent.width
            height: 1
            visible: root.hasAnyItems()
        }

        Column {
            width: parent.width
            spacing: 12
            visible: root.isOverview() && root.hasAnyItems()

            OverviewSection {
                width: parent.width

                title: "High priority"
                subtitle: "Needs attention first"
                sectionId: "high"
                icon: "󰀦"
                items: root.highPriorityItems()
                danger: true
                busy: root.busy
                expanded: root.expandedSection === "high"

                onToggleRequested: function(sectionId) {
                    root.toggleSection(sectionId)
                }

                onRemoveRequested: function(itemId) {
                    root.removeRequested(itemId)
                }

                onDoneRequested: function(itemId, done) {
                    root.doneRequested(itemId, done)
                }
            }

            OverviewSection {
                width: parent.width

                title: "Exams"
                subtitle: "Upcoming exam-related items"
                sectionId: "exams"
                icon: "󰑴"
                items: root.categoryItems("exams")
                danger: false
                busy: root.busy
                expanded: root.expandedSection === "exams"

                onToggleRequested: function(sectionId) {
                    root.toggleSection(sectionId)
                }

                onRemoveRequested: function(itemId) {
                    root.removeRequested(itemId)
                }

                onDoneRequested: function(itemId, done) {
                    root.doneRequested(itemId, done)
                }
            }

            OverviewSection {
                width: parent.width

                title: "Projects"
                subtitle: "Project tasks and deadlines"
                sectionId: "projects"
                icon: "󰏗"
                items: root.categoryItems("projects")
                danger: false
                busy: root.busy
                expanded: root.expandedSection === "projects"

                onToggleRequested: function(sectionId) {
                    root.toggleSection(sectionId)
                }

                onRemoveRequested: function(itemId) {
                    root.removeRequested(itemId)
                }

                onDoneRequested: function(itemId, done) {
                    root.doneRequested(itemId, done)
                }
            }

            OverviewSection {
                width: parent.width

                title: "To-do"
                subtitle: "General tasks"
                sectionId: "todo"
                icon: "󰄬"
                items: root.categoryItems("todo")
                danger: false
                busy: root.busy
                expanded: root.expandedSection === "todo"

                onToggleRequested: function(sectionId) {
                    root.toggleSection(sectionId)
                }

                onRemoveRequested: function(itemId) {
                    root.removeRequested(itemId)
                }

                onDoneRequested: function(itemId, done) {
                    root.doneRequested(itemId, done)
                }
            }
        }

        Column {
            width: parent.width
            spacing: 10

            visible: !root.isOverview() && root.hasAnyItems()

            Repeater {
                model: root.sortedItems(root.safeItems())

                UniCard {
                    required property var modelData

                    width: contentColumn.width

                    itemId: String(modelData.id || "")
                    itemType: String(modelData.type || "")
                    title: String(modelData.title || "")
                    course: String(modelData.course || "")
                    date: String(modelData.date || "")
                    priority: String(modelData.priority || "")
                    status: String(modelData.status || "")
                    busy: root.busy

                    onRemoveRequested: function(itemId) {
                        root.removeRequested(itemId)
                    }

                    onDoneRequested: function(itemId, done) {
                        root.doneRequested(itemId, done)
                    }
                }
            }
        }

        Card {
            visible: !root.hasAnyItems()

            width: parent.width
            height: 178

            cardRadius: 28
            cardColor: Qt.rgba(1, 1, 1, 0.035)
            cardBorderColor: WalTheme.border

            Column {
                anchors.centerIn: parent
                spacing: 10

                Rectangle {
                    width: 46
                    height: 46
                    radius: 18

                    anchors.horizontalCenter: parent.horizontalCenter

                    color: WalTheme.accentAlpha
                    border.width: 1
                    border.color: WalTheme.accent

                    Text {
                        anchors.centerIn: parent

                        text: root.isOverview() ? "󰄬" : "+"
                        color: WalTheme.fg

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 19
                        font.bold: true
                    }
                }

                HeadingText {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.isOverview()
                        ? "Nothing in your dashboard"
                        : "No items here"

                    font.pixelSize: 17
                }

                MetaText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(260, root.width - 42)
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap

                    text: root.isOverview()
                        ? "Add tasks, projects, or exams to start tracking them."
                        : "Add a new item in this category."

                    font.pixelSize: 12
                }
            }
        }

        Item {
            width: parent.width
            height: 8
        }
    }

    component OverviewSection: Column {
        id: section

        property string title: ""
        property string subtitle: ""
        property string sectionId: ""
        property string icon: ""
        property var items: []
        property bool danger: false
        property bool busy: false
        property bool expanded: false

        signal removeRequested(string itemId)
        signal doneRequested(string itemId, bool done)
        signal toggleRequested(string sectionId)

        spacing: 8
        visible: Array.isArray(items) && items.length > 0

        function safeItems() {
            if (Array.isArray(section.items))
                return root.sortedItems(section.items)

            return []
        }

        Card {
            width: section.width
            height: 54

            cardRadius: 22
            cardColor: section.danger && section.expanded ? WalTheme.urgentAlpha : Qt.rgba(1, 1, 1, 0.045)
            cardBorderColor: section.danger ? WalTheme.urgent : WalTheme.border

            Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Rectangle {
                    width: 30
                    height: 30
                    radius: 12

                    anchors.verticalCenter: parent.verticalCenter

                    color: section.danger
                        ? WalTheme.urgentAlpha
                        : WalTheme.accentAlpha

                    border.width: 1
                    border.color: section.danger
                        ? WalTheme.urgent
                        : WalTheme.accent

                    Text {
                        anchors.centerIn: parent

                        text: section.icon
                        color: WalTheme.fg

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        font.bold: true
                    }
                }

                Column {
                    width: Math.max(0, parent.width - 138)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    TitleText {
                        width: parent.width

                        text: section.title
                        font.pixelSize: 13
                    }

                    MetaText {
                        width: parent.width

                        text: section.subtitle
                        font.pixelSize: 11
                    }
                }

                Badge {
                    anchors.verticalCenter: parent.verticalCenter

                    text: section.safeItems().length === 1
                        ? "1 item"
                        : section.safeItems().length + " items"

                    accent: !section.danger
                    danger: section.danger
                    muted: false

                    badgeHeight: 24
                    badgeRadius: 12
                    fontSize: 11
                    horizontalPadding: 12
                }

                Rectangle {
                    width: 26
                    height: 26
                    radius: 13

                    anchors.verticalCenter: parent.verticalCenter

                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: WalTheme.border

                    Text {
                        anchors.centerIn: parent

                        text: section.expanded ? "" : ""
                        color: WalTheme.fgMuted

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    section.toggleRequested(section.sectionId)
                }
            }
        }

        Column {
            width: section.width
            spacing: 8
            visible: section.expanded

            Repeater {
                model: section.safeItems()

                UniCard {
                    required property var modelData

                    width: section.width

                    itemId: String(modelData.id || "")
                    itemType: String(modelData.type || "")
                    title: String(modelData.title || "")
                    course: String(modelData.course || "")
                    date: String(modelData.date || "")
                    priority: String(modelData.priority || "")
                    status: String(modelData.status || "")
                    busy: section.busy

                    onRemoveRequested: function(itemId) {
                        section.removeRequested(itemId)
                    }

                    onDoneRequested: function(itemId, done) {
                        section.doneRequested(itemId, done)
                    }
                }
            }
        }
    }
}
