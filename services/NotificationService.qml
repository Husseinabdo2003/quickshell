pragma Singleton
import QtQuick
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
        actionsSupported: true
        persistenceSupported: true
        keepOnReload: false

        onNotification: function(notification) {
            notification.tracked = true

            root.latestNotification = notification
            root.popupAdded(notification)
            root.rebuildGroups()
        }
    }

    function groupKey(notification) {
        if (notification.desktopEntry && notification.desktopEntry.length > 0)
            return notification.desktopEntry

        if (notification.appName && notification.appName.length > 0)
            return notification.appName

        return "system"
    }

    function groupName(notification) {
        if (notification.appName && notification.appName.length > 0)
            return notification.appName

        return "System"
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

        for (let i = group.items.length - 1; i >= 0; i--) {
            group.items[i].dismiss()
        }

        if (root.expandedGroupKey === key)
            root.expandedGroupKey = ""

        root.rebuildGroups()
    }

    function clearAll() {
        for (let i = root.notifications.length - 1; i >= 0; i--) {
            root.notifications[i].dismiss()
        }

        root.latestNotification = null
        root.expandedGroupKey = ""
        root.rebuildGroups()
    }

    Component.onCompleted: {
        root.rebuildGroups()
    }
}