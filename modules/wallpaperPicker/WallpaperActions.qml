import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string wallpaperDir: "/home/hussein/Pictures/Wallpapers"
    property string applyScript: "/home/hussein/.config/hypr/scripts/wallpaper-picker.lua"
    property string luaBinary: "lua"
    property string currentWallpaperCache: "/home/hussein/.cache/current-wallpaper"
    property string fallbackWallpaper: "/home/hussein/Pictures/wallpaper.png"

    property string pendingApplyPath: ""
    property string pendingRestorePath: ""

    readonly property bool applying: applyWallpaperProcess.running || restoreWallpaperProcess.running

    signal currentWallpaperRead(string path)
    signal wallpaperFound(string path, string name, string url)
    signal wallpaperApplied(string path)
    signal wallpaperRestored(string path)
    signal wallpaperApplyFailed(string path)
    signal wallpaperRestoreFailed(string path)

    function shellQuote(value) {
        return "'" + String(value || "").replace(/'/g, "'\\''") + "'"
    }

    function fileUrl(path) {
        const cleanPath = String(path || "")

        if (cleanPath.length === 0)
            return ""

        return "file://" + encodeURI(cleanPath)
    }

    function readCurrentWallpaper() {
        if (readCurrentWallpaperProcess.running)
            return

        readCurrentWallpaperProcess.exec([
            "bash",
            "-lc",
            "cat " + root.shellQuote(root.currentWallpaperCache) + " 2>/dev/null || true"
        ])
    }

    function listWallpapers() {
        if (listWallpapersProcess.running)
            return

        const command = "find "
            + root.shellQuote(root.wallpaperDir)
            + " -maxdepth 1 -type f \\( "
            + "-iname '*.jpg' -o "
            + "-iname '*.jpeg' -o "
            + "-iname '*.png' -o "
            + "-iname '*.webp' "
            + "\\) | sort"

        listWallpapersProcess.exec([
            "bash",
            "-lc",
            command
        ])
    }

    function applyWallpaper(path) {
        const cleanPath = String(path || "")

        if (cleanPath.length === 0)
            return

        if (root.applying)
            return

        root.pendingApplyPath = cleanPath

        applyWallpaperProcess.exec([
            root.luaBinary,
            root.applyScript,
            cleanPath
        ])
    }

    function restoreWallpaper() {
        if (root.applying)
            return

        root.pendingRestorePath = ""

        const command = ""
            + "wallpaper=\"$(cat " + root.shellQuote(root.currentWallpaperCache) + " 2>/dev/null || true)\"; "
            + "if [ -z \"$wallpaper\" ] || [ ! -f \"$wallpaper\" ]; then wallpaper=" + root.shellQuote(root.fallbackWallpaper) + "; fi; "
            + "if [ -f \"$wallpaper\" ]; then "
            + root.shellQuote(root.luaBinary) + " " + root.shellQuote(root.applyScript) + " \"$wallpaper\" && printf '%s\\n' \"$wallpaper\"; "
            + "else "
            + "exit 1; "
            + "fi"

        restoreWallpaperProcess.exec([
            "bash",
            "-lc",
            command
        ])
    }

    Process {
        id: readCurrentWallpaperProcess

        stdout: SplitParser {
            onRead: function(data) {
                const path = String(data || "").trim()

                if (path.length === 0)
                    return

                root.currentWallpaperRead(path)
            }
        }
    }

    Process {
        id: listWallpapersProcess

        stdout: SplitParser {
            onRead: function(data) {
                const path = String(data || "").trim()

                if (path.length === 0)
                    return

                const parts = path.split("/")
                const name = parts[parts.length - 1]
                const url = root.fileUrl(path)

                root.wallpaperFound(path, name, url)
            }
        }
    }

    Process {
        id: applyWallpaperProcess

        onExited: function(exitCode) {
            const path = root.pendingApplyPath
            root.pendingApplyPath = ""

            if (exitCode === 0) {
                root.wallpaperApplied(path)
                return
            }

            root.wallpaperApplyFailed(path)
        }
    }

    Process {
        id: restoreWallpaperProcess

        stdout: SplitParser {
            onRead: function(data) {
                const path = String(data || "").trim()

                if (path.length === 0)
                    return

                root.pendingRestorePath = path
            }
        }

        onExited: function(exitCode) {
            const path = root.pendingRestorePath
            root.pendingRestorePath = ""

            if (exitCode === 0 && path.length > 0) {
                root.wallpaperRestored(path)
                return
            }

            root.wallpaperRestoreFailed(path)
        }
    }
}