import QtQuick
import Quickshell
import Quickshell.Io

import "../../services"

Item {
    id: root

    signal addFinished()
    signal removeFinished()

    function addItem(category, type, title, course, date, priority, status) {
        addProcess.command = [
            Quickshell.env("HOME") + "/.config/hypr/scripts/dashboard-add.lua",
            category,
            type,
            title,
            course,
            date,
            priority,
            status
        ]

        addProcess.running = true
    }

    function removeItem(itemId) {
        removeProcess.command = [
            Quickshell.env("HOME") + "/.config/hypr/scripts/dashboard-remove.lua",
            itemId
        ]

        removeProcess.running = true
    }

    Process {
        id: addProcess

        command: []
        running: false

        onExited: {
            DashboardData.load()
            root.addFinished()
        }
    }

    Process {
        id: removeProcess

        command: []
        running: false

        onExited: {
            DashboardData.load()
            root.removeFinished()
        }
    }
}