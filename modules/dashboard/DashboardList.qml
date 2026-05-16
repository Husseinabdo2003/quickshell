import QtQuick

import "../../components"
import "../../theme"

Flickable {
    id: root

    property var items: []
    property string activeCategory: "all"
    property bool busy: false

    signal removeRequested(string itemId)

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

    function highPriorityItems() {
        return root.safeItems().filter(function(item) {
            return root.normalizedPriority(item) === "high"
        })
    }

    function categoryItems(category) {
        return root.safeItems().filter(function(item) {
            return root.normalizedCategory(item) === category
                && root.normalizedPriority(item) !== "high"
        })
    }

    function hasAnyItems() {
        return root.safeItems().length > 0
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
                icon: "󰀦"
                items: root.highPriorityItems()
                danger: true
                busy: root.busy

                onRemoveRequested: function(itemId) {
                    root.removeRequested(itemId)
                }
            }

            OverviewSection {
                width: parent.width

                title: "Exams"
                subtitle: "Upcoming exam-related items"
                icon: "󰑴"
                items: root.categoryItems("exams")
                danger: false
                busy: root.busy

                onRemoveRequested: function(itemId) {
                    root.removeRequested(itemId)
                }
            }

            OverviewSection {
                width: parent.width

                title: "Projects"
                subtitle: "Project tasks and deadlines"
                icon: "󰏗"
                items: root.categoryItems("projects")
                danger: false
                busy: root.busy

                onRemoveRequested: function(itemId) {
                    root.removeRequested(itemId)
                }
            }

            OverviewSection {
                width: parent.width

                title: "To-do"
                subtitle: "General tasks"
                icon: "󰄬"
                items: root.categoryItems("todo")
                danger: false
                busy: root.busy

                onRemoveRequested: function(itemId) {
                    root.removeRequested(itemId)
                }
            }
        }

        Column {
            width: parent.width
            spacing: 10

            visible: !root.isOverview() && root.hasAnyItems()

            Repeater {
                model: root.safeItems()

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
                }
            }
        }

        Card {
            visible: !root.hasAnyItems()

            width: parent.width
            height: 160

            cardRadius: 28
            cardColor: Theme.pillBg
            cardBorderColor: WalTheme.border

            Column {
                anchors.centerIn: parent
                spacing: 8

                HeadingText {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: root.isOverview()
                        ? "Nothing in your dashboard"
                        : "No items here"

                    font.pixelSize: 17
                }

                MetaText {
                    anchors.horizontalCenter: parent.horizontalCenter

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
        property string icon: ""
        property var items: []
        property bool danger: false
        property bool busy: false

        signal removeRequested(string itemId)

        spacing: 8
        visible: Array.isArray(items) && items.length > 0

        function safeItems() {
            if (Array.isArray(section.items))
                return section.items

            return []
        }

        Card {
            width: section.width
            height: 54

            cardRadius: 22
            cardColor: Theme.pillBg
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
                    width: Math.max(0, parent.width - 96)
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

                    text: section.safeItems().length + ""

                    accent: !section.danger
                    danger: section.danger
                    muted: false

                    badgeHeight: 24
                    badgeRadius: 12
                    fontSize: 11
                    horizontalPadding: 12
                }
            }
        }

        Column {
            width: section.width
            spacing: 8

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
                }
            }
        }
    }
}