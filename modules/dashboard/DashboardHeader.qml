import QtQuick

import "../../components"
import "../../theme"

Row {
    id: root

    property bool addOpen: false
    property bool busy: false

    signal addClicked()

    width: parent ? parent.width : 390
    height: 34

    HeadingText {
        text: "Dashboard"

        width: Math.max(0, parent.width - 100)
        anchors.verticalCenter: parent.verticalCenter
    }

    ActionButton {
        width: 92
        height: 30

        text: root.busy
            ? "Working"
            : root.addOpen
                ? "Close"
                : "+ Add"

        accent: !root.addOpen && !root.busy
        danger: root.addOpen && !root.busy
        muted: root.busy

        buttonRadius: 15
        fontSize: 12

        enabled: !root.busy
        opacity: root.busy ? 0.65 : 1.0

        anchors.verticalCenter: parent.verticalCenter

        onClicked: {
            root.addClicked()
        }
    }
}