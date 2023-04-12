pragma Singleton

import QtQml 2.0
import QtQuick 2.12

QtObject {


    /*
    readonly property FontLoader regularLoader: FontLoader {
        id: regularLoader
        source: "qrc:/fonts/avenir_next_lt_pro_regular.otf"
    }

    readonly property FontMetrics regularMetrics: FontMetrics {
        id: metrics
        font.family: regularLoader.name
    }
    */


    /*
    readonly property FontLoader boldLoader: FontLoader {
        id: boldLoader
        source: "qrc:/fonts/avenir_next_lt_pro_bold.otf"
    }

    readonly property FontLoader italicLoader: FontLoader {
        id: italicLoader
        source: "qrc:/fonts/avenir_next_lt_pro_it.otf"
    }

    Component.onCompleted: {
        console.log("youpi")
    }*/
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
