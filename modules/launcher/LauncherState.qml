import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    visible: false

    property string query: ""
    property string activeCategory: "all"
    property string countsPath: Quickshell.env("HOME") + "/.cache/quickshell/launch-counts.json"
    property int selectedIndex: 0

    property int maxResults: 999

    property var apps: []
    property var filteredApps: []
    property var launchCounts: ({})

    readonly property var selectedApp: filteredApps.length > 0
        ? filteredApps[Math.max(0, Math.min(selectedIndex, filteredApps.length - 1))]
        : null

    Process {
        id: readCountsProcess

        command: []
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.applyCountsText(this.text)
            }
        }

        stderr: StdioCollector {}
    }

    Process {
        id: writeCountsProcess

        command: []
        running: false

        stdout: StdioCollector {}
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0)
                    console.log("Launcher counts write stderr:", this.text.trim())
            }
        }
    }

    function getValue(object, key, fallback) {
        if (!object)
            return fallback

        try {
            const value = object[key]

            if (value === undefined || value === null)
                return fallback

            return value
        } catch (error) {
            return fallback
        }
    }

    function getString(object, key) {
        const value = root.getValue(object, key, "")

        try {
            return String(value || "").trim()
        } catch (error) {
            return ""
        }
    }

    function getBool(object, key) {
        const value = root.getValue(object, key, false)

        try {
            if (typeof value === "boolean")
                return value

            const text = String(value || "").toLowerCase().trim()

            return text === "true"
                || text === "1"
                || text === "yes"
        } catch (error) {
            return false
        }
    }

    function getArray(object, key) {
        const value = root.getValue(object, key, [])

        try {
            if (!value)
                return []

            if (Array.isArray(value))
                return value.slice()

            if (value.length !== undefined) {
                const result = []

                for (let i = 0; i < value.length; i++)
                    result.push(String(value[i] || ""))

                return result
            }

            return []
        } catch (error) {
            return []
        }
    }

    function clean(value) {
        try {
            return String(value || "").toLowerCase().trim()
        } catch (error) {
            return ""
        }
    }

    function appId(app) {
        if (!app)
            return ""

        try {
            return String(app.id || app.name || "").trim()
        } catch (error) {
            return ""
        }
    }

    function launchCountFor(app) {
        if (!app)
            return 0

        const id = root.appId(app)

        if (id.length === 0)
            return 0

        try {
            const value = root.launchCounts[id]
            const count = Number(value || 0)

            if (isNaN(count))
                return 0

            return count
        } catch (error) {
            return 0
        }
    }

    function applyCountsText(rawText) {
        try {
            const raw = String(rawText || "").trim()

            if (raw.length === 0) {
                root.launchCounts = ({})
                root.updateFilteredApps()
                return
            }

            const parsed = JSON.parse(raw)

            if (!parsed) {
                root.launchCounts = ({})
                root.updateFilteredApps()
                return
            }

            root.launchCounts = parsed
            root.updateFilteredApps()
        } catch (error) {
            console.log("Launcher counts parse failed:", error)
            root.launchCounts = ({})
            root.updateFilteredApps()
        }
    }

    function loadCounts() {
        readCountsProcess.exec([
            "cat",
            root.countsPath
        ])
    }

    function writeCounts() {
        let payload = "{}"

        try {
            payload = JSON.stringify(root.launchCounts)
        } catch (error) {
            payload = "{}"
        }

        writeCountsProcess.exec([
            "python3",
            "-c",
            "import json, os, sys\npath = sys.argv[1]\ndata = sys.argv[2]\nos.makedirs(os.path.dirname(path), exist_ok=True)\njson.loads(data)\nopen(path, 'w', encoding='utf-8').write(data + '\\n')\n",
            root.countsPath,
            payload
        ])
    }

    function incrementCount(appId) {
        const id = String(appId || "").trim()

        if (id.length === 0)
            return

        const nextCounts = Object.assign({}, root.launchCounts)

        try {
            nextCounts[id] = Number(nextCounts[id] || 0) + 1
        } catch (error) {
            nextCounts[id] = 1
        }

        root.launchCounts = nextCounts
        root.updateFilteredApps()
        root.writeCounts()
    }

    function makeSafeApp(entry) {
        if (!entry)
            return null

        const noDisplay = root.getBool(entry, "noDisplay")

        if (noDisplay)
            return null

        const name = root.getString(entry, "name")

        if (name.length === 0)
            return null

        const genericName = root.getString(entry, "genericName")
        const comment = root.getString(entry, "comment")
        const id = root.getString(entry, "id")
        const icon = root.getString(entry, "icon")
        const command = root.getString(entry, "command")
        const keywords = root.getArray(entry, "keywords")
        const categories = root.getArray(entry, "categories")

        const searchText = [
            name,
            genericName,
            comment,
            id,
            command,
            keywords.join(" "),
            categories.join(" ")
        ].join(" ").toLowerCase()

        const categoryText = categories.join(" ").toLowerCase()

        return {
            name: name,
            genericName: genericName,
            comment: comment,
            id: id,
            icon: icon,
            command: command,
            keywords: keywords,
            categories: categories,
            searchText: searchText,
            categoryText: categoryText,
            entry: entry
        }
    }

    function appName(app) {
        if (!app)
            return ""

        try {
            return String(app.name || "").trim()
        } catch (error) {
            return ""
        }
    }

    function appText(app) {
        if (!app)
            return ""

        try {
            return String(app.searchText || "").toLowerCase()
        } catch (error) {
            return ""
        }
    }

    function appCategories(app) {
        if (!app)
            return ""

        try {
            return String(app.categoryText || "").toLowerCase()
        } catch (error) {
            return ""
        }
    }

    function matchesCategory(app) {
        if (root.activeCategory === "all")
            return true

        const text = root.appText(app)
        const cats = root.appCategories(app)

        if (root.activeCategory === "terminal") {
            return text.indexOf("terminal") !== -1
                || text.indexOf("console") !== -1
                || cats.indexOf("terminalemulator") !== -1
        }

        if (root.activeCategory === "browser") {
            return text.indexOf("browser") !== -1
                || text.indexOf("web") !== -1
                || cats.indexOf("network") !== -1
                || cats.indexOf("webbrowser") !== -1
        }

        if (root.activeCategory === "files") {
            return text.indexOf("files") !== -1
                || text.indexOf("file manager") !== -1
                || cats.indexOf("filemanager") !== -1
                || cats.indexOf("filesystem") !== -1
        }

        if (root.activeCategory === "settings") {
            return text.indexOf("settings") !== -1
                || text.indexOf("control center") !== -1
                || text.indexOf("preferences") !== -1
                || cats.indexOf("settings") !== -1
        }

        return true
    }

    function loadApps() {
        let allApps = []

        try {
            allApps = DesktopEntries.applications.values || []
        } catch (error) {
            allApps = []
        }

        const visibleApps = []

        for (let i = 0; i < allApps.length; i++) {
            const safeApp = root.makeSafeApp(allApps[i])

            if (safeApp)
                visibleApps.push(safeApp)
        }

        root.sortApps(visibleApps)

        root.apps = visibleApps
        root.updateFilteredApps()
    }

    function sortApps(list) {
        if (!Array.isArray(list))
            return []

        list.sort(function(a, b) {
            const countDiff = root.launchCountFor(b) - root.launchCountFor(a)

            if (countDiff !== 0)
                return countDiff

            return root.appName(a).localeCompare(root.appName(b))
        })

        return list
    }

    function updateFilteredApps() {
        const q = root.clean(root.query)

        const results = root.apps.filter(function(app) {
            if (!app)
                return false

            if (!root.matchesCategory(app))
                return false

            if (q.length === 0)
                return true

            return root.appText(app).indexOf(q) !== -1
        })

        root.filteredApps = root.sortApps(results).slice(0, root.maxResults)

        if (root.selectedIndex >= root.filteredApps.length)
            root.selectedIndex = Math.max(0, root.filteredApps.length - 1)

        if (root.selectedIndex < 0)
            root.selectedIndex = 0
    }

    function setCategory(category) {
        root.activeCategory = category
        root.selectedIndex = 0
        root.updateFilteredApps()
    }

    function reset() {
        root.query = ""
        root.activeCategory = "all"
        root.selectedIndex = 0

        root.apps = []
        root.filteredApps = []

        root.loadApps()
    }

    function moveDown() {
        root.selectedIndex = Math.min(
            root.selectedIndex + 1,
            Math.max(0, root.filteredApps.length - 1)
        )
    }

    function moveUp() {
        root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
    }

    Component.onCompleted: {
        root.loadCounts()
        root.loadApps()
    }
}
