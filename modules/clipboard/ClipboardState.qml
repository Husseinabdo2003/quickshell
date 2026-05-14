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

    readonly property bool deleteMode: mode === "delete"

    function clean(value) {
        return String(value || "").toLowerCase().trim()
    }

    function reset() {
        root.query = ""
        root.selectedIndex = 0
        root.items = []
        root.filteredItems = []

        root.load()
    }

    function load() {
        if (!listProcess.running)
            listProcess.running = true
    }

    function filterItems() {
        const q = root.clean(root.query)

        if (q.length === 0) {
            root.filteredItems = root.items
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
        root.selectedIndex = Math.min(
            root.selectedIndex + 1,
            Math.max(0, root.filteredItems.length - 1)
        )
    }

    function moveUp() {
        root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
    }

    function selectedItem() {
        if (root.filteredItems.length === 0)
            return ""

        return String(root.filteredItems[root.selectedIndex] || "")
    }

    function shellQuote(value) {
        return "'" + String(value || "").replace(/'/g, "'\\''") + "'"
    }

    function runSelectedAction() {
        const value = root.selectedItem()

        if (value.length === 0)
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
        if (!value || String(value).length === 0)
            return

        root.selectedValue = String(value)

        if (!copyProcess.running)
            copyProcess.running = true
    }

    function deleteSelected() {
        const value = root.selectedItem()

        if (value.length === 0)
            return

        root.deleteItem(value)
    }

    function deleteItem(value) {
        if (!value || String(value).length === 0)
            return

        root.selectedValue = String(value)

        if (!deleteProcess.running)
            deleteProcess.running = true
    }

    function deleteAll() {
        if (!deleteAllProcess.running)
            deleteAllProcess.running = true
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
    }

    Process {
        id: copyProcess

        command: [
            "bash",
            "-lc",
            "printf '%s' " + root.shellQuote(root.selectedValue) + " | cliphist decode | wl-copy"
        ]

        stdout: StdioCollector {}

        onExited: function(exitCode) {
            if (exitCode === 0)
                ShellState.closeClipboard()
        }
    }

    Process {
        id: deleteProcess

        command: [
            "bash",
            "-lc",
            "printf '%s' " + root.shellQuote(root.selectedValue) + " | cliphist delete"
        ]

        stdout: StdioCollector {}

        onExited: function(exitCode) {
            if (exitCode === 0) {
                root.selectedValue = ""
                root.load()
            }
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
            if (exitCode === 0) {
                root.selectedValue = ""
                root.items = []
                root.filteredItems = []
                root.selectedIndex = 0
            }
        }
    }
}