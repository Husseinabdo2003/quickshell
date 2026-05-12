import QtQuick

import "../../theme"
import "../../widgets"

Row {
    id: root

    spacing: Theme.spacing

    Clock {}

    MediaPrev {}

    Media {}

    MediaNext {}
}