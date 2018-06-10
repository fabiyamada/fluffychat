import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Content 1.3
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {

    id: chatPage

    property var sending: false
    property var membership: "join"

    function send () {
        if ( sending || messageTextField.displayText === "" ) return
        var messageID = Math.floor((Math.random() * 1000000) + 1);
        var data = {
            msgtype: "m.text",
            body: messageTextField.displayText
        }
        var fakeEvent = {
            type: "m.room.message",
            sender: matrix.matrixid,
            content_body: messageTextField.displayText,
            displayname: matrix.displayname,
            avatar_url: matrix.avatar_url,
            sending: true,
            origin_server_ts: new Date().getTime(),
            content: {}
        }
        chatScrollView.addEventToList ( fakeEvent )

        var error_callback = function ( error ) {
            if ( error.error !== "offline" ) toast.show ( error.errcode + ": " + error.error )
            chatScrollView.update ()
        }

        matrix.put( "/client/r0/rooms/" + activeChat + "/send/m.room.message/" + messageID, data, null, error_callback )

        messageTextField.focus = false
        messageTextField.text = ""
        messageTextField.focus = true
    }


    function sendAttachement ( mediaUrl ) {

        // Start the upload
        matrix.upload ( mediaUrl, function ( response ) {
            // Uploading was successfull, send now the file event
            console.log( JSON.stringify(response) )
            var messageID = Math.floor((Math.random() * 1000000) + 1);
            var data = {
                msgtype: "m.image",
                body: "Image",
                url: response.content_uri
            }
            var error_callback = function ( error ) {
                if ( error.error !== "offline" ) toast.show ( error.errcode + ": " + error.error )
                chatScrollView.update ()
            }

            matrix.put( "/client/r0/rooms/" + activeChat + "/send/m.room.message/" + messageID, data, null, error_callback )
        }, console.error )

        // Set the fake event while the file is uploading
        var fakeEvent = {
            type: "m.room.message",
            sender: matrix.matrixid,
            content_body: "Datei wird gesendet ...",
            displayname: matrix.displayname,
            avatar_url: matrix.avatar_url,
            sending: true,
            origin_server_ts: new Date().getTime(),
            content: {}
        }
        chatScrollView.addEventToList ( fakeEvent )
        messageTextField.focus = false
        messageTextField.text = ""
        messageTextField.focus = true
    }


    MediaImport { id: mediaImport }


    Component.onCompleted: {
        storage.transaction ( "SELECT membership FROM Rooms WHERE id='" + activeChat + "'", function (res) {
            membership = res.rows.length > 0 ? res.rows[0].membership : "join"
        })
        chatScrollView.update ()
    }

    Component.onDestruction: {
        activeChat = activeChatDisplayName = null
    }

    Connections {
        target: events
        onChatTimelineEvent: chatScrollView.handleNewEvent ()
    }

    Connections {
        target: mediaImport
        onMediaReceived: sendAttachement ( mediaUrl )
    }


    InviteDialog { id: inviteDialog }

    ChangeChatnameDialog { id: changeChatnameDialog }

    header: FcPageHeader {
        title: activeChatDisplayName || i18n.tr("Unknown chat")

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "contact-new"
                text: i18n.tr("Invite a friend")
                onTriggered: PopupUtils.open(inviteDialog)
            },
            Action {
                iconName: "compose"
                text: i18n.tr("Edit chat name")
                onTriggered: PopupUtils.open(changeChatnameDialog)
            },
            Action {
                iconName: "info"
                text: i18n.tr("Info")
                onTriggered: mainStack.push(Qt.resolvedUrl("./ChatSettingsPage.qml"))
            },
            Action {
                iconName: "delete"
                text: i18n.tr("Leave chat")
                onTriggered: {
                    matrix.post("/client/r0/rooms/" + activeChat + "/leave", null, function () {
                        events.waitForSync ()
                        mainStack.pop()
                    })
                }
            }
            ]
        }
    }

    Rectangle {
        anchors.fill: parent
        opacity: 0.15
        //color: mainColor
        gradient: Gradient {
            GradientStop { position: 0.0; color:  "#FFFFFF" }
            GradientStop { position: 0.2; color:  UbuntuColors.blue }
            GradientStop { position: 0.5; color:  UbuntuColors.orange }
            GradientStop { position: 0.8; color:  UbuntuColors.purple }
            GradientStop { position: 1.0; color:  "#FFFFFF" }
        }
        z: 0
    }

    Icon {
        source: "../../assets/background.svg"
        anchors.centerIn: parent
        width: parent.width / 1.25
        height: width
        opacity: 0.15
        z: 0
    }

    Label {
        text: i18n.tr('No messages in this chat ...')
        anchors.centerIn: parent
        visible: chatScrollView.count === 0
    }

    ChatScrollView { id: chatScrollView }

    Rectangle {
        id: chatInput
        anchors.bottom: parent.bottom
        height: header.height
        width: parent.width
        border.width: 1
        border.color: UbuntuColors.silk

        Button {
            id: joinButton
            color: UbuntuColors.green
            text: i18n.tr("Accept invatiation")
            anchors.centerIn: parent
            visible: membership === "invite"
            onClicked: {
                var success_callback = function () {
                    toast.show ( i18n.tr("Synchronizing \n This can take a few minutes ...") )
                    events.waitForSync ()
                    membership = "join"
                }
                matrix.post("/client/r0/join/" + encodeURIComponent(activeChat), null, success_callback)
            }
        }

        ActionBar {
            id: chatAttachementActionBar
            visible: membership === "join"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            actions: [
            Action {
                id: attachementButton
                iconName: "camera-photo-symbolic"
                onTriggered: mediaImport.requestMedia ()
                enabled: !sending
            }
            ]
        }

        TextField {
            id: messageTextField
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: units.gu(1)
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - chatInputActionBar.width - chatAttachementActionBar.width - units.gu(1)
            placeholderText: i18n.tr("Type something ...")
            Keys.onReturnPressed: sendButton.trigger ()
            visible: membership === "join"
        }
        ActionBar {
            id: chatInputActionBar
            visible: membership === "join"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            actions: [
            Action {
                id: sendButton
                iconName: "send"
                onTriggered: send ()
                enabled: !sending
            }
            ]
        }
    }

    Rectangle {
        id: toBottomRectangle
        color: "#FFFFFF"
        z: 2
        anchors.bottom: parent.bottom
        height: header.height
        width: parent.width
        border.width: 1
        border.color: UbuntuColors.silk
        visible: chatScrollView.historyPosition > 0
        Button {
            id: toBottomButton
            color: UbuntuColors.porcelain
            text: i18n.tr("Scroll down")
            anchors.centerIn: parent
            onClicked: {
                chatScrollView.updated = false
                chatScrollView.historyPosition = 0
                chatScrollView.update ()
            }
        }
    }

}
