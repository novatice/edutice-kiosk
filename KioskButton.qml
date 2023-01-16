import QtQml 2.12
import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    property bool disabled: false

    id: control
    background: Rectangle {
        color: "transparent"
    }
    icon.color: disabled ? "gray" : "white"

    MouseArea {
        enabled: !control.disabled
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.onClicked()
        onEntered: {
            cursorShape = Qt.PointingHandCursor
        }
    }
}
