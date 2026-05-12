import QtQuick

import "../theme"

Rectangle {
    id: root

    property alias text: input.text
    property alias input: input

    property string label: ""
    property string placeholder: ""

    property int inputRadius: 16
    property int labelSize: 9
    property int textSize: 12

    property color normalColor: WalTheme.surfaceAlpha
    property color focusColor: Qt.rgba(1, 1, 1, 0.10)

    property color normalBorderColor: WalTheme.border
    property color focusBorderColor: WalTheme.accent

    signal accepted()

    function forceInputFocus() {
        input.forceActiveFocus()
    }

    height: 42
    radius: inputRadius

    color: input.activeFocus ? focusColor : normalColor

    border.width: 1
    border.color: input.activeFocus ? focusBorderColor : normalBorderColor

    Behavior on color {
        ColorAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Column {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 5
        anchors.bottomMargin: 4

        spacing: 1

        Text {
            text: root.label
            color: WalTheme.fgMuted

            font.pixelSize: root.labelSize

            width: parent.width
            elide: Text.ElideRight
        }

        TextInput {
            id: input

            width: parent.width

            text: ""
            color: WalTheme.fg

            font.pixelSize: root.textSize

            clip: true
            selectByMouse: true
            cursorVisible: activeFocus

            verticalAlignment: TextInput.AlignVCenter

            onAccepted: {
                root.accepted()
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                visible: input.text.length === 0 && !input.activeFocus && root.placeholder.length > 0

                text: root.placeholder
                color: WalTheme.fgMuted
                opacity: 0.55

                font.pixelSize: root.textSize
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor

        onClicked: {
            input.forceActiveFocus()
        }
    }
}