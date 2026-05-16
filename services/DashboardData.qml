pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string dashboardPath: Quickshell.env("HOME") + "/.config/quickshell/data/dashboard.json"

    property var items: []
    property bool loaded: false
    property string lastError: ""

    function clean(value) {
        try {
            if (value === undefined || value === null)
                return ""

            return String(value).trim()
        } catch (error) {
            return ""
        }
    }

    function normalizePriority(value) {
        const priority = root.clean(value).toLowerCase()

        if (priority === "high")
            return "high"

        if (priority === "low")
            return "low"

        return "medium"
    }

    function normalizeCategory(value) {
        const category = root.clean(value).toLowerCase()

        if (category === "exams")
            return "exams"

        if (category === "projects")
            return "projects"

        return "todo"
    }

    function normalizeStatus(value) {
        const status = root.clean(value).toLowerCase()

        if (status.length === 0)
            return "upcoming"

        return status
    }

    function normalizeType(value, category) {
        const type = root.clean(value).toLowerCase()

        if (type.length > 0)
            return type

        if (category === "exams")
            return "exam"

        if (category === "projects")
            return "project"

        return "task"
    }

    function fallbackId(index, item) {
        const title = item && item.title !== undefined ? root.clean(item.title) : ""
        const date = item && item.date !== undefined ? root.clean(item.date) : ""

        return "item-" + index + "-" + title + "-" + date
    }

    function normalizeItem(item, index) {
        if (!item)
            item = {}

        const category = root.normalizeCategory(item.category)

        return {
            id: root.clean(item.id).length > 0
                ? root.clean(item.id)
                : root.fallbackId(index, item),

            category: category,
            type: root.normalizeType(item.type, category),
            title: root.clean(item.title),
            course: root.clean(item.course),
            date: root.clean(item.date),
            priority: root.normalizePriority(item.priority),
            status: root.normalizeStatus(item.status)
        }
    }

    function normalizeItems(value) {
        if (!Array.isArray(value))
            return []

        const result = []

        for (let i = 0; i < value.length; i++) {
            const item = root.normalizeItem(value[i], i)

            if (item.title.length > 0)
                result.push(item)
        }

        return result
    }

    function readFileText() {
        try {
            if (typeof dashboardFile.text === "function")
                return dashboardFile.text()

            if (dashboardFile.text !== undefined && dashboardFile.text !== null)
                return String(dashboardFile.text)

            return ""
        } catch (error) {
            root.lastError = "text read failed: " + error
            return ""
        }
    }

    function parseDashboard(rawText) {
        const raw = root.clean(rawText)

        if (raw.length === 0)
            return []

        const parsed = JSON.parse(raw)

        if (!parsed || !parsed.sections)
            return []

        if (!Array.isArray(parsed.sections.items))
            return []

        return root.normalizeItems(parsed.sections.items)
    }

    function applyFileContents() {
        try {
            const raw = root.readFileText()
            root.items = root.parseDashboard(raw)
            root.loaded = true
            root.lastError = ""
        } catch (error) {
            console.log("DashboardData: failed to parse dashboard.json:", error)
            root.items = []
            root.loaded = false
            root.lastError = String(error)
        }
    }

    function load() {
        try {
            dashboardFile.reload()
        } catch (error) {
            console.log("DashboardData: reload failed:", error)
            root.items = []
            root.loaded = false
            root.lastError = String(error)
        }
    }

    FileView {
        id: dashboardFile

        path: root.dashboardPath
        watchChanges: true

        onLoaded: {
            root.applyFileContents()
        }

        onLoadFailed: function(error) {
            console.log("DashboardData: failed to load dashboard.json:", error)
            root.items = []
            root.loaded = false
            root.lastError = String(error)
        }
    }

    Component.onCompleted: {
        root.load()
    }
}