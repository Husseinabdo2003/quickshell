pragma Singleton

import QtQuick

QtObject {
    id: root

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string monoFontFamily: "JetBrainsMono Nerd Font"
    readonly property string iconFontFamily: "JetBrainsMono Nerd Font"

    readonly property int barHeight: 42
    readonly property int pillHeight: 30

    readonly property int margin: 14
    readonly property int spacing: 8
    readonly property int smallSpacing: 5
    readonly property int largeSpacing: 14

    readonly property int radius: 16
    readonly property int smallRadius: 10
    readonly property int largeRadius: 24
    readonly property int popupRadius: 30

    readonly property int fontSize: 12
    readonly property int smallFontSize: 10
    readonly property int mediumFontSize: 13
    readonly property int titleFontSize: 15
    readonly property int headingFontSize: 18

    readonly property color bg: WalTheme.transparentBg
    readonly property color fg: WalTheme.fg
    readonly property color fgMuted: WalTheme.fgMuted

    readonly property color surface: WalTheme.surface
    readonly property color surfaceAlpha: WalTheme.surfaceAlpha

    readonly property color border: WalTheme.border

    readonly property color accent: WalTheme.accent
    readonly property color accentAlpha: WalTheme.accentAlpha

    readonly property color urgent: WalTheme.urgent
    readonly property color urgentAlpha: WalTheme.urgentAlpha

    readonly property color pillBg: WalTheme.surfaceAlpha

    readonly property color transparent: "transparent"

    // Static fallback danger colors.
    // Use these for destructive actions if pywal color1 is too calm.
    readonly property color danger: "#ff4b78"
    readonly property color dangerAlpha: Qt.rgba(1.0, 0.294, 0.471, 0.22)

    readonly property color overlay: Qt.rgba(0, 0, 0, 0.48)
    readonly property color overlayLight: Qt.rgba(0, 0, 0, 0.28)

    readonly property int borderWidth: 1
    readonly property int activeBorderWidth: 2

    readonly property int iconSize: 16
    readonly property int smallIconSize: 12
    readonly property int largeIconSize: 22

    readonly property int buttonSize: 30
    readonly property int iconButtonSize: 28

    function alpha(colorValue, amount) {
        return Qt.rgba(
            colorValue.r,
            colorValue.g,
            colorValue.b,
            amount
        )
    }

    function withAlpha(colorValue, amount) {
        return root.alpha(colorValue, amount)
    }
}