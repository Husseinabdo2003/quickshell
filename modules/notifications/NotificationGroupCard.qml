import QtQuick

import "../../components"
import "../../theme"

Item {
    id: root

    property var groupData: null
    property bool expanded: false

    signal toggleRequested()
    signal clearRequested()
    signal dismissRequested(var notification)

    readonly property var items: groupData && groupData.items ? groupData.items : []
    readonly property var latest: groupData && groupData.latest ? groupData.latest : null
    readonly property int count: items.length
    readonly property bool stacked: count > 1
    readonly property var expandedItems: root.safeExpandedItems()

    width: parent ? parent.width : 320

    height: !stacked
        ? singleCard.height
        : expanded
            ? expandedColumn.implicitHeight
            : 104

    Behavior on height {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    function safeExpandedItems() {
        const result = []

        if (!root.items)
            return result

        const latestId = root.latest && root.latest.id
            ? String(root.latest.id)
            : ""

        for (let i = 0; i < root.items.length; i++) {
            const item = root.items[i]

            if (!item)
                continue

            const id = item.id ? String(item.id) : ""

            if (latestId.length > 0 && id === latestId)
                continue

            result.push(item)
        }

        return result
    }

    NotificationCard {
        id: singleCard

        visible: !root.stacked

        width: parent.width

        notification: root.latest

        compact: false
        expanded: true

        showAppIcon: true
        showAppName: true
        showCloseButton: true
        showTime: true

        notificationRadius: 24

        onCloseRequested: function(notification) {
            root.dismissRequested(notification)
        }
    }

    Item {
        id: collapsedStack

        visible: root.stacked && !root.expanded

        width: parent.width
        height: 104

        Card {
            width: Math.max(0, parent.width - 24)
            height: 76

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 18

            cardRadius: 22
            cardColor: WalTheme.surfaceAlpha
            cardBorderColor: WalTheme.border
            cardBorderWidth: 1

            opacity: root.count >= 3 ? 0.55 : 0.0
        }

        Card {
            width: Math.max(0, parent.width - 12)
            height: 82

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 9

            cardRadius: 24
            cardColor: WalTheme.surfaceAlpha
            cardBorderColor: WalTheme.border
            cardBorderWidth: 1

            opacity: root.count >= 2 ? 0.75 : 0.0
        }

        NotificationCard {
            id: collapsedCard

            width: parent.width
            height: 88

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            notification: root.latest

            compact: true
            expanded: false

            showAppIcon: true
            showAppName: true
            showCloseButton: false
            showTime: true

            notificationRadius: 26
        }

        Badge {
            visible: root.count > 1

            anchors.right: collapsedCard.right
            anchors.top: collapsedCard.top
            anchors.rightMargin: 12
            anchors.topMargin: 12

            text: root.count + ""
            badgeHeight: 24
            badgeRadius: 12
            fontSize: 11
            horizontalPadding: 10
            accent: true
            muted: false
        }

        MouseArea {
            anchors.fill: collapsedCard
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.toggleRequested()
            }
        }

        IconButton {
            visible: root.count > 0

            anchors.right: collapsedCard.right
            anchors.bottom: collapsedCard.bottom
            anchors.rightMargin: 10
            anchors.bottomMargin: 10

            buttonSize: 24
            buttonRadius: 12
            iconSize: 10

            icon: ""
            muted: true

            onClicked: {
                root.clearRequested()
            }
        }
    }

    Column {
        id: expandedColumn

        visible: root.stacked && root.expanded

        width: parent.width
        spacing: 8

        opacity: root.expanded ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        NotificationCard {
            width: parent.width

            notification: root.latest

            compact: true
            expanded: false

            showAppIcon: true
            showAppName: true
            showCloseButton: false
            showTime: true

            notificationRadius: 26

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    root.toggleRequested()
                }
            }

            IconButton {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 10
                anchors.bottomMargin: 10

                buttonSize: 24
                buttonRadius: 12
                iconSize: 10

                icon: ""
                muted: true

                onClicked: {
                    root.toggleRequested()
                }
            }

            IconButton {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 10
                anchors.topMargin: 10

                buttonSize: 24
                buttonRadius: 12
                iconSize: 10

                icon: ""
                muted: true

                onClicked: {
                    root.clearRequested()
                }
            }
        }

        Repeater {
            model: root.expandedItems

            NotificationCard {
                required property var modelData

                width: expandedColumn.width

                notification: modelData

                compact: false
                expanded: true

                showAppIcon: false
                showAppName: false
                showCloseButton: true
                showTime: true

                notificationRadius: 24

                onCloseRequested: function(notification) {
                    root.dismissRequested(notification)
                }
            }
        }
    }
}
