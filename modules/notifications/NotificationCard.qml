import QtQuick
import Quickshell
import Quickshell.Widgets

import "../../components"
import "../../theme"
import "../../services"

Card {
    id: root

    property var notification: null

    property bool compact: false
    property bool expanded: false
    property bool showAppIcon: true
    property bool showAppName: true
    property bool showCloseButton: true
    property bool showTime: true

    property int notificationRadius: compact ? 24 : 24

    readonly property string resolvedIconSource: root.resolveIconSource()
    readonly property bool hasResolvedIcon: resolvedIconSource.length > 0

    signal closeRequested(var notification)

    function notificationAppName() {
        if (!root.notification)
            return "Notification"

        if (root.notification.appName && String(root.notification.appName).length > 0)
            return String(root.notification.appName)

        return "Notification"
    }

    function notificationSummary() {
        if (!root.notification)
            return ""

        if (root.notification.summary && String(root.notification.summary).length > 0)
            return String(root.notification.summary)

        return ""
    }

    function notificationBody() {
        if (!root.notification)
            return ""

        if (root.notification.body && String(root.notification.body).length > 0)
            return String(root.notification.body)

        return ""
    }

    function formattedTime() {
        if (!root.notification)
            return ""

        let value = null

        if (root.notification.time !== undefined && root.notification.time !== null)
            value = root.notification.time
        else if (root.notification.timestamp !== undefined && root.notification.timestamp !== null)
            value = root.notification.timestamp
        else if (root.notification.date !== undefined && root.notification.date !== null)
            value = root.notification.date

        if (value === null)
            return ""

        const d = new Date(value)

        if (isNaN(d.getTime()))
            return ""

        return Qt.formatTime(d, "h:mm AP")
    }

    function isDirectImageSource(source) {
        if (!source || source.length === 0)
            return false

        return source.startsWith("/")
            || source.startsWith("file://")
            || source.startsWith("image://")
            || source.startsWith("qrc:/")
            || source.startsWith("http://")
            || source.startsWith("https://")
    }

    function directImageSource(source) {
        if (!source || source.length === 0)
            return ""

        if (source.startsWith("/"))
            return "file://" + source

        return source
    }

    function resolveIconSource() {
        if (!root.notification)
            return ""

        const candidates = NotificationService.iconCandidatesFor(root.notification)

        for (let i = 0; i < candidates.length; i++) {
            const candidate = String(candidates[i] || "").trim()

            if (candidate.length === 0)
                continue

            if (root.isDirectImageSource(candidate))
                return root.directImageSource(candidate)

            const resolved = Quickshell.iconPath(candidate, true)

            if (resolved && String(resolved).length > 0)
                return resolved
        }

        return ""
    }

    width: 320
    height: compact
        ? 88
        : Math.max(90, contentColumn.implicitHeight + 28)

    cardRadius: root.notificationRadius
    cardColor: Theme.pillBg
    cardBorderColor: WalTheme.border
    cardBorderWidth: 1

    Row {
        anchors.fill: parent
        anchors.margins: compact ? 12 : 14
        spacing: 10

        Rectangle {
            id: appIconBox

            visible: root.showAppIcon

            width: root.showAppIcon ? 38 : 0
            height: 38
            radius: 12

            anchors.verticalCenter: parent.verticalCenter

            color: WalTheme.accentAlpha

            border.width: 1
            border.color: WalTheme.accent

            clip: true

            IconImage {
                id: appIcon

                visible: root.hasResolvedIcon

                anchors.centerIn: parent

                width: 27
                height: 27

                source: root.resolvedIconSource
                asynchronous: true
                mipmap: true
            }

            Text {
                visible: !root.hasResolvedIcon

                anchors.centerIn: parent

                text: NotificationService.appInitialFor(root.notification)

                color: WalTheme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.bold: true
            }
        }

        Column {
            id: contentColumn

            width: parent.width
                - (root.showAppIcon ? appIconBox.width + parent.spacing : 0)
                - (rightColumn.visible ? rightColumn.width + parent.spacing : 0)

            anchors.verticalCenter: parent.verticalCenter
            spacing: compact ? 2 : 5

            MetaText {
                visible: root.showAppName

                width: parent.width

                text: root.notificationAppName()
                boldText: true
                accentText: true
                font.pixelSize: 11
                opacity: 0.92
            }

            TitleText {
                width: parent.width

                text: root.notificationSummary().length > 0
                    ? root.notificationSummary()
                    : root.notificationBody()

                font.pixelSize: compact ? 12 : 13
            }

            MetaText {
                visible: root.notificationSummary().length > 0
                    && root.notificationBody().length > 0

                width: parent.width

                text: root.notificationBody()

                font.pixelSize: compact ? 11 : 12
                wrapMode: Text.WordWrap
                maximumLineCount: root.expanded ? 4 : 2
                opacity: 0.90
            }
        }

        Column {
            id: rightColumn

            visible: root.showTime || root.showCloseButton

            width: 54
            spacing: 8

            Item {
                width: parent.width
                height: root.showTime ? 18 : 0

                MetaText {
                    visible: root.showTime

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: root.formattedTime()
                    font.pixelSize: 11
                    opacity: 0.85
                }
            }

            Item {
                width: parent.width
                height: root.showCloseButton ? 24 : 0

                IconButton {
                    visible: root.showCloseButton

                    anchors.right: parent.right

                    buttonSize: 24
                    buttonRadius: 12
                    iconSize: 10

                    icon: ""
                    muted: true

                    onClicked: {
                        root.closeRequested(root.notification)
                    }
                }
            }
        }
    }
}