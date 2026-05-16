import QtQuick
import Quickshell
import Quickshell.Widgets

import "../../components"
import "../../theme"

Card {
    id: root

    property var app: null
    property bool selected: false

    readonly property string resolvedIcon: root.resolveIconSource()
    readonly property bool hasIcon: resolvedIcon.length > 0

    signal clicked(var app)

    width: parent ? parent.width : 520
    height: 56

    cardRadius: 18

    cardColor: root.selected
        ? WalTheme.accentAlpha
        : mouseArea.containsMouse
            ? Qt.rgba(WalTheme.fg.r, WalTheme.fg.g, WalTheme.fg.b, 0.055)
            : "transparent"

    cardBorderColor: root.selected
        ? WalTheme.accent
        : mouseArea.containsMouse
            ? WalTheme.border
            : "transparent"

    cardBorderWidth: root.selected || mouseArea.containsMouse ? 1 : 0

    Behavior on cardColor {
        ColorAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    Behavior on cardBorderColor {
        ColorAnimation {
            duration: Animations.fast
            easing.type: Easing.OutCubic
        }
    }

    function appName() {
        if (!root.app)
            return "Application"

        try {
            const name = String(root.app.name || "").trim()

            if (name.length > 0)
                return name
        } catch (error) {
            return "Application"
        }

        return "Application"
    }

    function appDescription() {
        if (!root.app)
            return ""

        try {
            const genericName = String(root.app.genericName || "").trim()
            const comment = String(root.app.comment || "").trim()

            if (genericName.length > 0)
                return genericName

            if (comment.length > 0)
                return comment
        } catch (error) {
            return ""
        }

        return ""
    }

    function appInitial() {
        const name = root.appName()

        if (name.length > 0)
            return name[0].toUpperCase()

        return "A"
    }

    function iconName() {
        if (!root.app)
            return ""

        try {
            return String(root.app.icon || "").trim()
        } catch (error) {
            return ""
        }
    }

    function isDirectImageSource(source) {
        if (!source || source.length === 0)
            return false

        return source.startsWith("/")
            || source.startsWith("file://")
            || source.startsWith("image://")
            || source.startsWith("qrc:/")
    }

    function directImageSource(source) {
        if (!source || source.length === 0)
            return ""

        if (source.startsWith("/"))
            return "file://" + source

        return source
    }

    function safeIconPath(icon) {
        if (!icon || String(icon).trim().length === 0)
            return ""

        try {
            const resolved = Quickshell.iconPath(String(icon), true)

            if (resolved && String(resolved).length > 0)
                return String(resolved)
        } catch (error) {
            return ""
        }

        return ""
    }

    function resolveIconSource() {
        const icon = root.iconName()

        if (icon.length > 0) {
            if (root.isDirectImageSource(icon))
                return root.directImageSource(icon)

            const resolved = root.safeIconPath(icon)

            if (resolved.length > 0)
                return resolved
        }

        const fallback = root.safeIconPath("application-x-executable")

        if (fallback.length > 0)
            return fallback

        return ""
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 12

        Card {
            width: 38
            height: 38

            anchors.verticalCenter: parent.verticalCenter

            cardRadius: 14
            cardColor: root.selected
                ? WalTheme.accentAlpha
                : WalTheme.surfaceAlpha

            cardBorderColor: root.selected
                ? WalTheme.accent
                : WalTheme.border

            clip: true

            IconImage {
                id: iconImage

                visible: root.hasIcon && status !== Image.Error

                anchors.centerIn: parent

                width: 25
                height: 25

                source: root.resolvedIcon
                asynchronous: true
                mipmap: true
            }

            Text {
                visible: !root.hasIcon || iconImage.status === Image.Error

                anchors.centerIn: parent

                text: root.appInitial()
                color: WalTheme.fg

                font.family: Theme.fontFamily
                font.pixelSize: 14
                font.bold: true
            }
        }

        Column {
            width: parent.width - 104
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            TitleText {
                width: parent.width

                text: root.appName()
                font.pixelSize: 13
                elide: Text.ElideRight
            }

            MetaText {
                width: parent.width

                text: root.appDescription()
                font.pixelSize: 11
                visible: text.length > 0
                elide: Text.ElideRight
            }
        }

        Badge {
            anchors.verticalCenter: parent.verticalCenter

            visible: root.selected

            text: "Enter"
            accent: true
            badgeHeight: 22
            badgeRadius: 11
            fontSize: 9
            horizontalPadding: 10
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.clicked(root.app)
        }
    }
}