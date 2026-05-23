import QtQuick

import "../theme"

Rectangle {
    id: root

    property bool opened: false
    property string title: ""
    property string label: ""
    property string placeholder: ""
    property string value: ""
    property string acceptText: "OK"
    property bool danger: false

    signal accepted(string value)
    signal canceled()

    function open(initialValue) {
        root.value = String(initialValue || "")
        root.opened = true

        Qt.callLater(function() {
            nameInput.forceInputFocus()
            nameInput.input.selectAll()
        })
    }

    function close() {
        root.opened = false
    }

    function acceptValue() {
        const cleanValue = root.value.trim()

        if (cleanValue.length === 0)
            return

        root.accepted(cleanValue)
        root.close()
    }

    anchors.centerIn: parent

    width: 360
    height: 150
    radius: 18

    visible: root.opened
    opacity: root.opened ? 1.0 : 0.0
    z: 20

    color: WalTheme.surfaceAlpha
    border.width: 1
    border.color: WalTheme.border

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: function(mouse) {
            mouse.accepted = true
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        HeadingText {
            width: parent.width

            text: root.title
            font.pixelSize: 15
        }

        FormInput {
            id: nameInput

            width: parent.width
            height: 44

            label: root.label
            placeholder: root.placeholder
            text: root.value

            onTextChanged: {
                root.value = text
            }

            onAccepted: {
                root.acceptValue()
            }
        }

        Row {
            anchors.right: parent.right
            spacing: 8

            ActionButton {
                width: 92
                height: 28

                text: "Cancel"
                muted: true
                fontSize: 11
                buttonRadius: 9

                onClicked: {
                    root.canceled()
                    root.close()
                }
            }

            ActionButton {
                width: 104
                height: 28

                text: root.acceptText
                accent: !root.danger
                danger: root.danger
                fontSize: 11
                buttonRadius: 9

                onClicked: {
                    root.acceptValue()
                }
            }
        }
    }
}
