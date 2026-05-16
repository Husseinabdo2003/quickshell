import QtQuick
import Quickshell

import "../../components"
import "../../theme"

Card {
    id: root

    property string icon: ""
    property string label: ""
    property string command: ""

    property bool locked: false
    property bool needsConfirmation: false
    property bool confirming: false
    property bool danger: false

    signal requested(string command)

    width: 105
    height: 124

    cardRadius: 24
    cardColor: root.confirming
        ? WalTheme.urgentAlpha
        : Theme.pillBg

    cardBorderWidth: 1
    cardBorderColor: root.confirming
        ? WalTheme.urgent
        : mouseArea.containsMouse && !root.locked
            ? WalTheme.accent
            : WalTheme.border

    scale: mouseArea.pressed && !root.locked ? 0.97 : 1.0
    opacity: root.locked ? 0.55 : 1.0

    Timer {
        id: confirmTimer

        interval: 1800
        repeat: false

        onTriggered: {
            root.confirming = false
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Behavior on cardColor {
        ColorAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Behavior on cardBorderColor {
        ColorAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    function triggerAction() {
        if (root.locked)
            return

        const cleanCommand = String(root.command || "").trim()

        if (cleanCommand.length === 0)
            return

        if (root.needsConfirmation && !root.confirming) {
            root.confirming = true
            confirmTimer.restart()
            return
        }

        confirmTimer.stop()
        root.confirming = false
        root.requested(cleanCommand)
    }

    Column {
        anchors.centerIn: parent
        spacing: 10

        Card {
            width: 44
            height: 44

            anchors.horizontalCenter: parent.horizontalCenter

            cardRadius: 17

            cardColor: root.confirming
                ? WalTheme.urgentAlpha
                : mouseArea.containsMouse && !root.locked
                    ? WalTheme.accentAlpha
                    : WalTheme.surfaceAlpha

            cardBorderWidth: 1
            cardBorderColor: root.confirming
                ? WalTheme.urgent
                : mouseArea.containsMouse && !root.locked
                    ? WalTheme.accent
                    : WalTheme.border

            Behavior on cardColor {
                ColorAnimation {
                    duration: Animations.fast
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on cardBorderColor {
                ColorAnimation {
                    duration: Animations.fast
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                anchors.centerIn: parent

                text: root.confirming ? "!" : root.icon
                color: root.confirming
                    ? WalTheme.urgent
                    : WalTheme.fg

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: root.confirming ? 22 : 21
                font.bold: true
            }
        }

        TitleText {
            anchors.horizontalCenter: parent.horizontalCenter

            text: root.confirming ? "Confirm" : root.label
            font.pixelSize: Theme.fontSize
            color: root.confirming
                ? WalTheme.urgent
                : WalTheme.fg
        }

        MetaText {
            anchors.horizontalCenter: parent.horizontalCenter

            visible: root.needsConfirmation || root.locked

            text: root.locked
                ? "Running"
                : root.confirming
                    ? "Click again"
                    : "2-step"

            font.pixelSize: 10
            accentText: root.confirming
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: !root.locked
        enabled: !root.locked
        cursorShape: root.locked ? Qt.ArrowCursor : Qt.PointingHandCursor

        onClicked: {
            root.triggerAction()
        }
    }
}