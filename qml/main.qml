import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import QtQuick.Controls.Universal
import QtQml
import QtWebEngine
import Process 1.0
import AvenirFonts 1.0

Window {

    width: Screen.width
    height: Screen.height
    visible: true
    flags: Qt.FramelessWindowHint | Qt.Window
    visibility: Qt.WindowFullScreen
    Component.onCompleted: {
        var webview = createNewTab(urlToLoad);
        webview.homeWebview = true;
        console.debug("totem", deviceConfig.totem);
        console.debug("tabmode", deviceConfig.tabMode);
        if (!automatic) {
            dataDialog.open();
        }
    }

    Shortcut {
        context: Qt.ApplicationShortcut
        sequences: ["Alt+Shift+Q"]

        onActivated: {
            console.log("JS: Shortcut activated.");
            Process.openTerminal();
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
            return "Vos données de navigation seront supprimées.\n\n Confirmez-vous cette opération ?";
        } else {
            return "Voulez-vous quitter la borne de consultation ?";
        }
    }

    KioskDialog {
        id: dataDialog
        Timer {
            id: dataTimer
            interval: 10000
            onTriggered: {
                bubbleAnimationDisappear.start();
            }
        }
        title: "Données de navigation"
        acceptText: "Ok"
        text: "Pensez à fermer votre session afin de procéder au nettoyage de vos données de navigation !"
        onAccepted: {
            bubbleAnimationAppear.start();
        }
    }

    KioskDialog {
        id: closeDialog
        title: "Fin de session"
        withCancelButton: true
        acceptText: "Confirmer"
        text: getCloseText()
        onAccepted: {
            Process.disconnect();
            Qt.quit();
        }

        onCanceled: {
            if (!totem) {
                inactivityTimer.start();
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

                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                    KioskButton {
                        icon.source: "../icons/back.png"
                        onClicked: webEngine.goBack()
                        tooltip: "Précédent"
                        disabled: !getCurrentWebview().canGoBack
                    }

                    KioskButton {
                        icon.source: "../icons/forward.png"
                        onClicked: getCurrentWebview().goForward()
                        tooltip: "Suivant"
                        disabled: !getCurrentWebview().canGoForward
                    }

                    KioskButton {
                        icon.source: "../icons/refresh.svg"
                        onClicked: getCurrentWebview().reloadAndBypassCache()
                        tooltip: "Recharger la page"
                        disabled: getCurrentWebview().loading
                    }

                    KioskButton {
                        icon.source: "../icons/home.svg"
                        onClicked: {
                            tabBar.setCurrentIndex(0);
                            getCurrentWebview().goHome();
                        }
                        tooltip: "Retourner à la page d'accueil"
                        disabled: false
                    }
                }

                KioskButton {
                    id: cleanBtn
                    readonly property int maxIconSize: 48
                    readonly property int minIconSize: 32
                    property int iconSize: maxIconSize
                    property bool disabled: getCurrentWebview().firstLoad
                    visible: automatic
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
                        Process.disconnect();
                        Qt.quit();
                    }
                }

                ScrollView {
                    id: tabBarScrollView
                    Layout.fillWidth: true

                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                    clip: true

                    TabBar {
                        id: tabBar
                        visible: deviceConfig.tabMode
                        Layout.alignment: Qt.AlignLeft
                        background: Rectangle {
                            color: "transparent"
                        }
                        onCurrentIndexChanged: {
                            console.debug("currentIndex : ", tabBar.currentIndex);
                        }
                    }
                }

                Spacer {}

                RowLayout {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

                    KioskButton {
                        icon.source: "../icons/zoom-out.svg"
                        tooltip: "Zoom arrière"

                        onClicked: {
                            var currentWebview = getCurrentWebview();
                            let newZoomFactor = currentWebview.zoomFactor - 0.1;
                            currentWebview.zoomFactor = newZoomFactor;
                            currentWebview.zoomFactor = newZoomFactor;
                        }
                    }

                    KioskButton {
                        id: zoom
                        text: (getCurrentWebview().zoomFactor * 100).toFixed(0) + "%"
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
                                width: AvenirFonts.regular.metrics.boundingRect("100%").width
                                color: "white"
                            }
                        }

                        onClicked: {
                            var currentWebview = getCurrentWebview();
                            currentWebview.zoomFactor = 1;
                            currentWebview.zoomFactor = 1;
                        }
                    }

                    KioskButton {
                        icon.source: "../icons/zoom-in.svg"
                        tooltip: "Zoom avant"
                        onClicked: {
                            var currentWebview = getCurrentWebview();
                            let newZoomFactor = currentWebview.zoomFactor + 0.1;
                            currentWebview.zoomFactor = newZoomFactor;
                            currentWebview.zoomFactor = newZoomFactor;
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
                                inactivityTimer.stop();
                                closeDialog.open();
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
                                dataTimer.start();
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

                                anchors.rightMargin: closeButton.width / 2 - bubbleCanvas.width / 2 - parent.anchors.rightMargin
                                onPaint: {
                                    var ctx = getContext("2d");

                                    // the equliteral triangle
                                    ctx.beginPath();
                                    ctx.moveTo(0, bubbleCanvas.height);
                                    ctx.lineTo(bubbleCanvas.width / 2, 0);
                                    ctx.lineTo(bubbleCanvas.width, bubbleCanvas.height);
                                    ctx.closePath();

                                    // fill color
                                    ctx.fillStyle = "#41B146";
                                    ctx.fill();
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

            StackLayout {
                id: tabStack
                anchors.fill: parent
                currentIndex: tabBar.currentIndex
                onCurrentIndexChanged: {
                    console.debug("tabStack index : ", tabStack.currentIndex);
                }
            }

            Component {
                id: tabButtonComponent
                TabButton {
                    id: tabBtn

                    property WebEngineView associatedWebview: null
                    text: associatedWebview != null ? associatedWebview.title : "Loading ... "
                    property url tabIconUrl: ""

                    contentItem: RowLayout {

                        Image {
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            Layout.alignment: Qt.AlignVCenter
                            source: associatedWebview.icon

                            // Show default icon or hide if no favicon exists yet
                            visible: associatedWebview.icon
                            fillMode: Image.PreserveAspectFit
                        }
                        Label {
                            text: tabBtn.text
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            elide: "ElideRight"
                        }
                    }

                    opacity: 1
                    background: Rectangle {
                        color: "white"
                        opacity: tabBtn.checked ? 0.3 : (tabBtn.hovered ? 0.1 : 0)
                        radius: 10
                    }
                }
            }

            Component {
                id: newTabWebviewComponent

                NeosWebview {
                    id: webview
                    property TabButton tabButton: null
                }
            }
        }
    }

    function createNewTab(url) {
        var newWebview = newTabWebviewComponent.createObject(tabStack);
        var newTabButton = tabButtonComponent.createObject(tabBar);
        newWebview.tabButton = newTabButton;
        newTabButton.associatedWebview = newWebview;
        newWebview.homeUrl = url;
        tabBar.addItem(newTabButton);
        tabBar.setCurrentIndex(tabBar.count - 1);
        return newWebview;
    }

    function getCurrentWebview() {
        if (tabBar.currentIndex >= 0 && tabBar.currentIndex < tabStack.count) {
            return tabStack.children[tabBar.currentIndex];
        }
        return null;
    }
}
