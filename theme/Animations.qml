pragma Singleton

import QtQuick

QtObject {
    readonly property int instant: 80
    readonly property int fast: 120
    readonly property int normal: 180
    readonly property int slow: 260

    readonly property int popupFade: 140
    readonly property int popupSlide: 220
    readonly property int layoutMove: 180

    readonly property int osdShow: 140
    readonly property int osdHide: 180

    readonly property int hover: 120
    readonly property int press: 90

    readonly property int dashboardOpen: 240
    readonly property int dashboardClose: 220

    readonly property int overviewOpen: 210
    readonly property int overviewClose: 160

    readonly property int wallpaperSlide: 260

    readonly property int notificationSlide: 220
    readonly property int notificationFade: 140

    readonly property var easeOutCubic: Easing.OutCubic
    readonly property var easeInOutCubic: Easing.InOutCubic
    readonly property var easeOutQuint: Easing.OutQuint
}