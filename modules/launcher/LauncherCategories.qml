import QtQuick

import "../../components"

Row {
    id: root

    property string activeCategory: "all"

    signal categorySelected(string category)

    width: parent ? parent.width : 580
    height: 32
    spacing: 8

    CategoryButton {
        width: (parent.width - parent.spacing * 4) / 5
        label: "All"
        category: "all"
    }

    CategoryButton {
        width: (parent.width - parent.spacing * 4) / 5
        label: "Terminal"
        category: "terminal"
    }

    CategoryButton {
        width: (parent.width - parent.spacing * 4) / 5
        label: "Browser"
        category: "browser"
    }

    CategoryButton {
        width: (parent.width - parent.spacing * 4) / 5
        label: "Files"
        category: "files"
    }

    CategoryButton {
        width: (parent.width - parent.spacing * 4) / 5
        label: "Settings"
        category: "settings"
    }

    component CategoryButton: ActionButton {
        property string label: ""
        property string category: ""

        height: 32

        text: label
        accent: root.activeCategory === category
        muted: root.activeCategory !== category
        buttonRadius: 16
        fontSize: 11

        onClicked: {
            root.categorySelected(category)
        }
    }
}