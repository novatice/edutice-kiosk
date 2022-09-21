import QtQml 2.12
import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    id: control
    background: Rectangle {
                    color: "transparent"
            }
    icon.color: "white"

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.onClicked()
        onEntered: {
            cursorShape = Qt.PointingHandCursor
        }
    }
}
