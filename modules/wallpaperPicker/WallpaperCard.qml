import QtQuick

import "../../components"
import "../../theme"

Card {
    id: root

    property string wallpaperPath: ""
    property string wallpaperName: ""
    property string wallpaperUrl: ""

    property bool shown: true
    property bool active: false
    property bool selected: false

    signal hovered(string path, string name, string url)
    signal chosen(string path, string name, string url)

    visible: shown

    width: shown ? 260 : 0
    height: 156

    cardRadius: 14
    cardColor: Qt.rgba(0, 0, 0, 0.22)
    cardBorderWidth: active || selected || mouse.containsMouse ? 2 : 1
    cardBorderColor: active || selected || mouse.containsMouse
        ? WalTheme.accent
        : WalTheme.border

    scale: mouse.containsMouse ? 1.035 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 130
            easing.type: Easing.OutCubic
        }
    }

    Behavior on cardBorderColor {
        ColorAnimation {
            duration: 130
            easing.type: Easing.OutCubic
        }
    }

    Image {
        anchors.fill: parent

        source: root.wallpaperUrl
        fillMode: Image.PreserveAspectCrop

        asynchronous: true
        smooth: true
    }

    Rectangle {
        anchors.fill: parent

        color: mouse.containsMouse
            ? Qt.rgba(0, 0, 0, 0.18)
            : Qt.rgba(0, 0, 0, 0.30)
    }

    Badge {
        visible: root.active

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.rightMargin: 10

        text: "Active"
        accent: true
        danger: false
        badgeHeight: 26
        badgeRadius: 13
        fontSize: 11
        horizontalPadding: 20
    }

    TitleText {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.bottomMargin: 10

        text: root.wallpaperName

        font.pixelSize: 12
        horizontalAlignment: Text.AlignHCenter
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            root.hovered(
                root.wallpaperPath,
                root.wallpaperName,
                root.wallpaperUrl
            )
        }

        onClicked: {
            root.chosen(
                root.wallpaperPath,
                root.wallpaperName,
                root.wallpaperUrl
            )
        }
    }
}