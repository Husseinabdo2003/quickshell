import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import "../../components"
import "../../services"
import "../../theme"

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true

    color: "transparent"
    visible: ShellState.fileManagerOpen

    readonly property int managerWidth: 940
    readonly property int managerHeight: 600
    readonly property int sidebarWidth: 188
    readonly property int previewWidth: 236
    readonly property int activePreviewWidth: root.selectedIsImage() ? root.previewWidth : 0
    readonly property int toolbarHeight: 66
    readonly property int pathBarHeight: 48
    readonly property int headerHeight: 30
    readonly property int statusHeight: 34
    readonly property int contentInset: 8
    readonly property int rowInset: 10
    readonly property int iconColumnWidth: 22
    readonly property int sizeColumnWidth: 82
    readonly property int dateColumnWidth: 132
    readonly property int columnGap: 12
    readonly property string homeDir: Quickshell.env("HOME")

    readonly property color finderBg: WalTheme.surfaceAlpha
    readonly property color softBorder: WalTheme.border

    property string query: ""
    property string selectedPath: ""
    property string selectedName: ""
    property string selectedKind: ""
    property string selectedSizeText: ""
    property string selectedModifiedText: ""
    property string statusText: ""
    property string clipboardMode: ""
    property string clipboardPath: ""
    property string clipboardName: ""
    property string sortKey: "name"
    property bool sortDescending: false
    property var rawEntries: []
    property var devicePlaces: []
    property bool pickerActive: false
    property bool pickerDirectoryMode: false
    property bool pickerSaveMode: false
    property string pickerToken: ""
    property string pickerTitle: ""
    property string pickerSaveName: ""
    readonly property bool fileShortcutsEnabled: ShellState.fileManagerOpen && !root.promptIsOpen()

    readonly property var sidebarPlaces: [
        { "label": "Home", "icon": "", "path": root.homeDir },
        { "label": "Desktop", "icon": "󰇄", "path": root.homeDir + "/Desktop" },
        { "label": "Documents", "icon": "󰈙", "path": root.homeDir + "/Documents" },
        { "label": "Downloads", "icon": "", "path": root.homeDir + "/Downloads" },
        { "label": "Pictures", "icon": "", "path": root.homeDir + "/Pictures" },
        { "label": "Trash", "icon": "", "path": root.homeDir + "/.local/share/Trash/files", "kind": "trash" }
    ]

    HyprlandFocusGrab {
        id: focusGrab

        windows: [root]
        active: ShellState.fileManagerOpen

        onCleared: {
            if (ShellState.fileManagerOpen)
                ShellState.closeFileManager()
        }
    }

    IpcHandler {
        target: "fileManager"

        function toggle(): void {
            ShellState.toggleFileManager()
        }

        function open(): void {
            ShellState.openFileManager()
        }

        function close(): void {
            ShellState.closeFileManager()
        }

        function home(): void {
            fileActions.goHome()
        }

        function openPath(path: string): void {
            const cleanPath = String(path || root.homeDir)

            ShellState.openFileManager()
            fileActions.listDirectory(cleanPath, "folder")
        }

        function chooseFile(token: string, startDir: string, title: string, multiple: bool, directory: bool, save: bool): void {
            root.openPicker(token, startDir, title, multiple, directory, save, "download")
        }

        function chooseFileWithName(token: string, startDir: string, title: string, multiple: bool, directory: bool, save: bool, saveName: string): void {
            root.openPicker(token, startDir, title, multiple, directory, save, saveName)
        }
    }

    function openPicker(token, startDir, title, multiple, directory, save, saveName) {
        try {
            const cleanDir = String(startDir || root.homeDir)

            root.pickerActive = true
            root.pickerDirectoryMode = directory
            root.pickerSaveMode = save
            root.pickerToken = String(token || "")
            root.pickerTitle = String(title || "")
            root.pickerSaveName = String(saveName || "download")
            root.query = ""

            ShellState.openFileManager()
            fileActions.listDirectory(cleanDir, "folder")
        } catch (error) {
            console.log("FileManager: failed to open picker:", error)
        }
    }

    Shortcut {
        sequence: "Ctrl+C"
        context: Qt.ApplicationShortcut
        enabled: root.fileShortcutsEnabled

        onActivated: {
            root.beginCopySelected()
        }
    }

    Shortcut {
        sequence: "Ctrl+X"
        context: Qt.ApplicationShortcut
        enabled: root.fileShortcutsEnabled

        onActivated: {
            root.beginMoveSelected()
        }
    }

    Shortcut {
        sequence: "Ctrl+V"
        context: Qt.ApplicationShortcut
        enabled: root.fileShortcutsEnabled

        onActivated: {
            root.pasteClipboard()
        }
    }

    Shortcut {
        sequence: "Delete"
        context: Qt.ApplicationShortcut
        enabled: root.fileShortcutsEnabled

        onActivated: {
            root.trashSelected()
        }
    }

    Shortcut {
        sequence: "F2"
        context: Qt.ApplicationShortcut
        enabled: root.fileShortcutsEnabled

        onActivated: {
            root.openRenameDialog()
        }
    }

    Shortcut {
        sequence: "Ctrl+N"
        context: Qt.ApplicationShortcut
        enabled: root.fileShortcutsEnabled

        onActivated: {
            root.openNewFolderDialog()
        }
    }

    FileManagerActions {
        id: fileActions

        onListStarted: {
            contextMenu.close()
            root.rawEntries = []
            entriesModel.clear()
            root.selectedPath = ""
            root.selectedName = ""
            root.selectedKind = ""
            root.selectedSizeText = ""
            root.selectedModifiedText = ""
            root.statusText = "Loading..."
        }

        onEntryFound: function(path, name, kind, sizeText, modifiedText, sizeValue, modifiedValue) {
            root.rawEntries = root.rawEntries.concat([{
                path: path,
                name: name,
                kind: kind,
                sizeText: sizeText,
                modifiedText: modifiedText,
                sizeValue: Number(sizeValue || 0),
                modifiedValue: String(modifiedValue || "")
            }])
        }

        onListFinished: function(exitCode) {
            if (exitCode === 0) {
                root.rebuildEntriesModel()
                root.statusText = fileActions.currentPlaceKind === "trash" && entriesModel.count === 0
                    ? "Trash is empty"
                    : entriesModel.count + " items"
                return
            }

            root.statusText = "Could not open folder"
        }

        onOpenFailed: function(path) {
            root.statusText = "Could not open " + fileActions.fileName(path)
        }

        onDirectoryCreated: function(path) {
            root.statusText = "Created " + fileActions.fileName(path)
            fileActions.reload()
        }

        onDirectoryCreateFailed: function(name) {
            root.statusText = "Could not create " + name
        }

        onPathMoved: function(sourcePath, targetDir) {
            root.statusText = "Moved " + fileActions.fileName(sourcePath)
            root.clearClipboard()
            fileActions.reload()
        }

        onPathMoveFailed: function(sourcePath, targetDir) {
            root.statusText = "Could not move " + fileActions.fileName(sourcePath)
        }

        onPathCopied: function(sourcePath, targetDir) {
            root.statusText = "Copied " + fileActions.fileName(sourcePath)
            fileActions.reload()
        }

        onPathCopyFailed: function(sourcePath, targetDir) {
            root.statusText = "Could not copy " + fileActions.fileName(sourcePath)
        }

        onPathRenamed: function(sourcePath, newPath) {
            root.statusText = "Renamed " + fileActions.fileName(newPath)
            root.selectedPath = newPath
            fileActions.reload()
        }

        onPathRenameFailed: function(sourcePath, newPath) {
            root.statusText = "Could not rename " + fileActions.fileName(sourcePath)
        }

        onPathTrashed: function(path) {
            root.statusText = "Moved " + fileActions.fileName(path) + " to Trash"
            root.selectedPath = ""
            root.selectedName = ""
            root.selectedKind = ""
            root.selectedSizeText = ""
            root.selectedModifiedText = ""
            fileActions.reload()
        }

        onPathTrashFailed: function(path) {
            root.statusText = "Could not trash " + fileActions.fileName(path)
        }

        onTrashEmptied: {
            root.statusText = "Trash emptied"
            root.selectedPath = ""
            root.selectedName = ""
            root.selectedKind = ""
            root.selectedSizeText = ""
            root.selectedModifiedText = ""
            fileActions.reload()
        }

        onTrashEmptyFailed: {
            root.statusText = "Could not empty Trash"
        }

        onDeviceListStarted: {
            root.devicePlaces = []
        }

        onDeviceFound: function(label, path, icon, blockPath, mounted, removable, canUnmount, status) {
            root.devicePlaces = root.devicePlaces.concat([{
                label: label,
                path: path,
                icon: icon,
                blockPath: blockPath,
                mounted: mounted,
                removable: removable,
                canUnmount: canUnmount,
                status: status
            }])
        }

        onDeviceMounted: function(blockPath, mountPath) {
            root.statusText = "Mounted " + blockPath
            fileActions.refreshDevices()

            if (mountPath.length > 0)
                fileActions.listDirectory(mountPath, "folder")
        }

        onDeviceMountFailed: function(blockPath) {
            root.statusText = "Could not mount " + blockPath
            fileActions.refreshDevices()
        }

        onDeviceUnmounted: function(blockPath) {
            root.statusText = "Unmounted " + blockPath

            for (let index = 0; index < root.devicePlaces.length; index++) {
                const device = root.devicePlaces[index]

                if (device.blockPath === blockPath
                        && device.path.length > 0
                        && fileActions.currentDir.indexOf(device.path) === 0) {
                    fileActions.goHome()
                    break
                }
            }

            fileActions.refreshDevices()
        }

        onDeviceUnmountFailed: function(blockPath) {
            root.statusText = "Could not unmount " + blockPath
            fileActions.refreshDevices()
        }
    }

    Timer {
        id: focusTimer

        interval: Animations.instant
        repeat: false

        onTriggered: {
            panel.forceActiveFocus()
        }
    }

    Connections {
        target: ShellState

        function onFileManagerOpenChanged() {
            if (ShellState.fileManagerOpen) {
                contextMenu.close()
                root.query = ""
                fileActions.reload()
                fileActions.refreshDevices()
                focusTimer.restart()
            } else {
                contextMenu.close()
                focusTimer.stop()
            }
        }
    }

    ListModel {
        id: entriesModel
    }

    function closeManager() {
        if (root.pickerActive)
            root.finishPicker(false)

        contextMenu.close()
        ShellState.closeFileManager()
    }

    function currentTitle() {
        if (root.pickerActive && root.pickerTitle.length > 0)
            return root.pickerTitle

        if (fileActions.currentPlaceKind === "trash" && fileActions.currentDir === fileActions.trashDir)
            return "Trash"

        if (fileActions.currentDir === "/")
            return "Root"

        return fileActions.fileName(fileActions.currentDir) || "Files"
    }

    function matchesSearch(name) {
        const cleanQuery = root.query.toLowerCase().trim()

        if (cleanQuery.length === 0)
            return true

        return String(name || "").toLowerCase().indexOf(cleanQuery) !== -1
    }

    function fileUrl(path) {
        const cleanPath = String(path || "")

        if (cleanPath.length === 0)
            return ""

        return "file://" + encodeURI(cleanPath)
    }

    function isImagePath(path) {
        return /\.(png|jpe?g|webp|gif|bmp|svg)$/i.test(String(path || ""))
    }

    function selectedIsImage() {
        return root.selectedKind !== "directory" && root.isImagePath(root.selectedPath)
    }

    function compareEntries(left, right) {
        const leftIsDirectory = left.kind === "directory"
        const rightIsDirectory = right.kind === "directory"

        if (leftIsDirectory !== rightIsDirectory)
            return leftIsDirectory ? -1 : 1

        let result = 0

        if (root.sortKey === "size") {
            result = Number(left.sizeValue || 0) - Number(right.sizeValue || 0)
        } else if (root.sortKey === "date") {
            result = String(left.modifiedValue || "").localeCompare(String(right.modifiedValue || ""))
        } else {
            result = String(left.name || "").toLowerCase().localeCompare(String(right.name || "").toLowerCase())
        }

        if (result === 0)
            result = String(left.name || "").toLowerCase().localeCompare(String(right.name || "").toLowerCase())

        return root.sortDescending ? -result : result
    }

    function rebuildEntriesModel() {
        const selected = root.selectedPath
        const sortedEntries = root.rawEntries.slice().sort(root.compareEntries)

        entriesModel.clear()

        if (selected.length > 0) {
            root.selectedName = ""
            root.selectedKind = ""
            root.selectedSizeText = ""
            root.selectedModifiedText = ""
        }

        for (let index = 0; index < sortedEntries.length; index++) {
            entriesModel.append(sortedEntries[index])

            if (sortedEntries[index].path === selected) {
                root.selectedName = sortedEntries[index].name
                root.selectedKind = sortedEntries[index].kind
                root.selectedSizeText = sortedEntries[index].sizeText
                root.selectedModifiedText = sortedEntries[index].modifiedText
            }
        }
    }

    function setSort(key) {
        const cleanKey = String(key || "name")

        if (root.sortKey === cleanKey) {
            root.sortDescending = !root.sortDescending
        } else {
            root.sortKey = cleanKey
            root.sortDescending = cleanKey === "date"
        }

        root.rebuildEntriesModel()
    }

    function selectEntry(path) {
        root.selectedPath = String(path || "")
        root.selectedName = ""
        root.selectedKind = ""
        root.selectedSizeText = ""
        root.selectedModifiedText = ""

        for (let index = 0; index < entriesModel.count; index++) {
            const item = entriesModel.get(index)

            if (item.path === root.selectedPath) {
                root.selectedName = item.name
                root.selectedKind = item.kind
                root.selectedSizeText = item.sizeText
                root.selectedModifiedText = item.modifiedText
                return
            }
        }
    }

    function openSelected() {
        if (root.selectedPath.length === 0 || fileActions.opening)
            return

        const path = root.selectedPath

        for (let index = 0; index < entriesModel.count; index++) {
            const item = entriesModel.get(index)

            if (item.path === path) {
                fileActions.openPath(item.path, item.kind)
                return
            }
        }
    }

    function openNewFolderDialog() {
        if (fileActions.busy || fileActions.currentPlaceKind === "trash")
            return

        newFolderDialog.open("")
    }

    function beginMoveSelected() {
        if (root.selectedPath.length === 0 || fileActions.busy)
            return

        root.clipboardMode = "move"
        root.clipboardPath = root.selectedPath
        root.clipboardName = root.selectedName
        root.statusText = "Ready to move " + root.clipboardName
    }

    function beginCopySelected() {
        if (root.selectedPath.length === 0 || fileActions.busy)
            return

        root.clipboardMode = "copy"
        root.clipboardPath = root.selectedPath
        root.clipboardName = root.selectedName
        root.statusText = "Ready to copy " + root.clipboardName
    }

    function pasteClipboard() {
        if (root.clipboardPath.length === 0
                || root.clipboardMode.length === 0
                || fileActions.busy
                || fileActions.currentPlaceKind === "trash")
            return

        const targetDir = root.selectedKind === "directory"
            ? root.selectedPath
            : fileActions.currentDir

        if (targetDir.length === 0 || targetDir === root.clipboardPath)
            return

        if (root.clipboardMode === "copy") {
            fileActions.copyPath(root.clipboardPath, targetDir)
            return
        }

        fileActions.movePath(root.clipboardPath, targetDir)
    }

    function clearClipboard() {
        root.clipboardMode = ""
        root.clipboardPath = ""
        root.clipboardName = ""
    }

    function cancelClipboard() {
        root.clearClipboard()
        root.statusText = entriesModel.count + " items"
    }

    function openRenameDialog() {
        if (root.selectedPath.length === 0 || fileActions.busy || fileActions.currentPlaceKind === "trash")
            return

        renameDialog.open(root.selectedName)
    }

    function trashSelected() {
        if (root.selectedPath.length === 0 || fileActions.busy)
            return

        if (fileActions.currentPlaceKind === "trash")
            return

        fileActions.trashPath(root.selectedPath)
    }

    function emptyTrash() {
        if (fileActions.busy || fileActions.currentPlaceKind !== "trash" || entriesModel.count === 0)
            return

        fileActions.emptyTrash()
    }

    function pickerResultPath() {
        if (!root.pickerActive)
            return ""

        if (root.pickerSaveMode) {
            const saveName = fileActions.fileName(root.pickerSaveName)

            if (saveName.length === 0)
                return ""

            if (root.selectedPath.length > 0 && root.selectedKind !== "directory")
                return root.selectedPath

            const targetDir = root.selectedKind === "directory" && root.selectedPath.length > 0
                ? root.selectedPath
                : fileActions.currentDir

            if (targetDir.length === 0)
                return ""

            return targetDir + "/" + saveName
        }

        if (root.pickerDirectoryMode) {
            if (root.selectedKind === "directory")
                return root.selectedPath

            return fileActions.currentDir
        }

        if (root.selectedPath.length === 0 || root.selectedKind === "directory")
            return ""

        return root.selectedPath
    }

    function writePickerFile(suffix, value) {
        if (root.pickerToken.length === 0)
            return

        const runtimeDir = Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
        const pickerDir = runtimeDir + "/quickshell-file-picker"
        const target = pickerDir + "/" + root.pickerToken + suffix

        writePickerProcess.exec([
            "python3",
            "-c",
            "import os, sys\npicker_dir, target, value = sys.argv[1:4]\nos.makedirs(picker_dir, exist_ok=True)\nopen(target, 'w', encoding='utf-8').write(value + '\\n')\n",
            pickerDir,
            target,
            value
        ])
    }

    function finishPicker(accepted) {
        if (!root.pickerActive)
            return

        const resultPath = accepted ? root.pickerResultPath() : ""

        if (accepted && resultPath.length === 0)
            return

        if (accepted)
            root.writePickerFile(".result", resultPath)
        else
            root.writePickerFile(".cancel", "cancel")

        root.pickerActive = false
        root.pickerDirectoryMode = false
        root.pickerSaveMode = false
        root.pickerToken = ""
        root.pickerTitle = ""
        root.pickerSaveName = ""
        ShellState.closeFileManager()
    }

    Process {
        id: writePickerProcess

        command: []
        running: false
    }

    function currentPathLabel() {
        if (fileActions.currentPlaceKind === "trash" && fileActions.currentDir === fileActions.trashDir)
            return "Trash"

        return fileActions.currentDir
    }

    function promptIsOpen() {
        return newFolderDialog.opened || renameDialog.opened
    }

    function handleFileShortcut(key, modifiers) {
        if (!ShellState.fileManagerOpen || root.promptIsOpen())
            return false

        const controlPressed = modifiers & Qt.ControlModifier

        if (controlPressed && key === Qt.Key_C) {
            root.beginCopySelected()
            return true
        }

        if (controlPressed && key === Qt.Key_X) {
            root.beginMoveSelected()
            return true
        }

        if (controlPressed && key === Qt.Key_V) {
            root.pasteClipboard()
            return true
        }

        if (controlPressed && key === Qt.Key_N) {
            root.openNewFolderDialog()
            return true
        }

        if (key === Qt.Key_Delete) {
            root.trashSelected()
            return true
        }

        if (key === Qt.Key_F2) {
            root.openRenameDialog()
            return true
        }

        return false
    }

    function startSearchFromKey(event) {
        if ((event.modifiers & Qt.ControlModifier)
                || (event.modifiers & Qt.AltModifier)
                || (event.modifiers & Qt.MetaModifier))
            return false

        const text = String(event.text || "")

        if (text.length !== 1 || text < " ")
            return false

        root.query += text
        searchBox.forceInputFocus()
        return true
    }

    function openContextMenu(sceneX, sceneY) {
        const localPoint = panel.mapFromItem(null, sceneX, sceneY)
        contextMenu.openAt(localPoint.x, localPoint.y)
    }

    PopupBackdrop {
        opened: ShellState.fileManagerOpen
        dimOpacity: 0.52
        animationDuration: Animations.popupFade

        onClicked: {
            contextMenu.close()
            root.closeManager()
        }
    }

    AnimatedPopupCard {
        id: panel

        width: Math.max(720, Math.min(parent.width - 80, root.managerWidth))
        height: Math.max(500, Math.min(parent.height - 80, root.managerHeight))

        anchors.centerIn: parent

        opened: ShellState.fileManagerOpen

        openedScale: 1.0
        closedScale: 0.96

        openDuration: Animations.popupFade
        closeDuration: Animations.popupFade

        popupRadius: 20
        popupColor: root.finderBg
        popupBorderColor: WalTheme.border

        focus: true
        layer.enabled: false

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (newFolderDialog.opened) {
                    newFolderDialog.close()
                    event.accepted = true
                    return
                }

                if (renameDialog.opened) {
                    renameDialog.close()
                    event.accepted = true
                    return
                }

                if (root.clipboardPath.length > 0) {
                    root.cancelClipboard()
                    event.accepted = true
                    return
                }

                root.closeManager()
                event.accepted = true
                return
            }

            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.openSelected()
                event.accepted = true
                return
            }

            if (root.handleFileShortcut(event.key, event.modifiers)) {
                event.accepted = true
                return
            }

            if (root.startSearchFromKey(event))
                event.accepted = true
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: function(mouse) {
                mouse.accepted = true

                if (mouse.button === Qt.RightButton) {
                    contextMenu.openAt(mouse.x, mouse.y)
                    return
                }

                contextMenu.close()
            }
        }

        Row {
            anchors.fill: parent
            anchors.margins: root.contentInset

            FileManagerSidebar {
                sidebarWidth: root.sidebarWidth
                height: parent.height
                currentDir: fileActions.currentDir
                places: root.sidebarPlaces
                devices: root.devicePlaces

                onPathRequested: function(path, kind) {
                    root.query = ""

                    if (kind === "trash") {
                        fileActions.listTrash()
                        return
                    }

                    fileActions.listDirectory(path, "folder")
                }

                onDeviceMountRequested: function(blockPath) {
                    root.query = ""
                    root.statusText = "Mounting " + blockPath + "..."
                    fileActions.mountDevice(blockPath)
                }

                onDeviceUnmountRequested: function(blockPath) {
                    root.query = ""
                    root.statusText = "Unmounting " + blockPath + "..."
                    fileActions.unmountDevice(blockPath)
                }
            }

            Rectangle {
                width: parent.width - root.sidebarWidth
                height: parent.height

                color: "transparent"

                Column {
                    anchors.fill: parent

                    Rectangle {
                        id: toolbar

                        width: parent.width
                        height: root.toolbarHeight

                        color: "transparent"

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

                            Row {
                                id: navGroup

                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6

                                IconButton {
                                    icon: ""
                                    tooltip: "Up"
                                    muted: true

                                    onClicked: {
                                        fileActions.goUp()
                                    }
                                }
                            }

                            HeadingText {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: navGroup.right
                                anchors.leftMargin: 14
                                anchors.right: actionGroup.left
                                anchors.rightMargin: 14

                                text: root.currentTitle()
                                font.pixelSize: 17
                                elide: Text.ElideMiddle
                            }

                            Row {
                                id: actionGroup

                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                spacing: 8

                                IconButton {
                                    anchors.verticalCenter: parent.verticalCenter

                                    icon: ""
                                    tooltip: "Reload"
                                    muted: true

                                    onClicked: {
                                        fileActions.reload()
                                    }
                                }

                                IconButton {
                                    anchors.verticalCenter: parent.verticalCenter

                                    icon: "×"
                                    tooltip: "Close"
                                    muted: true

                                    onClicked: {
                                        root.closeManager()
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: root.pathBarHeight

                        color: "transparent"

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

                            SearchBox {
                                id: searchBox

                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                width: Math.min(226, parent.width * 0.34)
                                height: 30

                                placeholder: "Search"
                                text: root.query
                                interceptFileShortcuts: true

                                onTextChanged: {
                                    root.query = text
                                }

                                onFileShortcutPressed: function(key, modifiers) {
                                    root.handleFileShortcut(key, modifiers)
                                }
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: searchBox.left
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter

                                height: 30
                                radius: 8

                                color: Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.055)
                                border.width: 1
                                border.color: root.softBorder

                                Text {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 11
                                    anchors.right: parent.right
                                    anchors.rightMargin: 11
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: root.currentPathLabel()
                                    color: WalTheme.fgMuted

                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11

                                    elide: Text.ElideMiddle
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: root.headerHeight

                        color: "transparent"

                        Item {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 8

                            width: parent.width - root.activePreviewWidth - 16

                            SortHeader {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: root.rowInset
                                    + root.iconColumnWidth
                                    + root.columnGap
                                anchors.right: sizeHeader.left
                                anchors.rightMargin: root.columnGap

                                height: parent.height

                                label: "Name"
                                sortKey: "name"
                                activeSortKey: root.sortKey
                                descending: root.sortDescending

                                onRequested: function(sortKey) {
                                    root.setSort(sortKey)
                                }
                            }

                            SortHeader {
                                id: sizeHeader

                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: dateHeader.left
                                anchors.rightMargin: root.columnGap

                                width: root.sizeColumnWidth
                                height: parent.height

                                label: "Size"
                                sortKey: "size"
                                activeSortKey: root.sortKey
                                descending: root.sortDescending
                                alignRight: true

                                onRequested: function(sortKey) {
                                    root.setSort(sortKey)
                                }
                            }

                            SortHeader {
                                id: dateHeader

                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: root.rowInset

                                width: root.dateColumnWidth
                                height: parent.height

                                label: "Date Modified"
                                sortKey: "date"
                                activeSortKey: root.sortKey
                                descending: root.sortDescending
                                alignRight: true

                                onRequested: function(sortKey) {
                                    root.setSort(sortKey)
                                }
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        height: parent.height
                            - root.toolbarHeight
                            - root.pathBarHeight
                            - root.headerHeight
                            - root.statusHeight

                        Rectangle {
                            width: parent.width - root.activePreviewWidth
                            height: parent.height

                            color: "transparent"
                            clip: true

                            ListView {
                                id: entriesView

                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                anchors.topMargin: 6
                                anchors.bottomMargin: 6

                                spacing: 1
                                model: entriesModel
                                clip: true

                                delegate: FileRow {
                                    width: entriesView.width

                                    visible: root.matchesSearch(name)
                                    height: visible ? 34 : 0

                                    name: model.name
                                    path: model.path
                                    kind: model.kind
                                    sizeText: model.sizeText
                                    modifiedText: model.modifiedText
                                    selected: root.selectedPath === model.path
                                    iconColumnWidth: root.iconColumnWidth
                                    sizeColumnWidth: root.sizeColumnWidth
                                    dateColumnWidth: root.dateColumnWidth
                                    columnGap: root.columnGap
                                    horizontalInset: root.rowInset

                                    onSelectedPath: function(path) {
                                        contextMenu.close()
                                        root.selectEntry(path)
                                    }

                                    onOpened: function(path, kind) {
                                        if (root.pickerActive && kind !== "directory") {
                                            root.selectEntry(path)
                                            root.finishPicker(true)
                                            return
                                        }

                                        if (kind !== "directory" && root.isImagePath(path)) {
                                            root.selectEntry(path)
                                            return
                                        }

                                        fileActions.openPath(path, kind)
                                    }

                                    onContextRequested: function(path, sceneX, sceneY) {
                                        root.selectEntry(path)
                                        root.openContextMenu(sceneX, sceneY)
                                    }
                                }
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                visible: !fileActions.loading && entriesModel.count === 0

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    text: "󰉖"
                                    color: WalTheme.fgMuted

                                    font.family: Theme.iconFontFamily
                                    font.pixelSize: 28
                                }

                                MetaText {
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    text: "Empty folder"
                                }
                            }
                        }

                        FilePreviewPane {
                            visible: root.selectedIsImage()

                            previewWidth: root.activePreviewWidth
                            height: parent.height
                            softBorder: root.softBorder
                            imageSource: root.selectedIsImage()
                                ? root.fileUrl(root.selectedPath)
                                : ""
                            selectedName: root.selectedName
                            selectedPath: root.selectedPath
                            selectedSizeText: root.selectedSizeText
                            selectedModifiedText: root.selectedModifiedText
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: root.statusHeight

                        color: "transparent"

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16

                            Row {
                                id: footerActions

                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter

                                spacing: 8

                                ActionButton {
                                    width: 118
                                    height: 24

                                    visible: root.pickerActive

                                    text: root.pickerDirectoryMode
                                        ? "Choose"
                                        : root.pickerSaveMode ? "Save" : "Select"
                                    accent: true
                                    fontSize: 11
                                    buttonRadius: 8
                                    opacity: root.pickerResultPath().length > 0 ? 1.0 : 0.45

                                    onClicked: {
                                        root.finishPicker(true)
                                    }
                                }

                                ActionButton {
                                    width: 92
                                    height: 24

                                    visible: root.pickerActive

                                    text: "Cancel"
                                    muted: true
                                    fontSize: 11
                                    buttonRadius: 8

                                    onClicked: {
                                        root.finishPicker(false)
                                    }
                                }

                                ActionButton {
                                    width: 118
                                    height: 24

                                    visible: fileActions.currentPlaceKind === "trash" && !root.pickerActive

                                    text: "Empty Trash"
                                    danger: true
                                    fontSize: 11
                                    buttonRadius: 8
                                    opacity: entriesModel.count > 0 && !fileActions.busy ? 1.0 : 0.45

                                    onClicked: {
                                        root.emptyTrash()
                                    }
                                }

                                ActionButton {
                                    id: openButton

                                    width: 118
                                    height: 24

                                    visible: !root.pickerActive

                                    text: "Open"
                                    fontSize: 11
                                    buttonRadius: 8
                                    opacity: root.selectedPath.length > 0 && !fileActions.opening ? 1.0 : 0.45

                                    onClicked: {
                                        root.openSelected()
                                    }
                                }
                            }

                            MetaText {
                                anchors.left: parent.left
                                anchors.right: footerActions.left
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter

                                text: root.clipboardPath.length > 0
                                    ? "Clipboard: " + (root.clipboardMode === "copy" ? "copy " : "move ") + root.clipboardName
                                    : root.pickerActive
                                        ? root.pickerDirectoryMode
                                            ? "Choose a folder"
                                            : root.pickerSaveMode
                                                ? "Save as " + root.pickerSaveName
                                                : "Select a file"
                                    : root.selectedPath.length > 0
                                        ? root.selectedPath
                                        : root.statusText

                                font.pixelSize: 11
                                elide: Text.ElideMiddle
                            }
                        }
                    }
                }
            }

        }

        FileContextMenu {
            id: contextMenu

            hasSelection: root.selectedPath.length > 0
            canPaste: root.clipboardPath.length > 0
            inTrash: fileActions.currentPlaceKind === "trash"
            busy: fileActions.busy

            onOpenRequested: {
                root.openSelected()
            }

            onNewFolderRequested: {
                root.openNewFolderDialog()
            }

            onCopyRequested: {
                root.beginCopySelected()
            }

            onCutRequested: {
                root.beginMoveSelected()
            }

            onPasteRequested: {
                root.pasteClipboard()
            }

            onRenameRequested: {
                root.openRenameDialog()
            }

            onTrashRequested: {
                root.trashSelected()
            }

            onEmptyTrashRequested: {
                root.emptyTrash()
            }

            onReloadRequested: {
                fileActions.reload()
            }
        }

        TextPromptDialog {
            id: newFolderDialog

            title: "New Folder"
            label: "Name"
            placeholder: "Folder name"
            acceptText: "Create"

            onAccepted: function(name) {
                fileActions.createDirectory(name)
            }
        }

        TextPromptDialog {
            id: renameDialog

            title: "Rename"
            label: "Name"
            placeholder: "File name"
            acceptText: "Rename"

            onAccepted: function(name) {
                fileActions.renamePath(root.selectedPath, name)
            }
        }
    }

    Component.onCompleted: {
        fileActions.reload()
        fileActions.refreshDevices()
    }
}
