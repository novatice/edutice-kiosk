import QtQml 2.12
import QtQuick 2.12
import QtQuick.Controls 2.12
import AvenirFonts 1.0

Button {
    property bool disabled: false
    property string tooltip

    id: control
    background: Rectangle {
        color: "transparent"
    }

    icon.color: disabled ? "gray" : "transparent"
    icon.width: 32
    icon.height: 32

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

    ToolTip.visible: this.hovered && this.tooltip
    ToolTip.text: tooltip
    ToolTip.toolTip.font.family: AvenirFonts.regular.name
}
