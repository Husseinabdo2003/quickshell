import QtQuick

QtObject {
    id: root

    property string activeCategory: "all"

    readonly property string categoryTitle: {
        if (activeCategory === "all")
            return "Overview"

        if (activeCategory === "todo")
            return "To-do list"

        if (activeCategory === "projects")
            return "Projects"

        return "Exams"
    }

    readonly property string defaultType: {
        if (activeCategory === "exams")
            return "exam"

        if (activeCategory === "projects")
            return "project"

        return "task"
    }

    readonly property string addCategory: {
        if (activeCategory === "all")
            return "todo"

        return activeCategory
    }

    function safeItems(items) {
        if (Array.isArray(items))
            return items

        return []
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

    function filteredItems(items) {
        const list = root.safeItems(items)

        if (root.activeCategory === "all")
            return list.slice()

        return list.filter(function(item) {
            return root.normalizedCategory(item) === root.activeCategory
        })
    }
}