import QtQuick

import "../../components"
import "../../theme"

Card {
    id: root

    property string value: ""
    property bool selected: false
    property bool busy: false

    signal clicked(string value)

    width: parent ? parent.width : 520
    height: 54

    cardRadius: 18

    cardColor: root.selected
        ? WalTheme.accentAlpha
        : mouseArea.containsMouse && !root.busy
            ? Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.055)
            : "transparent"

    cardBorderColor: root.selected
        ? WalTheme.accent
        : mouseArea.containsMouse && !root.busy
            ? WalTheme.border
            : "transparent"

    cardBorderWidth: root.selected || (mouseArea.containsMouse && !root.busy) ? 1 : 0

    opacity: root.busy ? 0.62 : 1.0

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

    function previewText() {
        try {
            return String(root.value || "")
                .replace(/\t/g, "    ")
                .replace(/\n/g, " ")
        } catch (error) {
            return ""
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 12

        Card {
            width: 36
            height: 36

            anchors.verticalCenter: parent.verticalCenter

            cardRadius: 14
            cardColor: root.selected
                ? WalTheme.accentAlpha
                : WalTheme.surfaceAlpha

            cardBorderColor: root.selected
                ? WalTheme.accent
                : WalTheme.border

            Text {
                anchors.centerIn: parent

                text: ""
                color: WalTheme.fg

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
                font.bold: true
            }
        }

        Column {
            width: parent.width - 104
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            TitleText {
                width: parent.width

                text: root.previewText()
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            MetaText {
                width: parent.width

                text: "Clipboard item"
                font.pixelSize: 10
                opacity: 0.75
            }
        }

        Badge {
            anchors.verticalCenter: parent.verticalCenter

            visible: root.selected

            text: root.busy ? "..." : "Enter"
            accent: true
            badgeHeight: 22
            badgeRadius: 11
            fontSize: 9
            horizontalPadding: 10
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: !root.busy
        enabled: !root.busy
        cursorShape: root.busy ? Qt.ArrowCursor : Qt.PointingHandCursor

        onClicked: {
            root.clicked(root.value)
        }
    }
}