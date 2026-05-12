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

    function filteredItems(items) {
        if (root.activeCategory === "all")
            return items

        return items.filter(function(item) {
            return item.category === root.activeCategory
        })
    }
}