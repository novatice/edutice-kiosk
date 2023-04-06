import QtQml 2.12
import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    property bool disabled: false
    property string tooltip

    id: control
    background: Rectangle {
        color: "transparent"
    }

    icon.color: disabled ? "gray" : "white"

    MouseArea {
        id: ma
        cursorShape: Qt.PointingHandCursor
        enabled: !control.disabled
        anchors.fill: parent
        hoverEnabled: true

        onEnabledChanged: {
            if (!this.enabled) {
                cursorShape = Qt.ArrowCursor
            } else {
                cursorShape = Qt.PointingHandCursor
            }
        }

        onClicked: {
            control.onClicked()
        }
    }

    ToolTip.visible: this.hovered
    ToolTip.text: tooltip
}
