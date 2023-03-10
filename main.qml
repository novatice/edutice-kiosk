import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Universal 2.12
import QtQml 2.12
import QtWebEngine 1.8
import Process 1.0

Window {
    width: Screen.width
    height: Screen.height
    visible: true
    flags: Qt.FramelessWindowHint | Qt.Window
    visibility: Qt.WindowFullScreen

    Shortcut {
        context: Qt.ApplicationShortcut
        sequences: ["Alt+Shift+Q"]

        onActivated: {
            console.log("JS: Shortcut activated.")
            Process.start("konsole")
        }
    }

    Universal.theme: Universal.Dark
    Universal.accent: Universal.Violet

    Column {
        Item {
            id: banner
            visible: !totem
            width: parent.width
            height: totem ? 0 : 80

            Rectangle {
                color: "#444B69"
                width: parent.width
                height: parent.height
            }

            RowLayout {

                height: parent.height
                width: parent.width
                Layout.alignment: Qt.AlignCenter

                Row {

                    Layout.alignment: Qt.AlignLeft

                    KioskButton {
                        icon.source: "icons/back.png"
                        onClicked: webEngine.goBack()
                        disabled: !webEngine.canGoBack
                    }

                    KioskButton {
                        icon.source: "icons/forward.png"
                        onClicked: webEngine.goForward()
                        disabled: !webEngine.canGoForward
                    }
                }

                Spacer {}

                KioskButton {
                    Layout.alignment: Qt.AlignHCenter
                    id: control
                    text: "Fermer la session"
                    icon.source: "icons/session-close.png"
                    padding: 10
                    onClicked: Process.disconnect()

                    contentItem: RowLayout {

                        Image {
                            source: control.icon.source
                        }

                        Text {
                            text: control.text
                            color: "white"
                        }
                    }

                    background: Rectangle {
                        color: "#4A5B7B"
                        radius: 50
                    }
                }

                Spacer {}

                Row {
                    Layout.alignment: Qt.AlignRight
                    KioskButton {
                        icon.source: "icons/zoom-out.png"
                        onClicked: {
                            webEngine.zoomFactor = webEngine.zoomFactor - 0.1
                            webEngine.zoomFactor = webEngine.zoomFactor - 0.1
                        }
                    }

                    KioskButton {
                        id: zoom
                        text: (webEngine.zoomFactor * 100).toFixed(0) + "%"

                        contentItem: Text {
                            text: zoom.text
                            color: "white"
                        }

                        onClicked: {
                            webEngine.zoomFactor = 1
                        }
                    }

                    KioskButton {
                        icon.source: "icons/zoom-in.png"
                        onClicked: {
                            webEngine.zoomFactor = webEngine.zoomFactor + 0.1
                            webEngine.zoomFactor = webEngine.zoomFactor + 0.1
                        }
                    }
                }
            }
        }

        Item {
            width: parent.parent.width
            height: parent.parent.height - banner.height

            WebEngineView {
                width: parent.width
                height: parent.height
                profile.httpCacheType: WebEngineProfile.NoCache

                id: webEngine

                onContextMenuRequested: function (request) {
                    request.accepted = true
                }

                onFullScreenRequested: function (request) {
                    request.accept()
                }

                onPrintRequested: function () {
                    showMessage("L'impression n'est pas autoris??e")
                }

                onFileDialogRequested: function (request) {
                    showMessage("Le t??l??versement de fichiers n'est pas autoris??")
                    request.accepted = true
                }

                onNewViewRequested: function (request) {
                    if (request.userInitiated) {
                        webEngine.url = request.requestedUrl
                    }
                }

                onNavigationRequested: function (request) {
                    var urlStr = request.url.toString()
                    // ignore mailto and other
                    if (!(urlStr.startsWith("http://") || urlStr.startsWith(
                              "https://"))) {
                        request.action = WebEngineNavigationRequest.IgnoreRequest
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
                    messageDialog.setX(
                                Screen.width / 2 - messageDialog.width / 2)
                    messageDialog.setY(
                                Screen.height / 2 - messageDialog.height / 2)
                }

                MessageDialog {
                    id: messageDialog
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
