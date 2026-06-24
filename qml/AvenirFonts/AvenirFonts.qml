pragma Singleton

import QtQml 2.0
import QtQuick 2.12

QtObject {

    readonly property AvenirFont regular: AvenirFont {
        source: "qrc:/fonts/avenir_next_lt_pro_regular.otf"
    }

    readonly property AvenirFont bold: AvenirFont {
        source: "qrc:/fonts/avenir_next_lt_pro_bold.otf"
    }

    readonly property AvenirFont italic: AvenirFont {
        source: "qrc:/fonts/avenir_next_lt_pro_it.otf"
    }
}
