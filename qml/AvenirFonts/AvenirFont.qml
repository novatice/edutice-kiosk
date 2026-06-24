import QtQml 2.12
import QtQuick 2.12

QtObject {
    property alias source: loader.source

    readonly property FontLoader loader: FontLoader {
        id: loader
    }

    readonly property FontMetrics metrics: FontMetrics {
        id: metrics
        font.family: loader.name
    }

    default property string name: loader.name
}
