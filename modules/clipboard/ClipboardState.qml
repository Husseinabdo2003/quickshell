import QtQuick
import Quickshell
import Quickshell.Io

import "../../services"

Item {
    id: root

    visible: false

    property string mode: "copy"
    property string query: ""
    property int selectedIndex: 0

    property var items: []
    property var filteredItems: []

    property string selectedValue: ""
    property string copyCommand: ""
    property string deleteCommand: ""

    property bool actionRunning: false
    property bool reloadPending: false
    property bool deleteAllConfirm: false

    readonly property bool deleteMode: mode === "delete"

    Timer {
        id: deleteAllConfirmTimer

        interval: 2200
        repeat: false

        onTriggered: {
            root.deleteAllConfirm = false
        }
    }

    function clean(value) {
        try {
            return String(value || "").toLowerCase().trim()
        } catch (error) {
            return ""
        }
    }

    function reset() {
        root.query = ""
        root.selectedIndex = 0
        root.items = []
        root.filteredItems = []
        root.selectedValue = ""
        root.reloadPending = false
        root.deleteAllConfirm = false
        deleteAllConfirmTimer.stop()

        root.load()
    }

    function load() {
        if (listProcess.running) {
            root.reloadPending = true
            return
        }

        listProcess.running = true
    }

    function filterItems() {
        const q = root.clean(root.query)

        if (q.length === 0) {
            root.filteredItems = root.items.slice()
        } else {
            root.filteredItems = root.items.filter(function(item) {
                return root.clean(item).indexOf(q) !== -1
            })
        }

        if (root.selectedIndex >= root.filteredItems.length)
            root.selectedIndex = Math.max(0, root.filteredItems.length - 1)

        if (root.selectedIndex < 0)
            root.selectedIndex = 0
    }

    function moveDown() {
        if (root.actionRunning)
            return

        root.selectedIndex = Math.min(
            root.selectedIndex + 1,
            Math.max(0, root.filteredItems.length - 1)
        )
    }

    function moveUp() {
        if (root.actionRunning)
            return

        root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
    }

    function selectedItem() {
        if (!root.filteredItems || root.filteredItems.length === 0)
            return ""

        const safeIndex = Math.max(
            0,
            Math.min(root.selectedIndex, root.filteredItems.length - 1)
        )

        return String(root.filteredItems[safeIndex] || "")
    }

    function shellQuote(value) {
        return "'" + String(value || "").replace(/'/g, "'\\''") + "'"
    }

    function runSelectedAction() {
        const value = root.selectedItem()
        root.runItemAction(value)
    }

    function runItemAction(value) {
        if (!value || String(value).length === 0)
            return

        if (root.deleteMode)
            root.deleteItem(value)
        else
            root.copyItem(value)
    }

    function copySelected() {
        const value = root.selectedItem()

        if (value.length === 0)
            return

        root.copyItem(value)
    }

    function copyItem(value) {
        if (root.actionRunning || copyProcess.running || deleteProcess.running || deleteAllProcess.running)
            return

        if (!value || String(value).length === 0)
            return

        root.actionRunning = true
        root.deleteAllConfirm = false
        deleteAllConfirmTimer.stop()

        root.selectedValue = String(value)
        root.copyCommand = "printf '%s' " + root.shellQuote(root.selectedValue) + " | cliphist decode | wl-copy"

        copyProcess.running = true
    }

    function deleteSelected() {
        const value = root.selectedItem()

        if (value.length === 0)
            return

        root.deleteItem(value)
    }

    function deleteItem(value) {
        if (root.actionRunning || copyProcess.running || deleteProcess.running || deleteAllProcess.running)
            return

        if (!value || String(value).length === 0)
            return

        root.actionRunning = true
        root.deleteAllConfirm = false
        deleteAllConfirmTimer.stop()

        root.selectedValue = String(value)
        root.deleteCommand = "printf '%s' " + root.shellQuote(root.selectedValue) + " | cliphist delete"

        deleteProcess.running = true
    }

    function requestDeleteAll() {
        if (root.actionRunning || deleteAllProcess.running)
            return

        if (!root.deleteAllConfirm) {
            root.deleteAllConfirm = true
            deleteAllConfirmTimer.restart()
            return
        }

        root.deleteAll()
    }

    function cancelDeleteAllConfirm() {
        root.deleteAllConfirm = false
        deleteAllConfirmTimer.stop()
    }

    function deleteAll() {
        if (root.actionRunning || copyProcess.running || deleteProcess.running || deleteAllProcess.running)
            return

        root.actionRunning = true
        root.deleteAllConfirm = false
        deleteAllConfirmTimer.stop()

        deleteAllProcess.running = true
    }

    function finishAction() {
        root.actionRunning = false
        root.selectedValue = ""
        root.copyCommand = ""
        root.deleteCommand = ""
    }

    Process {
        id: listProcess

        command: [
            "bash",
            "-lc",
            "cliphist list 2>/dev/null"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text
                    .split("\n")
                    .map(function(line) {
                        return line.trim()
                    })
                    .filter(function(line) {
                        return line.length > 0
                    })

                root.items = lines
                root.filterItems()
            }
        }

        onExited: function(exitCode) {
            if (root.reloadPending) {
                root.reloadPending = false
                root.load()
            }
        }
    }

    Process {
        id: copyProcess

        command: [
            "bash",
            "-lc",
            root.copyCommand
        ]

        stdout: StdioCollector {}

        onExited: function(exitCode) {
            root.finishAction()

            if (exitCode === 0)
                ShellState.closeClipboard()
        }
    }

    Process {
        id: deleteProcess

        command: [
            "bash",
            "-lc",
            root.deleteCommand
        ]

        stdout: StdioCollector {}

        onExited: function(exitCode) {
            root.finishAction()

            if (exitCode === 0)
                root.load()
        }
    }

    Process {
        id: deleteAllProcess

        command: [
            "bash",
            "-lc",
            "cliphist wipe"
        ]

        stdout: StdioCollector {}

        onExited: function(exitCode) {
            root.finishAction()

            if (exitCode === 0) {
                root.items = []
                root.filteredItems = []
                root.selectedIndex = 0
                root.query = ""
            }
        }
    }
}