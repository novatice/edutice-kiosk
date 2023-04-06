import QtQuick 2.12
import QtQuick.Controls 2.12
import AvenirFonts 1.0

Button {
    id: root
    contentItem: Text {
        text: root.text
        font.family: AvenirFonts.regular
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
