pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string dashboardPath: Quickshell.env("HOME") + "/.config/quickshell/data/dashboard.json"
    property var items: []

    function load() {
        dashboardFile.reload()
    }

    FileView {
        id: dashboardFile

        path: root.dashboardPath
        watchChanges: true

        onLoaded: {
            try {
                const parsed = JSON.parse(text())
                root.items = parsed.sections && parsed.sections.items
                    ? parsed.sections.items
                    : []
            } catch (e) {
                console.log("DashboardData: failed to parse dashboard.json:", e)
                root.items = []
            }
        }

        onLoadFailed: function(error) {
            console.log("DashboardData: failed to load dashboard.json:", error)
            root.items = []
        }
    }

    Component.onCompleted: {
        load()
    }
}