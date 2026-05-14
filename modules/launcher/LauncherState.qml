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

    function clean(value) {
        return String(value || "").toLowerCase().trim()
    }

    function appName(app) {
        if (!app)
            return ""

        if (app.name && String(app.name).length > 0)
            return String(app.name)

        return ""
    }

    function appText(app) {
        if (!app)
            return ""

        const parts = []

        if (app.name)
            parts.push(String(app.name))

        if (app.genericName)
            parts.push(String(app.genericName))

        if (app.comment)
            parts.push(String(app.comment))

        if (app.id)
            parts.push(String(app.id))

        if (app.keywords && app.keywords.length > 0)
            parts.push(app.keywords.join(" "))

        if (app.categories && app.categories.length > 0)
            parts.push(app.categories.join(" "))

        return parts.join(" ").toLowerCase()
    }

    function appCategories(app) {
        if (!app || !app.categories)
            return ""

        return app.categories.join(" ").toLowerCase()
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
                || cats.indexOf("system") !== -1
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
        const allApps = DesktopEntries.applications.values || []

        const visibleApps = allApps.filter(function(app) {
            return app
                && !app.noDisplay
                && root.appName(app).length > 0
        })

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

        let results = root.apps.filter(function(app) {
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