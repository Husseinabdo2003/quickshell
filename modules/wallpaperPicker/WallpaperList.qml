import QtQuick

Item {
    id: root

    property var model
    property string searchText: ""
    property string currentWallpaperPath: ""
    property string selectedPath: ""
    property bool applying: false

    property var filteredIndexes: []
    property int modelCountValue: root.model ? root.model.count : 0

    signal hovered(string path, string name, string url)
    signal chosen(string path, string name, string url)

    onSearchTextChanged: {
        root.rebuildFilter()
        flick.contentX = 0
    }

    onModelChanged: {
        root.rebuildFilter()
        flick.contentX = 0
    }

    onModelCountValueChanged: {
        root.rebuildFilter()
    }

    function clean(value) {
        try {
            return String(value || "").toLowerCase().trim()
        } catch (error) {
            return ""
        }
    }

    function matchesSearch(name) {
        const query = root.clean(root.searchText)

        if (query.length === 0)
            return true

        return root.clean(name).indexOf(query) !== -1
    }

    function modelCount() {
        return root.model ? root.model.count : 0
    }

    function modelItem(i) {
        if (!root.model || i < 0 || i >= root.model.count)
            return null

        return root.model.get(i)
    }

    function modelPath(i) {
        const item = root.modelItem(i)

        if (!item)
            return ""

        return String(item.path || "")
    }

    function modelName(i) {
        const item = root.modelItem(i)

        if (!item)
            return ""

        return String(item.name || "")
    }

    function modelUrl(i) {
        const item = root.modelItem(i)

        if (!item)
            return ""

        return String(item.url || "")
    }

    function rebuildFilter() {
        const indexes = []

        for (let i = 0; i < root.modelCount(); i++) {
            if (root.matchesSearch(root.modelName(i)))
                indexes.push(i)
        }

        root.filteredIndexes = indexes
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
                model: root.filteredIndexes

                WallpaperCard {
                    required property int modelData

                    wallpaperPath: root.modelPath(modelData)
                    wallpaperName: root.modelName(modelData)
                    wallpaperUrl: root.modelUrl(modelData)

                    active: root.currentWallpaperPath === root.modelPath(modelData)
                    selected: root.selectedPath === root.modelPath(modelData)
                    busy: root.applying

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

    Component.onCompleted: {
        root.rebuildFilter()
    }
}