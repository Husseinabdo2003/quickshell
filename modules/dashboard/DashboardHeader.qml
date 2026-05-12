import QtQuick

import "../../components"
import "../../theme"

Row {
    id: root

    property bool addOpen: false

    signal addClicked()

    width: parent ? parent.width : 390
    height: 34

    HeadingText {
        text: "Dashboard"

        width: parent.width - 100
        anchors.verticalCenter: parent.verticalCenter
    }

    ActionButton {
        width: 92
        height: 30

        text: root.addOpen ? "Close" : "+ Add"
        accent: !root.addOpen
        danger: root.addOpen
        buttonRadius: 15
        fontSize: 12

        anchors.verticalCenter: parent.verticalCenter

        onClicked: {
            root.addClicked()
        }
    }
}