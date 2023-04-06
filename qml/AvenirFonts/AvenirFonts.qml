pragma Singleton

import QtQuick 2.12

QtObject {

    readonly property FontLoader regularLoader: FontLoader {
        id: regularLoader
        source: "qrc:/fonts/avenir_next_lt_pro_regular.otf"
    }

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
    }

    readonly property string regular: regularLoader.name
    readonly property string bold: boldLoader.name
    readonly property string italic: italicLoader.name
}
