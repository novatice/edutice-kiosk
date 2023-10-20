import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Universal 2.12
import QtQml 2.12
import QtWebEngine 1.8
import Process 1.0
import AvenirFonts 1.0

Window {
    width: Screen.width
    height: Screen.height
    visible: true
    flags: Qt.FramelessWindowHint | Qt.Window
    visibility: Qt.WindowFullScreen
    Component.onCompleted: {
        if (!automatic) {
            dataDialog.open()
        }
    }

    Shortcut {
        context: Qt.ApplicationShortcut
        sequences: ["Alt+Shift+Q"]

        onActivated: {
            console.log("JS: Shortcut activated.")
            Process.openTerminal()
        }
    }

    InactivityTimer {
        id: inactivityTimer
        inactivyDelay: 300
        lastSeconds: 20
        enabled: !totem
    }

    function getCloseText() {
        if (automatic) {
            return "Vos données de navigation seront supprimées.\n\n Confirmez-vous cette opération ?"
        } else {
            return "Voulez-vous quitter la borne de consultation ?"
        }
    }

    KioskDialog {
        Timer {
            id: dataTimer
            interval: 10000
            onTriggered: {
                bubbleAnimationDisappear.start()
            }
        }

        id: dataDialog
        title: "Données de navigation"
        acceptText: "Ok"
        text: "Pensez à fermer votre session afin de procéder au nettoyage de vos données de navigation !"
        onAccepted: {
            bubbleAnimationAppear.start()
        }
    }

    KioskDialog {
        id: closeDialog
        title: "Fin de session"
        withCancelButton: true
        acceptText: "Confirmer"
        text: getCloseText()
        onAccepted: {
            Process.disconnect()
            Qt.quit()
        }

        onCanceled: {
            if (!totem) {
                inactivityTimer.start()
            }
        }
    }

    Universal.theme: Universal.Dark
    Universal.accent: Universal.Violet

    ColumnLayout {
        spacing: 0
        width: parent.width
        height: parent.height

        Item {
            id: banner
            visible: !totem
            Layout.fillWidth: true
            height: totem ? 0 : 60
            // allow bubble on close button to be visible
            // maybe it would be better to use an overlay ?
            z: 1

            Rectangle {
                color: "#444B69"
                width: parent.width
                height: parent.height
            }

            RowLayout {

                height: parent.height
                width: parent.width
                Layout.alignment: Qt.AlignVCenter

                // use this item to add padding to layout
                Item {
                    width: 5
                }

                RowLayout {

                    Layout.alignment: Qt.AlignVCenter

                    KioskButton {
                        icon.source: "../icons/back.png"
                        onClicked: webEngine.goBack()
                        tooltip: "Précédent"
                        disabled: !webEngine.canGoBack
                    }

                    KioskButton {
                        icon.source: "../icons/forward.png"
                        onClicked: webEngine.goForward()
                        tooltip: "Précédent"
                        disabled: !webEngine.canGoForward
                    }

                    KioskButton {
                        icon.source: "../icons/refresh.svg"
                        onClicked: webEngine.reloadAndBypassCache()
                        tooltip: "Recharger la page"
                        disabled: webEngine.loading
                    }

                    KioskButton {
                        icon.source: "../icons/home.svg"
                        onClicked: webEngine.goHome()
                        tooltip: "Retourner à la page d'accueuil"
                        disabled: false
                    }
                }

                KioskButton {
                    readonly property int maxIconSize: 48
                    readonly property int minIconSize: 32
                    property int iconSize: maxIconSize
                    property bool disabled: webEngine.firstLoad
                    visible: automatic

                    id: cleanBtn
                    //visible: !webEngine.firstLoad
                    text: "Nettoyer mes données !"

                    icon.height: iconSize
                    icon.width: iconSize

                    icon.source: "../icons/brush.svg"

                    // this undocumented, found at https://stackoverflow.com/a/64128167
                    palette.buttonText: "white"

                    contentItem: RowLayout {

                        id: contentItem

                        SequentialAnimation {

                            NumberAnimation {
                                target: cleanBtn
                                property: "iconSize"
                                //loops: Animation.Infinite
                                duration: 1000

                                from: cleanBtn.minIconSize
                                easing.type: Easing.Bezier
                                to: cleanBtn.maxIconSize
                            }

                            NumberAnimation {
                                target: cleanBtn
                                property: "iconSize"
                                //loops: Animation.Infinite
                                duration: 1000

                                to: cleanBtn.minIconSize
                                easing.type: Easing.Bezier
                                from: cleanBtn.maxIconSize
                            }
                            running: !cleanBtn.disabled
                            loops: Animation.Infinite
                        }

                        // take the max of the size so button doesn't change size when animation runs
                        Item {
                            width: cleanBtn.maxIconSize
                            height: cleanBtn.maxIconSize

                            Image {
                                source: "../icons/brush.svg"

                                sourceSize.width: cleanBtn.iconSize
                                sourceSize.height: cleanBtn.iconSize
                                anchors.centerIn: parent
                            }
                        }

                        SequentialAnimation {
                            NumberAnimation {
                                target: cleanTextItem
                                property: "implicitWidth"
                                duration: 200

                                from: 0
                                easing.type: Easing.Linear
                                to: cleanText.implicitWidth
                            }

                            PropertyAnimation {
                                target: cleanText
                                property: "visible"
                                from: false
                                to: true
                            }

                            running: !cleanBtn.disabled
                        }

                        Item {
                            id: cleanTextItem

                            implicitWidth: 0
                            implicitHeight: cleanBtn.disabled ? 0 : cleanText.implicitHeight
                            Text {
                                id: cleanText
                                text: "Nettoyer mes données !"
                                padding: 0
                                visible: false
                                color: "white"
                            }
                        }
                    }

                    background: Rectangle {
                        width: cleanBtn.width
                        color: cleanBtn.disabled ? "green" : "#F89345"
                        radius: 32
                    }

                    leftPadding: 0
                    rightPadding: !cleanBtn.disabled ? 10 : 0
                    verticalPadding: 0

                    onClicked: {
                        Process.disconnect()
                        Qt.quit()
                    }
                }

                Spacer {}

                RowLayout {
                    Layout.alignment: Qt.AlignVCenter

                    KioskButton {
                        icon.source: "../icons/zoom-out.svg"
                        tooltip: "Zoom arrière"

                        onClicked: {
                            let newZoomFactor = webEngine.zoomFactor - 0.1
                            webEngine.zoomFactor = newZoomFactor
                            webEngine.zoomFactor = newZoomFactor
                        }
                    }

                    KioskButton {
                        id: zoom
                        text: (webEngine.zoomFactor * 100).toFixed(0) + "%"
                        tooltip: "Réinitialiser le zoom"
                        contentItem: Item {
                            implicitHeight: text.height + 10
                            implicitWidth: text.width + 30

                            Rectangle {
                                anchors.fill: parent
                                anchors.centerIn: parent
                                antialiasing: true
                                color: "transparent"
                                border.color: "white"
                                radius: 5
                            }

                            Text {
                                id: text
                                anchors.centerIn: parent
                                text: zoom.text
                                horizontalAlignment: Text.AlignHCenter
                                font.family: AvenirFonts.regular.name
                                width: AvenirFonts.regular.metrics.boundingRect(
                                           "100%").width
                                color: "white"
                            }
                        }

                        onClicked: {
                            webEngine.zoomFactor = 1
                            webEngine.zoomFactor = 1
                        }
                    }

                    KioskButton {
                        icon.source: "../icons/zoom-in.svg"
                        tooltip: "Zoom avant"
                        onClicked: {
                            let newZoomFactor = webEngine.zoomFactor + 0.1
                            webEngine.zoomFactor = newZoomFactor
                            webEngine.zoomFactor = newZoomFactor
                        }
                    }

                    Item {
                        width: closeButton.width
                        height: closeButton.height
                        visible: !automatic

                        KioskButton {
                            id: closeButton
                            icon.source: "../icons/close.png"
                            tooltip: "Quitter"

                            onClicked: {
                                inactivityTimer.stop()
                                closeDialog.open()
                            }
                        }

                        SequentialAnimation {
                            id: bubbleAnimationDisappear
                            NumberAnimation {
                                target: bubble
                                property: "opacity"
                                duration: 1000

                                from: 1
                                easing.type: Easing.Linear
                                to: 0
                            }

                            PropertyAnimation {
                                target: cleanText
                                property: "visible"
                                from: true
                                to: false
                            }
                        }

                        SequentialAnimation {
                            id: bubbleAnimationAppear

                            PropertyAnimation {
                                target: bubble
                                property: "visible"
                                from: false
                                to: true
                            }

                            NumberAnimation {
                                target: bubble
                                property: "opacity"
                                duration: 1000

                                from: 0
                                easing.type: Easing.Linear
                                to: 1
                            }

                            onFinished: function () {
                                dataTimer.start()
                            }

                            //running: true
                        }

                        Item {
                            id: bubble
                            width: bubbleText.width
                            height: bubbleText.height
                            anchors.topMargin: 15
                            anchors.rightMargin: -5
                            anchors.top: parent.bottom
                            anchors.right: parent.right
                            opacity: 0

                            Rectangle {
                                color: "#41B146"
                                width: parent.width
                                height: parent.height
                                radius: 10
                            }

                            Text {
                                id: bubbleText
                                text: "Cliquez sur ce bouton pour fermer votre session !"
                                color: "white"
                                padding: 15
                            }

                            Canvas {
                                id: bubbleCanvas
                                width: 30
                                height: 15
                                antialiasing: true
                                anchors.bottom: parent.top
                                anchors.right: parent.right

                                anchors.rightMargin: closeButton.width / 2 - bubbleCanvas.width / 2
                                                     - parent.anchors.rightMargin
                                onPaint: {
                                    var ctx = getContext("2d")

                                    // the equliteral triangle
                                    ctx.beginPath()
                                    ctx.moveTo(0, bubbleCanvas.height)
                                    ctx.lineTo(bubbleCanvas.width / 2, 0)
                                    ctx.lineTo(bubbleCanvas.width,
                                               bubbleCanvas.height)
                                    ctx.closePath()

                                    // fill color
                                    ctx.fillStyle = "#41B146"
                                    ctx.fill()
                                }
                            }
                        }
                    }

                    Item {
                        width: 5
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            KioskProgressBar {
                width: parent.width
                height: 5
                z: 1
                value: webEngine.loadProgress
                visible: webEngine.loading
                anchors.top: parent.top
            }

            WebEngineView {
                property string homeUrl: urlToLoad
                property bool firstLoad: true

                width: parent.width
                height: parent.height

                profile.httpCacheType: WebEngineProfile.NoCache
                profile.httpAcceptLanguage: getLocaleAsAcceptLanguage()
                id: webEngine

                function goHome() {
                    url = homeUrl
                }

                function getLocaleAsAcceptLanguage() {
                    const locale = Qt.locale()
                    return locale.name.replace("_", "-")
                }

                onContextMenuRequested: function (request) {
                    request.accepted = true
                }

                onFullScreenRequested: function (request) {
                    request.accept()
                }

                onPrintRequested: function () {
                    showMessage("L'impression n'est pas autorisée")
                }

                onFileDialogRequested: function (request) {
                    showMessage("Le téléversement de fichiers n'est pas autorisé")
                    request.accepted = true
                    request.dialogReject()
                }

                onNewViewRequested: function (request) {
                    if (request.userInitiated) {
                        webEngine.url = request.requestedUrl
                    }
                }

                onNavigationRequested: function (request) {
                    var urlStr = request.url.toString()
                    console.log("trying to navigate to: ", urlStr)
                    // ignore mailto and other
                    if (!(urlStr.startsWith("http://") || urlStr.startsWith(
                              "https://"))) {
                        request.action = WebEngineNavigationRequest.IgnoreRequest
                    } else {
                        if (firstLoad) {
                            firstLoad = urlStr === urlToLoad
                        }
                    }
                }

                onLoadingChanged: function (request) {
                    if (request.status === WebEngineView.LoadFailedStatus) {
                        console.log("loading failed: ", request.errorCode, " ",
                                    request.errorString)
                        reloadingTimer.start()
                    }
                }

                function showMessage(text) {
                    messageDialog.text = text

                    messageDialog.open()
                }

                KioskDialog {
                    id: messageDialog
                    title: "Avertissement"
                }

                Timer {
                    id: reloadingTimer
                    interval: 5000
                    onTriggered: function () {
                        webEngine.reloadAndBypassCache()
                    }
                }

                url: urlToLoad
            }
        }
    }
}
