import QtQuick

import "../theme"

Rectangle {
    id: root

    property real value: 0
    property real minimum: 0
    property real maximum: 100

    property int sliderWidth: 115
    property int sliderHeight: 5

    property color trackColor: WalTheme.border
    property color fillColor: WalTheme.accent

    readonly property real normalizedValue: {
        const range = maximum - minimum

        if (range <= 0)
            return 0

        return Math.max(0, Math.min(1, (value - minimum) / range))
    }

    width: sliderWidth
    height: sliderHeight

    radius: 999
    color: trackColor

    Rectangle {
        height: parent.height
        width: parent.width * root.normalizedValue

        radius: 999
        color: root.fillColor

        Behavior on width {
            NumberAnimation {
                duration: Animations.fast
                easing.type: Easing.OutCubic
            }
        }
    }
}