import QtQuick

Item {
    id: root

    property var model
    property string searchText: ""
    property string currentWallpaperPath: ""
    property string selectedPath: ""

    signal hovered(string path, string name, string url)
    signal chosen(string path, string name, string url)

    function matchesSearch(name) {
        if (root.searchText.length === 0)
            return true

        return name.toLowerCase().indexOf(root.searchText.toLowerCase()) !== -1
    }

    function modelCount() {
        return root.model ? root.model.count : 0
    }

    function modelPath(i) {
        if (!root.model || i < 0 || i >= root.model.count)
            return ""

        return root.model.get(i).path || ""
    }

    function modelName(i) {
        if (!root.model || i < 0 || i >= root.model.count)
            return ""

        return root.model.get(i).name || ""
    }

    function modelUrl(i) {
        if (!root.model || i < 0 || i >= root.model.count)
            return ""

        return root.model.get(i).url || ""
    }

    Flickable {
        id: flick

        anchors.fill: parent

        contentWidth: wallpaperRow.implicitWidth
        contentHeight: wallpaperRow.height

        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalFlick
        clip: true

        WheelHandler {
            target: flick
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

            onWheel: function(event) {
                const maxX = Math.max(0, flick.contentWidth - flick.width)
                const delta = event.angleDelta.y !== 0
                    ? event.angleDelta.y
                    : event.pixelDelta.y

                if (delta > 0) {
                    flick.contentX = Math.max(0, flick.contentX - 180)
                } else {
                    flick.contentX = Math.min(maxX, flick.contentX + 180)
                }

                event.accepted = true
            }
        }

        Row {
            id: wallpaperRow

            height: flick.height
            spacing: 20

            Repeater {
                model: root.modelCount()

                WallpaperCard {
                    wallpaperPath: root.modelPath(index)
                    wallpaperName: root.modelName(index)
                    wallpaperUrl: root.modelUrl(index)

                    shown: root.matchesSearch(root.modelName(index))
                    active: root.currentWallpaperPath === root.modelPath(index)
                    selected: root.selectedPath === root.modelPath(index)

                    onHovered: function(path, name, url) {
                        root.hovered(path, name, url)
                    }

                    onChosen: function(path, name, url) {
                        root.chosen(path, name, url)
                    }
                }
            }
        }

        WallpaperScrollbar {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2

            contentWidthValue: flick.contentWidth
            viewportWidthValue: flick.width
            contentXValue: flick.contentX
        }
    }
}