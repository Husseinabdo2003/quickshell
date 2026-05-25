pragma Singleton
import QtQuick

QtObject {
    property int minimumNormalWorkspaces: 5

    property var pinnedSpecialWorkspaces: [
        "special:1",
        "special:music",
        "special:2",
        "special:3",
        "special:4"
    ]

    property var specialWorkspaceLabels: ({
        "special:1": "",
        "special:music": "music",
        "special:2": "",
        "special:3": "",
        "special:4": ""
    })

    function specialWorkspaceLabel(name) {
        return specialWorkspaceLabels[name] !== undefined
            ? specialWorkspaceLabels[name]
            : String(name).replace("special:", "")
    }

    function isEmptySpecialSlot(name) {
        return String(name).startsWith("special:")
    }

    function shouldShowSpecialWorkspace(name, windowCount) {
        return !isEmptySpecialSlot(name) || windowCount > 0
    }
}
