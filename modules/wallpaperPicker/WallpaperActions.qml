import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string wallpaperDir: "/home/hussein/Pictures/Wallpapers"
    property string applyScript: "/home/hussein/.config/hypr/scripts/wallpaper-picker.lua"
    property string currentWallpaperCache: "/home/hussein/.cache/current-wallpaper"
    property string fallbackWallpaper: "/home/hussein/Pictures/wallpaper.png"

    signal currentWallpaperRead(string path)
    signal wallpaperFound(string path, string name, string url)
    signal wallpaperApplied(string path)
    signal wallpaperRestored(string path)

    function readCurrentWallpaper() {
        readCurrentWallpaperProcess.exec([
            "bash",
            "-lc",
            "cat '" + root.currentWallpaperCache + "' 2>/dev/null || true"
        ])
    }

    function listWallpapers() {
        listWallpapersProcess.exec([
            "bash",
            "-lc",
            "find '" + root.wallpaperDir + "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"
        ])
    }

    function applyWallpaper(path) {
        if (!path || path.length === 0)
            return

        applyWallpaperProcess.exec([
            root.applyScript,
            path
        ])

        root.wallpaperApplied(path)
    }

    function restoreWallpaper() {
        restoreWallpaperProcess.exec([
            "bash",
            "-lc",
            "wallpaper=\"$(cat '" + root.currentWallpaperCache + "' 2>/dev/null || true)\"; " +
            "if [ -z \"$wallpaper\" ] || [ ! -f \"$wallpaper\" ]; then wallpaper='" + root.fallbackWallpaper + "'; fi; " +
            "if [ -f \"$wallpaper\" ]; then '" + root.applyScript + "' \"$wallpaper\"; printf '%s' \"$wallpaper\"; fi"
        ])
    }

    Process {
        id: readCurrentWallpaperProcess

        stdout: SplitParser {
            onRead: function(data) {
                if (!data)
                    return

                root.currentWallpaperRead(data.trim())
            }
        }
    }

    Process {
        id: listWallpapersProcess

        stdout: SplitParser {
            onRead: function(data) {
                if (!data)
                    return

                const path = data.trim()

                if (path.length === 0)
                    return

                const parts = path.split("/")
                const name = parts[parts.length - 1]
                const url = "file://" + path

                root.wallpaperFound(path, name, url)
            }
        }
    }

    Process {
        id: applyWallpaperProcess
    }

    Process {
        id: restoreWallpaperProcess

        stdout: SplitParser {
            onRead: function(data) {
                if (!data)
                    return

                const path = data.trim()

                if (path.length === 0)
                    return

                root.wallpaperRestored(path)
            }
        }
    }
}