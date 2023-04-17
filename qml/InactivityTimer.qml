import QtQuick 2.12
import QtQml 2.12
import QtQuick.Dialogs 1.3
import InactivityWatcher 1.0
import Process 1.0

Item {
    property int inactivyDelay: 300
    property int lastSeconds: 20
    property bool enabled: true

    Component.onCompleted: {
        if (this.enabled) {
            inactivityTimer.start()
        }
    }

    function getInactivityText() {
        if (automatic) {
            return `Sans action de votre part vos données de navigation seront suprimées dans ${lastSecondsTimer.seconds} seconde(s).`
        } else {
            return `Sans action de votre part la borne de consultation se fermera dans ${lastSecondsTimer.seconds} seconde(s).`
        }
    }

    function start() {
        inactivityTimer.restart()
    }

    function stop() {
        inactivityTimer.stop()
    }

    Connections {
        target: InactivityWatcher
        onEventRaised: {
            if (enabled && inactivityTimer.running) {
                inactivityTimer.restart()
            }
        }
    }

    Timer {
        id: inactivityTimer
        interval: (inactivyDelay - lastSeconds) * 1000

        onTriggered: function () {
            console.log("inactivity")
            inactivityDialog.open()
            lastSecondsTimer.start()
            this.stop()
        }
    }

    Timer {
        id: lastSecondsTimer
        repeat: true

        function reset() {
            this.stop()
            this.seconds = lastSeconds
            inactivityTimer.restart()
            inactivityDialog.text = getInactivityText()
        }

        property int seconds: lastSeconds
        interval: 1000
        onTriggered: {
            this.seconds--
            inactivityDialog.text = getInactivityText()
            console.log(this.seconds, " remaining")
            if (this.seconds === 0) {
                Process.disconnect()
                Qt.quit()
            }
        }
    }

    KioskDialog {
        id: inactivityDialog
        title: "Inactivité"
        text: getInactivityText()
        acceptText: "Je suis là !"
        onAccepted: lastSecondsTimer.reset()
    }
}
