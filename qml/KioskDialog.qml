import QtQuick
import QtQuick.Window
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Layouts
import AvenirFonts 1.0

Dialog {
    property alias text: contentLabel.text
    property alias acceptText: acceptBtn.text
    property alias cancelText: cancelBtn.text
    property bool withCancelButton: false

    parent: Overlay.overlay
    x: (parent.width - this.implicitWidth) / 2
    y: parent.height / 2 - this.height / 2

    id: root
    modal: true
    closePolicy: "NoAutoClose"
    // signal onAccepted
    signal canceled

    background: Rectangle {
        border.color: "transparent"
        radius: 5
    }

    header: Label {
        text: root.title
        horizontalAlignment: Qt.AlignHCenter

        font.family: AvenirFonts.bold.name
        font.pointSize: 18
        padding: 12
        color: "#3b78bc"
    }

    contentItem: ColumnLayout {

        id: column
        spacing: 20

        RowLayout {
            Layout.alignment: Qt.AlignCenter

            Label {
                id: contentLabel
                font.family: AvenirFonts.regular.name
                wrapMode: "WordWrap"
                font.pointSize: 12
                Layout.columnSpan: 2
                Layout.alignment: Qt.AlignRight
                Layout.minimumWidth: root.parent.width / 8
                Layout.maximumWidth: root.parent.width / 4
                horizontalAlignment: Qt.AlignCenter
            }
        }

        RowLayout {

            Layout.alignment: Qt.AlignCenter
            spacing: 30

            KioskDialogButton {
                id: cancelBtn
                text: "Annuler"
                onClicked: {
                    root.canceled()
                    close()
                }
                visible: withCancelButton
            }

            KioskDialogButton {
                id: acceptBtn
                text: "Ok"
                onClicked: {
                    root.accepted()
                    close()
                }
            }
        }
    }
}
