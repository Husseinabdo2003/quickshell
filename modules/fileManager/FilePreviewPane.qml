import QtQuick

import "../../components"
import "../../theme"

Rectangle {
    id: root

    property int previewWidth: 236
    property string imageSource: ""
    property string selectedName: ""
    property string selectedPath: ""
    property string selectedSizeText: ""
    property string selectedModifiedText: ""
    property color softBorder: WalTheme.border

    width: previewWidth

    color: "transparent"
    border.width: 1
    border.color: root.softBorder

    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Rectangle {
            width: parent.width
            height: Math.min(parent.width, parent.height - 116)
            radius: 12

            color: Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.045)
            border.width: 1
            border.color: root.softBorder
            clip: true

            Image {
                anchors.fill: parent
                anchors.margins: 8

                source: root.imageSource

                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: false
                smooth: true
            }
        }

        HeadingText {
            width: parent.width

            text: root.selectedName.length > 0
                ? root.selectedName
                : "Preview"

            font.pixelSize: 14
            elide: Text.ElideMiddle
        }

        MetaText {
            width: parent.width

            text: root.selectedSizeText + " - " + root.selectedModifiedText

            font.pixelSize: 10
            elide: Text.ElideRight
        }

        MetaText {
            width: parent.width

            text: root.selectedPath

            font.pixelSize: 10
            elide: Text.ElideMiddle
        }
    }
}
