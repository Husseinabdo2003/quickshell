pragma Singleton
import QtQuick

QtObject {
    readonly property color bg: "#0e2020"
    readonly property color fg: "#c2c7c7"
    readonly property color surface: "#0e2020"
    readonly property color border: "#5E6469"
    readonly property color accent: "#8C8375"
    readonly property color urgent: "#39454E"

    readonly property color transparentBg: "transparent"
    readonly property color surfaceAlpha: Qt.rgba(0.054902, 0.125490, 0.125490, 0.75)
    readonly property color accentAlpha: Qt.rgba(0.549020, 0.513725, 0.458824, 0.55)
    readonly property color urgentAlpha: Qt.rgba(0.223529, 0.270588, 0.305882, 0.75)
    readonly property color fgMuted: Qt.rgba(0.760784, 0.780392, 0.780392, 0.65)
}
