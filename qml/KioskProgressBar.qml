import QtQuick
import QtQuick.Controls.Basic
import QtQml

ProgressBar {
    id: root

    background: Rectangle {
        implicitWidth: root.width
        implicitHeight: root.height
        color: "#e6e6e6"
        radius: 3
    }

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
