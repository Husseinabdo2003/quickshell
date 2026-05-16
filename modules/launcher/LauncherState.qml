import QtQuick
import Quickshell

Item {
    id: root

    visible: false

    property string query: ""
    property string activeCategory: "all"
    property int selectedIndex: 0

    property int maxResults: 999

    property var apps: []
    property var filteredApps: []

    property int loadAttempts: 0
    readonly property int maxLoadAttempts: 12

    readonly property var selectedApp: filteredApps.length > 0
        ? filteredApps[Math.max(0, Math.min(selectedIndex, filteredApps.length - 1))]
        : null

    Timer {
        id: retryLoadTimer

        interval: 120
        repeat: false

        onTriggered: {
            root.loadApps()
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

        if (visibleApps.length === 0 && root.loadAttempts < root.maxLoadAttempts) {
            root.loadAttempts += 1
            retryLoadTimer.restart()
            return
        }

        visibleApps.sort(function(a, b) {
            return root.appName(a).localeCompare(root.appName(b))
        })

        root.apps = visibleApps
        root.updateFilteredApps()
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

        root.filteredApps = results.slice(0, root.maxResults)

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
        retryLoadTimer.stop()

        root.query = ""
        root.activeCategory = "all"
        root.selectedIndex = 0
        root.loadAttempts = 0

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
}