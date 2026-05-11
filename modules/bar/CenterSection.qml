import QtQuick

import "../../theme"
import "../../widgets"

Row {
    anchors.centerIn: parent

    spacing: Theme.spacing

    Clock {}
    MediaPrev {}
    Media {}
    MediaNext {}
}