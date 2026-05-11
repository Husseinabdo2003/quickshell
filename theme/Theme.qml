pragma Singleton
import QtQuick

QtObject {
    readonly property color bg: WalTheme.transparentBg

    readonly property color pillBg: WalTheme.surfaceAlpha
    readonly property color border: WalTheme.border
    readonly property color accent: WalTheme.accentAlpha
    readonly property color urgent: WalTheme.urgentAlpha

    readonly property color text: WalTheme.fg
    readonly property color textStrong: WalTheme.fg
    readonly property color textMuted: WalTheme.fgMuted

    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    readonly property int barHeight: 42
    readonly property int pillHeight: 28
    readonly property int radius: 999

    readonly property int fontSize: 12
    readonly property int margin: 8
    readonly property int spacing: 7
}