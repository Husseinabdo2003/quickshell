import QtQuick

import "../../components"
import "../../theme"

Card {
    id: root

    property var apps: []
    property int selectedIndex: 0

    signal appClicked(var app)

    function ensureSelectedVisible() {
        if (root.apps.length === 0)
            return

        const itemHeight = 62
        const targetY = root.selectedIndex * itemHeight
        const bottomY = targetY + itemHeight

        if (targetY < flick.contentY) {
            flick.contentY = Math.max(0, targetY)
            return
        }

        if (bottomY > flick.contentY + flick.height) {
            flick.contentY = Math.min(
                Math.max(0, flick.contentHeight - flick.height),
                bottomY - flick.height
            )
        }
    }

    cardRadius: 24
    cardColor: Qt.rgba(0, 0, 0, 0.14)
    cardBorderColor: WalTheme.border

    clip: true

    Flickable {
        id: flick

        anchors.fill: parent
        anchors.margins: 10
        anchors.rightMargin: 18

        contentWidth: width
        contentHeight: listColumn.implicitHeight

        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        Column {
            id: listColumn

            width: flick.width
            spacing: 6

            Repeater {
                model: root.apps

                LauncherItem {
                    required property var modelData
                    required property int index

                    width: listColumn.width

                    app: modelData
                    selected: index === root.selectedIndex

                    onClicked: function(app) {
                        root.appClicked(app)
                    }
                }
            }
        }
    }

    Rectangle {
        visible: flick.contentHeight > flick.height

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.topMargin: 14
        anchors.bottomMargin: 14
        anchors.rightMargin: 8

        width: 4
        radius: 999
        color: Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.08)

        Rectangle {
            width: parent.width
            radius: 999
            color: WalTheme.accent

            height: flick.contentHeight > 0
                ? Math.max(34, parent.height * flick.height / flick.contentHeight)
                : 34

            y: flick.contentHeight > flick.height
                ? (parent.height - height) * flick.contentY / (flick.contentHeight - flick.height)
                : 0

            Behavior on y {
                NumberAnimation {
                    duration: Animations.fast
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    LauncherEmptyState {
        visible: root.apps.length === 0

        anchors.fill: parent
        anchors.margins: 10
    }
}