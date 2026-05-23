import QtQuick

import "../theme"

Rectangle {
    id: root

    property alias text: input.text
    property alias input: input
    property string placeholder: "Search ..."
    property bool interceptFileShortcuts: false

    signal accepted()
    signal fileShortcutPressed(int key, int modifiers)

    function forceInputFocus() {
        input.forceActiveFocus()
    }

    height: 52
    radius: 14

    color: input.activeFocus
        ? Qt.rgba(1, 1, 1, 0.10)
        : Qt.rgba(1, 1, 1, 0.06)

    border.width: 1
    border.color: input.activeFocus
        ? WalTheme.accent
        : WalTheme.border

    Behavior on color {
        ColorAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter

        visible: input.text.length === 0

        text: root.placeholder
        color: WalTheme.fgMuted
        opacity: 0.75

        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.bold: true
    }

    TextInput {
        id: input

        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        verticalAlignment: TextInput.AlignVCenter

        color: WalTheme.fg
        selectionColor: WalTheme.accent
        selectedTextColor: WalTheme.fg

        font.family: Theme.fontFamily
        font.pixelSize: 14
        font.bold: true

        clip: true
        selectByMouse: true
        cursorVisible: activeFocus

        Keys.onPressed: function(event) {
            if (!root.interceptFileShortcuts)
                return

            const controlPressed = event.modifiers & Qt.ControlModifier
            const fileShortcut = (controlPressed
                    && (event.key === Qt.Key_C
                        || event.key === Qt.Key_X
                        || event.key === Qt.Key_V
                        || event.key === Qt.Key_N))
                || event.key === Qt.Key_Delete
                || event.key === Qt.Key_F2

            if (!fileShortcut)
                return

            root.fileShortcutPressed(event.key, event.modifiers)
            event.accepted = true
        }

        onAccepted: {
            root.accepted()
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor

        onClicked: {
            root.forceInputFocus()
        }
    }
}
