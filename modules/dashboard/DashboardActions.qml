import QtQuick
import Quickshell
import Quickshell.Io

import "../../services"

Item {
    id: root

    readonly property bool busy: addProcess.running || removeProcess.running

    property string luaBinary: "lua"
    property string addScript: Quickshell.env("HOME") + "/.config/hypr/scripts/dashboard-add.lua"
    property string removeScript: Quickshell.env("HOME") + "/.config/hypr/scripts/dashboard-remove.lua"

    signal addFinished()
    signal removeFinished()
    signal addFailed(int exitCode)
    signal removeFailed(int exitCode)

    function clean(value) {
        try {
            return String(value || "").trim()
        } catch (error) {
            return ""
        }
    }

    function addItem(category, type, title, course, date, priority, status) {
        if (root.busy)
            return

        const cleanTitle = root.clean(title)

        if (cleanTitle.length === 0)
            return

        addProcess.command = [
            root.luaBinary,
            root.addScript,
            root.clean(category),
            root.clean(type),
            cleanTitle,
            root.clean(course),
            root.clean(date),
            root.clean(priority),
            root.clean(status)
        ]

        addProcess.running = true
    }

    function removeItem(itemId) {
        if (root.busy)
            return

        const cleanId = root.clean(itemId)

        if (cleanId.length === 0)
            return

        removeProcess.command = [
            root.luaBinary,
            root.removeScript,
            cleanId
        ]

        removeProcess.running = true
    }

    Process {
        id: addProcess

        command: []
        running: false

        stdout: StdioCollector {}
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0)
                    console.log("Dashboard add stderr:", this.text.trim())
            }
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                DashboardData.load()
                root.addFinished()
                return
            }

            root.addFailed(exitCode)
        }
    }

    Process {
        id: removeProcess

        command: []
        running: false

        stdout: StdioCollector {}
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0)
                    console.log("Dashboard remove stderr:", this.text.trim())
            }
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                DashboardData.load()
                root.removeFinished()
                return
            }

            root.removeFailed(exitCode)
        }
    }
}