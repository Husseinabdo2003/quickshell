import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string trashDir: homeDir + "/.local/share/Trash/files"

    property string currentDir: homeDir
    property string currentPlaceKind: "folder"
    property string pendingOpenPath: ""
    property string pendingCreateName: ""
    property string pendingCreatePath: ""
    property string pendingMovePath: ""
    property string pendingMoveTargetDir: ""
    property string pendingCopyPath: ""
    property string pendingCopyTargetDir: ""
    property string pendingRenamePath: ""
    property string pendingRenameNewPath: ""
    property string pendingTrashPath: ""
    property string pendingDevicePath: ""
    property string pendingDeviceMountPath: ""

    readonly property bool loading: listProcess.running
    readonly property bool opening: openProcess.running
    readonly property bool loadingDevices: deviceListProcess.running
    readonly property bool busy: listProcess.running
        || openProcess.running
        || createDirectoryProcess.running
        || movePathProcess.running
        || copyPathProcess.running
        || renamePathProcess.running
        || trashPathProcess.running
        || emptyTrashProcess.running
        || mountDeviceProcess.running
        || unmountDeviceProcess.running

    signal entryFound(string path, string name, string kind, string sizeText, string modifiedText, real sizeValue, string modifiedValue)
    signal listStarted()
    signal listFinished(int exitCode)
    signal openFailed(string path)
    signal directoryCreated(string path)
    signal directoryCreateFailed(string name)
    signal pathMoved(string sourcePath, string targetDir)
    signal pathMoveFailed(string sourcePath, string targetDir)
    signal pathCopied(string sourcePath, string targetDir)
    signal pathCopyFailed(string sourcePath, string targetDir)
    signal pathRenamed(string sourcePath, string newPath)
    signal pathRenameFailed(string sourcePath, string newPath)
    signal pathTrashed(string path)
    signal pathTrashFailed(string path)
    signal trashEmptied()
    signal trashEmptyFailed()
    signal deviceListStarted()
    signal deviceFound(string label, string path, string icon, string blockPath, bool mounted, bool removable, bool canUnmount, string status)
    signal deviceListFinished()
    signal deviceMounted(string blockPath, string mountPath)
    signal deviceMountFailed(string blockPath)
    signal deviceUnmounted(string blockPath)
    signal deviceUnmountFailed(string blockPath)

    function shellQuote(value) {
        return "'" + String(value || "").replace(/'/g, "'\\''") + "'"
    }

    function fileName(path) {
        const cleanPath = String(path || "")
        const parts = cleanPath.split("/")
        return parts[parts.length - 1] || cleanPath
    }

    function parentDir(path) {
        const cleanPath = String(path || root.homeDir)

        if (cleanPath === "/")
            return "/"

        const trimmed = cleanPath.replace(/\/+$/, "")
        const index = trimmed.lastIndexOf("/")

        if (index <= 0)
            return "/"

        return trimmed.slice(0, index)
    }

    function goHome() {
        listDirectory(root.homeDir)
    }

    function goUp() {
        if (root.currentPlaceKind === "trash" && root.currentDir === root.trashDir)
            return

        listDirectory(parentDir(root.currentDir), root.currentPlaceKind)
    }

    function reload() {
        if (root.currentPlaceKind === "trash")
            listTrash()
        else
            listDirectory(root.currentDir)
    }

    function listTrash() {
        listDirectory(root.trashDir, "trash")
    }

    function listDirectory(path, placeKind) {
        if (listProcess.running)
            return

        const cleanPath = String(path || root.homeDir)
        const cleanKind = String(placeKind || "folder")

        root.currentDir = cleanPath
        root.currentPlaceKind = cleanKind
        root.listStarted()

        const command = ""
            + "dir=" + root.shellQuote(cleanPath) + "; "
            + "if [ ! -d \"$dir\" ]; then exit 2; fi; "
            + "find \"$dir\" -mindepth 1 -maxdepth 1 "
            + "-printf '%y\\t%s\\t%TY-%Tm-%Td %TH:%TM\\t%p\\n' "
            + "| sort -k1,1 -k4,4f"

        listProcess.exec([
            "bash",
            "-lc",
            command
        ])
    }

    function refreshDevices() {
        if (deviceListProcess.running)
            return

        root.deviceListStarted()

        deviceListProcess.exec([
            "lsblk",
            "-P",
            "-o",
            "NAME,PATH,LABEL,MOUNTPOINT,RM,TYPE,FSTYPE,SIZE,MODEL,TRAN,HOTPLUG"
        ])
    }

    function mountDevice(blockPath) {
        const cleanPath = String(blockPath || "")

        if (cleanPath.length === 0 || mountDeviceProcess.running)
            return

        root.pendingDevicePath = cleanPath
        root.pendingDeviceMountPath = ""

        mountDeviceProcess.exec([
            "udisksctl",
            "mount",
            "-b",
            cleanPath
        ])
    }

    function unmountDevice(blockPath) {
        const cleanPath = String(blockPath || "")

        if (cleanPath.length === 0 || unmountDeviceProcess.running)
            return

        root.pendingDevicePath = cleanPath

        unmountDeviceProcess.exec([
            "udisksctl",
            "unmount",
            "-b",
            cleanPath
        ])
    }

    function openPath(path, kind) {
        const cleanPath = String(path || "")

        if (cleanPath.length === 0)
            return

        if (kind === "directory") {
            listDirectory(cleanPath, root.currentPlaceKind)
            return
        }

        if (openProcess.running)
            return

        root.pendingOpenPath = cleanPath
        openProcess.exec([
            "xdg-open",
            cleanPath
        ])
    }

    function createDirectory(name) {
        const cleanName = String(name || "").trim()

        if (cleanName.length === 0 || createDirectoryProcess.running)
            return

        if (cleanName.indexOf("/") !== -1) {
            root.directoryCreateFailed(cleanName)
            return
        }

        root.pendingCreateName = cleanName
        root.pendingCreatePath = root.currentDir + "/" + cleanName

        const command = ""
            + "target=" + root.shellQuote(root.pendingCreatePath) + "; "
            + "if [ -e \"$target\" ]; then exit 3; fi; "
            + "mkdir -- \"$target\""

        createDirectoryProcess.exec([
            "bash",
            "-lc",
            command
        ])
    }

    function movePath(sourcePath, targetDir) {
        const cleanSource = String(sourcePath || "")
        const cleanTargetDir = String(targetDir || root.currentDir)

        if (cleanSource.length === 0 || cleanTargetDir.length === 0 || movePathProcess.running)
            return

        root.pendingMovePath = cleanSource
        root.pendingMoveTargetDir = cleanTargetDir

        const command = ""
            + "src=" + root.shellQuote(cleanSource) + "; "
            + "dst_dir=" + root.shellQuote(cleanTargetDir) + "; "
            + "if [ ! -e \"$src\" ] || [ ! -d \"$dst_dir\" ]; then exit 2; fi; "
            + "case \"$dst_dir\" in \"$src\"|\"$src\"/*) exit 4;; esac; "
            + "base=\"$(basename -- \"$src\")\"; "
            + "dst=\"$dst_dir/$base\"; "
            + "if [ -e \"$dst\" ]; then exit 3; fi; "
            + "mv -- \"$src\" \"$dst\""

        movePathProcess.exec([
            "bash",
            "-lc",
            command
        ])
    }

    function copyPath(sourcePath, targetDir) {
        const cleanSource = String(sourcePath || "")
        const cleanTargetDir = String(targetDir || root.currentDir)

        if (cleanSource.length === 0 || cleanTargetDir.length === 0 || copyPathProcess.running)
            return

        root.pendingCopyPath = cleanSource
        root.pendingCopyTargetDir = cleanTargetDir

        const command = ""
            + "src=" + root.shellQuote(cleanSource) + "; "
            + "dst_dir=" + root.shellQuote(cleanTargetDir) + "; "
            + "if [ ! -e \"$src\" ] || [ ! -d \"$dst_dir\" ]; then exit 2; fi; "
            + "case \"$dst_dir\" in \"$src\"|\"$src\"/*) exit 4;; esac; "
            + "base=\"$(basename -- \"$src\")\"; "
            + "dst=\"$dst_dir/$base\"; "
            + "if [ -e \"$dst\" ]; then exit 3; fi; "
            + "cp -a -- \"$src\" \"$dst\""

        copyPathProcess.exec([
            "bash",
            "-lc",
            command
        ])
    }

    function renamePath(path, newName) {
        const cleanPath = String(path || "")
        const cleanName = String(newName || "").trim()

        if (cleanPath.length === 0 || cleanName.length === 0 || renamePathProcess.running)
            return

        if (cleanName.indexOf("/") !== -1) {
            root.pathRenameFailed(cleanPath, "")
            return
        }

        const targetPath = root.parentDir(cleanPath) + "/" + cleanName

        root.pendingRenamePath = cleanPath
        root.pendingRenameNewPath = targetPath

        const command = ""
            + "src=" + root.shellQuote(cleanPath) + "; "
            + "dst=" + root.shellQuote(targetPath) + "; "
            + "if [ ! -e \"$src\" ]; then exit 2; fi; "
            + "if [ \"$src\" = \"$dst\" ]; then exit 0; fi; "
            + "if [ -e \"$dst\" ]; then exit 3; fi; "
            + "mv -- \"$src\" \"$dst\""

        renamePathProcess.exec([
            "bash",
            "-lc",
            command
        ])
    }

    function trashPath(path) {
        const cleanPath = String(path || "")

        if (cleanPath.length === 0 || trashPathProcess.running)
            return

        root.pendingTrashPath = cleanPath

        const command = ""
            + "target=" + root.shellQuote(cleanPath) + "; "
            + "if [ ! -e \"$target\" ]; then exit 2; fi; "
            + "if command -v gio >/dev/null 2>&1; then "
            + "gio trash -- \"$target\"; "
            + "elif command -v trash-put >/dev/null 2>&1; then "
            + "trash-put -- \"$target\"; "
            + "else exit 5; fi"

        trashPathProcess.exec([
            "bash",
            "-lc",
            command
        ])
    }

    function emptyTrash() {
        if (emptyTrashProcess.running)
            return

        emptyTrashProcess.exec([
            "gio",
            "trash",
            "--empty"
        ])
    }

    function lsblkValue(line, key) {
        const expression = new RegExp(key + "=\"([^\"]*)\"")
        const match = expression.exec(line)

        return match ? match[1] : ""
    }

    function shouldShowDevice(type, fstype, mounted, removable, hotplug, transport, mountPoint, blockPath) {
        if (type !== "part" && type !== "disk")
            return false

        if (blockPath.indexOf("/dev/loop") === 0)
            return false

        if (mountPoint.indexOf("/snap/") === 0)
            return false

        if (mounted)
            return true

        if (fstype.length === 0)
            return false

        return removable || hotplug || transport === "usb"
    }

    function deviceLabel(name, label, mountPoint, size, model) {
        if (mountPoint === "/")
            return "System"

        if (label.length > 0)
            return label

        if (mountPoint.length > 0)
            return root.fileName(mountPoint)

        if (model.length > 0)
            return model

        return name.length > 0 ? name : "Disk"
    }

    function kindFromType(typeCode) {
        if (typeCode === "d")
            return "directory"

        if (typeCode === "l")
            return "link"

        return "file"
    }

    function sizeLabel(kind, rawSize) {
        if (kind === "directory")
            return "Folder"

        const size = Number(rawSize || 0)

        if (size < 1024)
            return size + " B"

        if (size < 1024 * 1024)
            return Math.round(size / 102.4) / 10 + " KB"

        if (size < 1024 * 1024 * 1024)
            return Math.round(size / 1024 / 102.4) / 10 + " MB"

        return Math.round(size / 1024 / 1024 / 102.4) / 10 + " GB"
    }

    Process {
        id: listProcess

        stdout: SplitParser {
            onRead: function(data) {
                const line = String(data || "")

                if (line.trim().length === 0)
                    return

                const fields = line.split("\t")

                if (fields.length < 4)
                    return

                const kind = root.kindFromType(fields[0])
                const sizeText = root.sizeLabel(kind, fields[1])
                const modifiedText = fields[2].slice(0, 16)
                const path = fields.slice(3).join("\t")

                root.entryFound(
                    path,
                    root.fileName(path),
                    kind,
                    sizeText,
                    modifiedText,
                    Number(fields[1] || 0),
                    modifiedText
                )
            }
        }

        onExited: function(exitCode) {
            root.listFinished(exitCode)
        }
    }

    Process {
        id: deviceListProcess

        stdout: SplitParser {
            onRead: function(data) {
                const line = String(data || "")

                if (line.trim().length === 0)
                    return

                const name = root.lsblkValue(line, "NAME")
                const blockPath = root.lsblkValue(line, "PATH")
                const label = root.lsblkValue(line, "LABEL")
                const mountPoint = root.lsblkValue(line, "MOUNTPOINT")
                const removable = root.lsblkValue(line, "RM") === "1"
                const type = root.lsblkValue(line, "TYPE")
                const fstype = root.lsblkValue(line, "FSTYPE")
                const size = root.lsblkValue(line, "SIZE")
                const model = root.lsblkValue(line, "MODEL")
                const transport = root.lsblkValue(line, "TRAN")
                const hotplug = root.lsblkValue(line, "HOTPLUG") === "1"
                const mounted = mountPoint.length > 0
                const canUnmount = mounted && mountPoint !== "/" && mountPoint.indexOf("/boot") !== 0

                if (!root.shouldShowDevice(type, fstype, mounted, removable, hotplug, transport, mountPoint, blockPath))
                    return

                root.deviceFound(
                    root.deviceLabel(name, label, mountPoint, size, model),
                    mountPoint,
                    removable || hotplug || transport === "usb" ? "󰕓" : "󰋊",
                    blockPath,
                    mounted,
                    removable || hotplug || transport === "usb",
                    canUnmount,
                    mounted ? size : "Not mounted"
                )
            }
        }

        onExited: function(exitCode) {
            root.deviceListFinished()
        }
    }

    Process {
        id: mountDeviceProcess

        stdout: SplitParser {
            onRead: function(data) {
                const line = String(data || "")
                const match = / at (.*)\.$/.exec(line.trim())

                if (match)
                    root.pendingDeviceMountPath = match[1]
            }
        }

        onExited: function(exitCode) {
            const blockPath = root.pendingDevicePath
            const mountPath = root.pendingDeviceMountPath

            root.pendingDevicePath = ""
            root.pendingDeviceMountPath = ""

            if (exitCode === 0) {
                root.deviceMounted(blockPath, mountPath)
                return
            }

            root.deviceMountFailed(blockPath)
        }
    }

    Process {
        id: unmountDeviceProcess

        onExited: function(exitCode) {
            const blockPath = root.pendingDevicePath

            root.pendingDevicePath = ""

            if (exitCode === 0) {
                root.deviceUnmounted(blockPath)
                return
            }

            root.deviceUnmountFailed(blockPath)
        }
    }

    Process {
        id: openProcess

        onExited: function(exitCode) {
            const path = root.pendingOpenPath
            root.pendingOpenPath = ""

            if (exitCode !== 0)
                root.openFailed(path)
        }
    }

    Process {
        id: createDirectoryProcess

        onExited: function(exitCode) {
            const name = root.pendingCreateName
            const path = root.pendingCreatePath

            root.pendingCreateName = ""
            root.pendingCreatePath = ""

            if (exitCode === 0) {
                root.directoryCreated(path)
                return
            }

            root.directoryCreateFailed(name)
        }
    }

    Process {
        id: movePathProcess

        onExited: function(exitCode) {
            const sourcePath = root.pendingMovePath
            const targetDir = root.pendingMoveTargetDir

            root.pendingMovePath = ""
            root.pendingMoveTargetDir = ""

            if (exitCode === 0) {
                root.pathMoved(sourcePath, targetDir)
                return
            }

            root.pathMoveFailed(sourcePath, targetDir)
        }
    }

    Process {
        id: copyPathProcess

        onExited: function(exitCode) {
            const sourcePath = root.pendingCopyPath
            const targetDir = root.pendingCopyTargetDir

            root.pendingCopyPath = ""
            root.pendingCopyTargetDir = ""

            if (exitCode === 0) {
                root.pathCopied(sourcePath, targetDir)
                return
            }

            root.pathCopyFailed(sourcePath, targetDir)
        }
    }

    Process {
        id: renamePathProcess

        onExited: function(exitCode) {
            const sourcePath = root.pendingRenamePath
            const newPath = root.pendingRenameNewPath

            root.pendingRenamePath = ""
            root.pendingRenameNewPath = ""

            if (exitCode === 0) {
                root.pathRenamed(sourcePath, newPath)
                return
            }

            root.pathRenameFailed(sourcePath, newPath)
        }
    }

    Process {
        id: trashPathProcess

        onExited: function(exitCode) {
            const path = root.pendingTrashPath

            root.pendingTrashPath = ""

            if (exitCode === 0) {
                root.pathTrashed(path)
                return
            }

            root.pathTrashFailed(path)
        }
    }

    Process {
        id: emptyTrashProcess

        onExited: function(exitCode) {
            if (exitCode === 0) {
                root.trashEmptied()
                return
            }

            root.trashEmptyFailed()
        }
    }
}
