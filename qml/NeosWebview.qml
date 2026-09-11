import QtQuick 2.12
import QtWebEngine
import PrintHelper 1.0

WebEngineView {
    id: webView

    KioskProgressBar {
        width: parent.width
        height: 5
        z: 1
        value: webView.loadProgress
        visible: webView.loading
        anchors.top: parent.top
    }
    property string homeUrl: ""
    property bool firstLoad: true
    property bool homeWebview: false
    property bool isPrinting: false

    profile.httpCacheType: WebEngineProfile.NoCache
    profile.persistentCookiesPolicy: WebEngineProfile.NoPersistentCookies
    profile.httpAcceptLanguage: getLocaleAsAcceptLanguage()

    function goHome() {
        if (homeUrl !== url) {
            url = homeUrl;
        }
        tabStack.currentIndex = 0;
    }

    function getLocaleAsAcceptLanguage() {
        const locale = Qt.locale();
        return locale.name.replace("_", "-");
    }

    onContextMenuRequested: function (request) {
        request.accepted = true;
    }

    onFullScreenRequested: function (request) {
        request.accept();
    }

    function isPrintAllowed() {
        return deviceConfig !== undefined && deviceConfig.printAllowed;
    }

    function requestPrint(printFn) {
        if (!isPrintAllowed()) {
            showMessage("L'impression n'est pas autorisée");
            return;
        }
        if (isPrinting) {
            console.log("print already in progress, ignoring request");
            return;
        }
        var path = PrintHelper.tempPdfPath();
        if (!path) {
            showMessage("L'impression n'est pas autorisée");
            return;
        }
        isPrinting = true;
        printFn(path);
    }

    onPrintRequested: function () {
        requestPrint(function (path) {
            webView.printToPdf(path);
        });
    }

    // Qt >= 6.8 emits printRequestedByFrame for subframes instead of
    // printRequested. Connections with ignoreUnknownSignals keeps this
    // working on Qt 6.7 and earlier where the signal does not exist.
    Connections {
        target: webView
        ignoreUnknownSignals: true
        function onPrintRequestedByFrame(frame) {
            requestPrint(function (path) {
                frame.printToPdf(path);
            });
        }
    }

    onPdfPrintingFinished: function (filePath, success) {
        if (!isPrinting) {
            return;
        }
        isPrinting = false;
        if (!success) {
            console.log("PDF generation failed for printing: ", filePath);
            showMessage("Échec de l'impression");
            return;
        }
        var result = PrintHelper.printPdf(filePath);
        if (result === PrintHelper.NoPrinter) {
            showMessage("Aucune imprimante disponible");
        } else if (result !== PrintHelper.Ok) {
            showMessage("Échec de l'impression");
        }
    }

    onFileDialogRequested: function (request) {
        showMessage("Le téléversement de fichiers n'est pas autorisé");
        request.accepted = true;
        request.dialogReject();
    }

    onNewWindowRequested: function (request) {
        if (request.userInitiated) {
            webEngine.url = request.requestedUrl;
        }
    }

    onNavigationRequested: function (request) {
        var urlStr = request.url.toString();
        console.log("trying to navigate to: ", urlStr);
        // ignore mailto and other
        if (!(urlStr.startsWith("http://") || urlStr.startsWith("https://"))) {
            console.debug("rejected");
            request.reject();
        } else {
            if (firstLoad) {
                firstLoad = urlStr === urlToLoad;
            }
            if (deviceConfig !== undefined) {
                const urlAfterParameters = deviceConfig.addNeosUrlParameters(urlStr);
                if (urlAfterParameters !== urlStr) {
                    webEngine.url = urlAfterParameters;
                    request.reject();
                } else {
                    if (request.navigationType === WebEngineNavigationRequest.LinkClickedNavigation && homeWebview && deviceConfig.tabMode) {
                        request.reject();
                        createNewTab(urlStr);
                    } else {
                        request.accept();
                    }
                }
            }
        }
    }

    onAuthenticationDialogRequested: function (request) {
        request.accepted = true;
        request.dialogReject();
    }

    onLoadingChanged: function (request) {
        if (request.status === WebEngineView.LoadFailedStatus && (request.errorCode < 400 && request.errorCode >= 500)) {
            console.log("loading failed: ", request.errorCode, " ", request.errorString);
            reloadingTimer.start();
        }
    }

    function showMessage(text) {
        messageDialog.text = text;
        messageDialog.open();
    }

    KioskDialog {
        id: messageDialog
        title: "Avertissement"
    }

    Timer {
        id: reloadingTimer
        interval: 5000
        onTriggered: function () {
            webEngine.reloadAndBypassCache();
        }
    }

    url: homeUrl
}
