pragma Singleton
import QtQuick

QtObject {
    readonly property color bg: "#130811"
    readonly property color fg: "#c4c1c3"
    readonly property color surface: "#130811"
    readonly property color border: "#6B6264"
    readonly property color accent: "#8C2C42"
    readonly property color urgent: "#3B3F46"

    readonly property color transparentBg: "transparent"
    readonly property color surfaceAlpha: Qt.rgba(0.074510, 0.031373, 0.066667, 0.75)
    readonly property color accentAlpha: Qt.rgba(0.549020, 0.172549, 0.258824, 0.55)
    readonly property color urgentAlpha: Qt.rgba(0.231373, 0.247059, 0.274510, 0.75)
    readonly property color fgMuted: Qt.rgba(0.768627, 0.756863, 0.764706, 0.65)
}
