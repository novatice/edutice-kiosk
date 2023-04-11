import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

ProgressBar {
    id: root

    contentItem: Item {

        Rectangle {
            id: item
            width: root.visualPosition * parent.width
            height: root.height
            radius: 10
            color: "#68A0DD"
        }
    }
}
