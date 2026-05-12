pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: root

    signal popupAdded(var notification)

    property var latestNotification: null

    property var appGroups: []
    property string expandedGroupKey: ""

    readonly property var notifications: server.trackedNotifications.values

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
            notification.tracked = true

            root.latestNotification = notification
            root.popupAdded(notification)
            root.rebuildGroups()
        }
    }

    function cleanString(value) {
        if (value === null || value === undefined)
            return ""

        return String(value).trim()
    }

    function groupKey(notification) {
        if (!notification)
            return "system"

        const desktopEntry = root.cleanString(notification.desktopEntry)

        if (desktopEntry.length > 0)
            return desktopEntry.toLowerCase()

        const appName = root.cleanString(notification.appName)

        if (appName.length > 0)
            return appName.toLowerCase()

        return "system"
    }

    function groupName(notification) {
        if (!notification)
            return "System"

        const appName = root.cleanString(notification.appName)

        if (appName.length > 0)
            return appName

        const desktopEntry = root.cleanString(notification.desktopEntry)

        if (desktopEntry.length > 0)
            return desktopEntry

        return "System"
    }

    function desktopIconFor(notification) {
        if (!notification)
            return ""

        const desktopEntry = root.cleanString(notification.desktopEntry)

        if (desktopEntry.length === 0)
            return ""

        let entry = DesktopEntries.byId(desktopEntry)

        if (entry === null || entry === undefined)
            entry = DesktopEntries.byId(desktopEntry + ".desktop")

        if (entry === null || entry === undefined)
            return ""

        return root.cleanString(entry.icon)
    }

    function fallbackIconCandidatesFor(notification) {
        const app = root.groupName(notification).toLowerCase()
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

        if (app.includes("steam")) {
            candidates.push("steam")
        }

        if (app.includes("github")) {
            candidates.push("github")
            candidates.push("github-desktop")
        }

        if (app.includes("kitty")) {
            candidates.push("kitty")
        }

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
        const appName = root.groupName(notification)

        if (appName.length > 0)
            return appName[0].toUpperCase()

        return "N"
    }

    function rebuildGroups() {
        const map = {}

        for (let i = root.notifications.length - 1; i >= 0; i--) {
            const notification = root.notifications[i]
            const key = root.groupKey(notification)

            if (!map[key]) {
                map[key] = {
                    key: key,
                    name: root.groupName(notification),
                    latest: notification,
                    items: []
                }
            }

            map[key].items.push(notification)
        }

        root.appGroups = Object.keys(map).map(function(key) {
            return map[key]
        })
    }

    function toggleGroup(key) {
        root.expandedGroupKey = root.expandedGroupKey === key ? "" : key
    }

    function dismiss(notification) {
        if (notification !== null && notification !== undefined) {
            notification.dismiss()
            root.rebuildGroups()
        }
    }

    function clearGroup(key) {
        const group = root.appGroups.find(function(item) {
            return item.key === key
        })

        if (!group)
            return

        for (let i = group.items.length - 1; i >= 0; i--)
            group.items[i].dismiss()

        if (root.expandedGroupKey === key)
            root.expandedGroupKey = ""

        root.rebuildGroups()
    }

    function clearAll() {
        for (let i = root.notifications.length - 1; i >= 0; i--)
            root.notifications[i].dismiss()

        root.latestNotification = null
        root.expandedGroupKey = ""
        root.rebuildGroups()
    }

    Component.onCompleted: {
        root.rebuildGroups()
    }
}