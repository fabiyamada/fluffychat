import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent

    function search () {
        // Search in the roster and displays a potential new contact
        var searchInput = searchTextField.displayText

        // Go through all items in the roster
        for( var i = 0; i < rosterGrid.children.length; ++i ) {

            // Remove old newContact-items
            if ( rosterGrid.children[i].contactProposal ) {
                rosterGrid.children[i].destroy ()
                continue;
            }

            // The potential new contact
            var newContact = searchInput
            var newContactInRoster = false
            if ( newContact.indexOf("@") === -1 ) {
                newContact += "@" + defaultDomain
            }

            // Search in the current item
            // If the searchInputField is empty, then just show all roster items
            if( searchInput === "" ||
            rosterGrid.children[i].name.indexOf ( searchInput ) !== -1 ){

                rosterGrid.children[i].visible = true
                // Is the potential new user allreay in the roster?
                if ( rosterGrid.children[i].name === newContact ) newContactInRoster = true
            }
            else {
                rosterGrid.children[i].visible = false
            }


        }

        // If the potential new user is not in the roster, then display a
        // new item in the grid

        if ( !newContactInRoster && searchInput !== "" ) {
            var newTask = Qt.createComponent("../components/ContactGridItem.qml")
            newTask.createObject(rosterGrid, {"name": newContact, "contactProposal": true, "iconName": "contact-new" })
        }
    }


    function joinRoom () {
        var newChatId = searchTextField.displayText
        errorReport.text = ""
        if ( newChatId === "" ) searchTextField.focus = true
        else {

            var success_callback = function () {
                searchTextField.text = ""
                activeChat = newChatId
                if ( mainStack.depth === 1 ) bottomEdge.collapse()
                else mainStack.pop ()
                mainStack.push (Qt.resolvedUrl("./ChatPage.qml"))
            }
            var error_callback = function ( error ) {
                var errcodes = {
                    "M_UNKNOWN": i18n.tr("Room was not found 😟"),
                }
                errorReport.text = error.errcode in errcodes ? errcodes[error.errcode] : error.error
            }

            matrix.post("/client/r0/join/" + encodeURIComponent(newChatId), null, success_callback, error_callback)
        }

    }

    header: FcPageHeader {
        title: i18n.tr('Start a new chat')

        trailingActionBar {
            actions: [
            Action {
                iconName: "contact-new"
                onTriggered: joinRoom ()
            }
            ]
        }
    }

    TextField {
        id: searchTextField
        anchors.top: header.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: height
        width: parent.width - height
        placeholderText: i18n.tr("Enter room id or alias")
        Keys.onReturnPressed: joinRoom ()
        //onDisplayTextChanged: search ()
    }


    Label {
        id: errorReport
        anchors.top: searchTextField.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: height
        color: UbuntuColors.red
        text: ""
        visible: text !== ""
    }


    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height - 3*searchTextField.height
        anchors.top: searchTextField.bottom
        anchors.topMargin: searchTextField.height

        contentItem: Grid {
            id: rosterGrid
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

}
