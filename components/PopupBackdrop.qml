import QtQuick

Item {
    id: root

    property bool opened: false
    property real dimOpacity: 0.58
    property int animationDuration: 160
    property bool closeOnClick: true

    signal clicked()

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent

        color: Qt.rgba(0, 0, 0, root.opened ? root.dimOpacity : 0)

        Behavior on color {
            ColorAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        enabled: root.opened && root.closeOnClick

        onClicked: {
            root.clicked()
        }
    }
}