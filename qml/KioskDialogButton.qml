import QtQuick
import QtQuick.Controls
import AvenirFonts 1.0

KioskButton {
    id: root

    contentItem: Text {
        text: root.text
        font.family: AvenirFonts.regular.name
        font.pointSize: 12
        padding: 5
        color: "white"
    }

    background: Rectangle {
        anchors.fill: root
        color: "#3b78bc"
        radius: 5
    }
}
