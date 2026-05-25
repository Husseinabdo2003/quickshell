import QtQuick

Row {
    id: root

    property string activeCategory: "all"
    property int allCount: 0
    property int todoCount: 0
    property int projectsCount: 0
    property int examsCount: 0

    signal categorySelected(string category)

    width: parent ? parent.width : 390
    height: 34

    spacing: 8

    DashboardTab {
        width: (parent.width - parent.spacing * 3) / 4
        height: parent.height

        label: "Overview"
        count: root.allCount
        selected: root.activeCategory === "all"

        onClicked: {
            root.categorySelected("all")
        }
    }

    DashboardTab {
        width: (parent.width - parent.spacing * 3) / 4
        height: parent.height

        label: "To-do"
        count: root.todoCount
        selected: root.activeCategory === "todo"

        onClicked: {
            root.categorySelected("todo")
        }
    }

    DashboardTab {
        width: (parent.width - parent.spacing * 3) / 4
        height: parent.height

        label: "Projects"
        count: root.projectsCount
        selected: root.activeCategory === "projects"

        onClicked: {
            root.categorySelected("projects")
        }
    }

    DashboardTab {
        width: (parent.width - parent.spacing * 3) / 4
        height: parent.height

        label: "Exams"
        count: root.examsCount
        selected: root.activeCategory === "exams"

        onClicked: {
            root.categorySelected("exams")
        }
    }
}
