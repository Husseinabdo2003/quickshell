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
        return root.filteredItemsFor(items, root.activeCategory)
    }

    function filteredItemsFor(items, category) {
        const list = root.safeItems(items)
        const cleanCategory = String(category || "all")

        if (cleanCategory === "all")
            return list.slice()

        return list.filter(function(item) {
            return root.normalizedCategory(item) === cleanCategory
        })
    }

    function highPriorityItems(items) {
        return root.safeItems(items).filter(function(item) {
            if (!item || item.priority === undefined || item.priority === null)
                return false

            try {
                const priority = String(item.priority).toLowerCase().trim()
                const status = String(item.status || "").toLowerCase().trim()

                return priority === "high" && status !== "done"
            } catch (error) {
                return false
            }
        })
    }
}
