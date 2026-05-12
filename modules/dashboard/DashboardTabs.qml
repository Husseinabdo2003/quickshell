import QtQuick

Row {
    id: root

    property string activeCategory: "all"

    signal categorySelected(string category)

    width: parent ? parent.width : 390
    height: 34

    spacing: 8

    DashboardTab {
        width: (parent.width - parent.spacing * 3) / 4
        height: parent.height

        label: "Overview"
        selected: root.activeCategory === "all"

        onClicked: {
            root.categorySelected("all")
        }
    }

    DashboardTab {
        width: (parent.width - parent.spacing * 3) / 4
        height: parent.height

        label: "To-do"
        selected: root.activeCategory === "todo"

        onClicked: {
            root.categorySelected("todo")
        }
    }

    DashboardTab {
        width: (parent.width - parent.spacing * 3) / 4
        height: parent.height

        label: "Projects"
        selected: root.activeCategory === "projects"

        onClicked: {
            root.categorySelected("projects")
        }
    }

    DashboardTab {
        width: (parent.width - parent.spacing * 3) / 4
        height: parent.height

        label: "Exams"
        selected: root.activeCategory === "exams"

        onClicked: {
            root.categorySelected("exams")
        }
    }
}