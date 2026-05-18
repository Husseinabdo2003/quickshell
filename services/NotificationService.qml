pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    signal popupAdded(var notificationSnapshot)

    property var latestNotification: null

    property var appGroups: []
    property string expandedGroupKey: ""

    property int nextNotificationId: 1
    property var liveTargets: ({})
    property var dismissingIds: ({})

    readonly property var notifications: server.trackedNotifications.values
    readonly property int notificationCount: notifications.length

    onNotificationCountChanged: {
        root.rebuildGroups()
    }

    NotificationServer {
        id: server

        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        bodyImagesSupported: true
        actionsSupported: true
        actionIconsSupported: true
        persistenceSupported: true
        keepOnReload: false

        onNotification: function(notification) {
            if (!notification)
                return

            try {
                notification.tracked = true
            } catch (error) {
                console.log("Notification tracking failed:", error)
            }

            const id = root.notificationId(notification)
            const snapshot = root.makeSnapshot(notification, id)

            if (!snapshot)
                return

            root.latestNotification = snapshot
            root.popupAdded(snapshot)
            root.rebuildGroups()
        }
    }

    function cleanString(value) {
        try {
            if (value === null || value === undefined)
                return ""

            return String(value).trim()
        } catch (error) {
            return ""
        }
    }

    function safeNotificationValue(notification, key) {
        if (!notification)
            return ""

        try {
            const value = notification[key]

            if (value === null || value === undefined)
                return ""

            return root.cleanString(value)
        } catch (error) {
            return ""
        }
    }

    function notificationId(notification) {
        if (!notification)
            return ""

        try {
            if (notification.__qsNotificationId !== undefined && notification.__qsNotificationId !== null)
                return String(notification.__qsNotificationId)
        } catch (error) {
        }

        const id = String(root.nextNotificationId)
        root.nextNotificationId += 1

        try {
            notification.__qsNotificationId = id
        } catch (error) {
        }

        return id
    }

    function groupKey(notification) {
        if (!notification)
            return "system"

        const desktopEntry = root.safeNotificationValue(notification, "desktopEntry")

        if (desktopEntry.length > 0)
            return desktopEntry.toLowerCase()

        const appName = root.safeNotificationValue(notification, "appName")

        if (appName.length > 0)
            return appName.toLowerCase()

        return "system"
    }

    function groupName(notification) {
        if (!notification)
            return "System"

        const appName = root.safeNotificationValue(notification, "appName")

        if (appName.length > 0)
            return appName

        const desktopEntry = root.safeNotificationValue(notification, "desktopEntry")

        if (desktopEntry.length > 0)
            return desktopEntry

        return "System"
    }

    function makeSnapshot(notification, id) {
        if (!notification)
            return null

        const cleanId = String(id || root.notificationId(notification))

        if (cleanId.length === 0)
            return null

        return {
            id: cleanId,
            appName: root.groupName(notification),
            groupKey: root.groupKey(notification),
            desktopEntry: root.safeNotificationValue(notification, "desktopEntry"),
            appIcon: root.safeNotificationValue(notification, "appIcon"),
            image: root.safeNotificationValue(notification, "image"),
            summary: root.safeNotificationValue(notification, "summary"),
            body: root.safeNotificationValue(notification, "body"),
            time: root.safeNotificationValue(notification, "time"),
            timestamp: root.safeNotificationValue(notification, "timestamp"),
            date: root.safeNotificationValue(notification, "date")
        }
    }

    function isDismissing(id) {
        const cleanId = String(id || "")

        if (cleanId.length === 0)
            return false

        try {
            return root.dismissingIds[cleanId] === true
        } catch (error) {
            return false
        }
    }

    function markDismissing(id) {
        const cleanId = String(id || "")

        if (cleanId.length === 0)
            return

        const next = Object.assign({}, root.dismissingIds)
        next[cleanId] = true
        root.dismissingIds = next
    }

    function unmarkDismissing(id) {
        const cleanId = String(id || "")

        if (cleanId.length === 0)
            return

        const next = Object.assign({}, root.dismissingIds)
        delete next[cleanId]
        root.dismissingIds = next
    }

    function removeIdsFromUi(ids) {
        const removeMap = {}

        for (let i = 0; i < ids.length; i++)
            removeMap[String(ids[i])] = true

        const nextGroups = []

        for (let g = 0; g < root.appGroups.length; g++) {
            const group = root.appGroups[g]

            if (!group || !group.items)
                continue

            const nextItems = group.items.filter(function(item) {
                return item && !removeMap[String(item.id)]
            })

            if (nextItems.length === 0)
                continue

            nextGroups.push({
                key: group.key,
                name: group.name,
                latest: nextItems[0],
                items: nextItems
            })
        }

        root.appGroups = nextGroups

        const expandedStillExists = root.appGroups.some(function(group) {
            return group.key === root.expandedGroupKey
        })

        if (!expandedStillExists)
            root.expandedGroupKey = ""
    }

    function desktopIconFor(notification) {
        if (!notification)
            return ""

        const desktopEntry = root.cleanString(notification.desktopEntry)

        if (desktopEntry.length === 0)
            return ""

        try {
            let entry = DesktopEntries.byId(desktopEntry)

            if (entry === null || entry === undefined)
                entry = DesktopEntries.byId(desktopEntry + ".desktop")

            if (entry === null || entry === undefined)
                return ""

            return root.cleanString(entry.icon)
        } catch (error) {
            return ""
        }
    }

    function fallbackIconCandidatesFor(notification) {
        const app = root.cleanString(notification && notification.appName ? notification.appName : "System").toLowerCase()
        const candidates = []

        if (app.includes("spotify")) {
            candidates.push("spotify")
            candidates.push("spotify-client")
            candidates.push("com.spotify.Client")
        }

        if (
            app.includes("visual studio code")
            || app.includes("vscode")
            || app === "code"
            || app.includes("vs code")
        ) {
            candidates.push("visual-studio-code")
            candidates.push("code")
            candidates.push("com.visualstudio.code")
            candidates.push("vscode")
        }

        if (app.includes("discord")) {
            candidates.push("discord")
            candidates.push("com.discordapp.Discord")
        }

        if (app.includes("telegram")) {
            candidates.push("telegram")
            candidates.push("telegram-desktop")
            candidates.push("org.telegram.desktop")
        }

        if (app.includes("brave")) {
            candidates.push("brave-browser")
            candidates.push("brave")
        }

        if (app.includes("chrome")) {
            candidates.push("google-chrome")
            candidates.push("chrome")
        }

        if (app.includes("firefox")) {
            candidates.push("firefox")
            candidates.push("firefox-esr")
        }

        if (app.includes("steam"))
            candidates.push("steam")

        if (app.includes("github")) {
            candidates.push("github")
            candidates.push("github-desktop")
        }

        if (app.includes("kitty"))
            candidates.push("kitty")

        if (app.includes("terminal")) {
            candidates.push("utilities-terminal")
            candidates.push("terminal")
        }

        if (app.includes("nautilus") || app.includes("files")) {
            candidates.push("org.gnome.Nautilus")
            candidates.push("system-file-manager")
            candidates.push("folder")
        }

        return candidates
    }

    function iconCandidatesFor(notification) {
        const candidates = []

        if (!notification)
            return candidates

        const directIcon = root.cleanString(notification.appIcon)

        if (directIcon.length > 0)
            candidates.push(directIcon)

        const desktopIcon = root.desktopIconFor(notification)

        if (desktopIcon.length > 0)
            candidates.push(desktopIcon)

        const desktopEntry = root.cleanString(notification.desktopEntry)

        if (desktopEntry.length > 0) {
            candidates.push(desktopEntry)
            candidates.push(desktopEntry.replace(".desktop", ""))
        }

        const fallbackCandidates = root.fallbackIconCandidatesFor(notification)

        for (let i = 0; i < fallbackCandidates.length; i++)
            candidates.push(fallbackCandidates[i])

        const unique = []

        for (let j = 0; j < candidates.length; j++) {
            const item = root.cleanString(candidates[j])

            if (item.length > 0 && !unique.includes(item))
                unique.push(item)
        }

        return unique
    }

    function imageFor(notification) {
        if (!notification)
            return ""

        return root.cleanString(notification.image)
    }

    function appInitialFor(notification) {
        if (!notification)
            return "N"

        const appName = root.cleanString(notification.appName)

        if (appName.length > 0)
            return appName[0].toUpperCase()

        return "N"
    }

    function rebuildGroups() {
        const map = {}
        const targets = {}

        try {
            for (let i = root.notifications.length - 1; i >= 0; i--) {
                const notification = root.notifications[i]

                if (!notification)
                    continue

                const id = root.notificationId(notification)

                if (root.isDismissing(id))
                    continue

                const snapshot = root.makeSnapshot(notification, id)

                if (!snapshot)
                    continue

                targets[id] = notification

                const key = snapshot.groupKey

                if (!map[key]) {
                    map[key] = {
                        key: key,
                        name: snapshot.appName,
                        latest: snapshot,
                        items: []
                    }
                }

                map[key].items.push(snapshot)
            }
        } catch (error) {
            console.log("Notification group rebuild failed:", error)
        }

        root.liveTargets = targets

        root.appGroups = Object.keys(map).map(function(key) {
            return map[key]
        })

        const expandedStillExists = root.appGroups.some(function(group) {
            return group.key === root.expandedGroupKey
        })

        if (!expandedStillExists)
            root.expandedGroupKey = ""
    }

    function toggleGroup(key) {
        root.expandedGroupKey = root.expandedGroupKey === key ? "" : key
    }

    function dismiss(notificationSnapshot) {
        if (!notificationSnapshot)
            return

        const id = String(notificationSnapshot.id || "")

        if (id.length === 0)
            return

        let target = null

        try {
            target = root.liveTargets[id]
        } catch (error) {
            target = null
        }

        root.markDismissing(id)
        root.removeIdsFromUi([id])

        const nextTargets = Object.assign({}, root.liveTargets)
        delete nextTargets[id]
        root.liveTargets = nextTargets

        if (!target)
            return

        Qt.callLater(function() {
            try {
                target.dismiss()
            } catch (error) {
                console.log("Notification dismiss failed:", error)
            }

            Qt.callLater(function() {
                root.unmarkDismissing(id)
                root.rebuildGroups()
            })
        })
    }

    function clearGroup(key) {
        const group = root.appGroups.find(function(item) {
            return item.key === key
        })

        if (!group || !group.items)
            return

        const ids = []
        const targets = []

        for (let i = 0; i < group.items.length; i++) {
            const item = group.items[i]

            if (!item || !item.id)
                continue

            const id = String(item.id)
            ids.push(id)
            root.markDismissing(id)

            try {
                if (root.liveTargets[id])
                    targets.push({
                        id: id,
                        target: root.liveTargets[id]
                    })
            } catch (error) {
            }
        }

        if (root.expandedGroupKey === key)
            root.expandedGroupKey = ""

        root.removeIdsFromUi(ids)

        const nextTargets = Object.assign({}, root.liveTargets)

        for (let j = 0; j < ids.length; j++)
            delete nextTargets[ids[j]]

        root.liveTargets = nextTargets

        Qt.callLater(function() {
            for (let k = targets.length - 1; k >= 0; k--) {
                try {
                    if (targets[k].target)
                        targets[k].target.dismiss()
                } catch (error) {
                    console.log("Notification group dismiss failed:", error)
                }

                root.unmarkDismissing(targets[k].id)
            }

            Qt.callLater(function() {
                root.rebuildGroups()
            })
        })
    }

    function clearAll() {
        const ids = []
        const targets = []

        try {
            for (let i = root.notifications.length - 1; i >= 0; i--) {
                const notification = root.notifications[i]

                if (!notification)
                    continue

                const id = root.notificationId(notification)

                ids.push(id)
                root.markDismissing(id)

                targets.push({
                    id: id,
                    target: notification
                })
            }
        } catch (error) {
            console.log("Notification collect all failed:", error)
        }

        root.latestNotification = null
        root.expandedGroupKey = ""
        root.appGroups = []
        root.liveTargets = ({})

        Qt.callLater(function() {
            for (let i = targets.length - 1; i >= 0; i--) {
                try {
                    if (targets[i].target)
                        targets[i].target.dismiss()
                } catch (error) {
                    console.log("Notification clear all failed:", error)
                }

                root.unmarkDismissing(targets[i].id)
            }

            Qt.callLater(function() {
                root.rebuildGroups()
            })
        })
    }

    Component.onCompleted: {
        root.rebuildGroups()
    }
}
