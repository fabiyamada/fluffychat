import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "controller"
import "components"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'fluffychat.christianpauly'
    automaticOrientation: true

    // automatically anchor items to keyboard that are anchored to the bottom
    anchorToKeyboard: true

    width: units.gu(45)
    height: units.gu(75)

    property var activeChat: null
    property var activeChatDisplayName: null
    property var defaultDomain: "matrix.org"
    property var defaultDeviceName: "UbuntuPhone"
    property var defaultTimeout: 10000
    property var longPollingTimeout: 60000
    property var progressBarRequests: 0
    property var waitingForSync: false
    property var appstatus: 4


    PageStack {
        id: mainStack
        function toStart () { while (depth > 1) pop() }
    }
    StorageController { id: storage }
    MatrixController { id: matrix }
    StampController { id: stamp }
    EventController { id: events }
    RoomNameController { id: roomnames }
    UserNameController { id: usernames }
    DisplayEventController { id: displayEvents }
    Toast { id: toast }
    LoadingModal { id: loadingModal }

    onActiveChatChanged: {
        roomnames.getById ( activeChat, function (name) {
            activeChatDisplayName = name
        } )
    }


    Component.onCompleted: {
        storage.init ()
        matrix.init ()

    }
}
