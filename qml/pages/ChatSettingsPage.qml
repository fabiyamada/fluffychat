import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    property var membership: "unknown"
    property var max: 20
    property var position: 0
    property var blocked: false
    property var newContactMatrixID

    function init () {

        // Get the member status of the user himself
        storage.transaction ( "SELECT membership FROM Rooms WHERE id='" + activeChat + "'", function (res) {
            membership = res.rows.length > 0 ? res.rows[0].membership : "unknown"
        })

        // Request the full memberlist, from the server
        matrix.get ( "/client/r0/rooms/%1/members".arg(activeChat), null, function (response) {
            for ( var i = 0; i < response.chunk.length; i++ ) {
                var member = response.chunk[ i ]
                model.append({
                    name: member.content.displayname || usernames.transformFromId( member.state_key ),
                    matrixid: member.state_key,
                    membership: getDisplayMemberStatus ( member.membership ),
                    avatar_url: member.content.avatar_url
                })
            }
        })
    }

    function getDisplayMemberStatus ( membership ) {
        if ( membership === "join" ) return i18n.tr("Member")
        else if ( membership === "invite" ) return i18n.tr("Was invited")
        else if ( membership === "leave" ) return i18n.tr("Has left the chat")
        else if ( membership === "knock" ) return i18n.tr("Has knocked")
        else if ( membership === "ban" ) return i18n.tr("Was banned from the chat")
        else return i18n.tr("Unknown")
    }

    function startChat_callback ( response ) {
        activeChat = response.room_id
        if ( mainStack.depth === 1 ) bottomEdge.collapse()
        else mainStack.pop ()
        mainStack.push (Qt.resolvedUrl("./ChatPage.qml"))
    }


    Component.onCompleted: init ()

    InviteDialog { id: inviteDialog }

    NewContactDialog { id: newContactDialog }

    ChangeChatnameDialog { id: changeChatnameDialog }

    LeaveChatDialog { id: leaveChatDialog }

    header: FcPageHeader {
        id: header
        title: activeChatDisplayName

        trailingActionBar {
            numberOfSlots: 1
            actions: [
            Action {
                iconName: "compose"
                text: i18n.tr("Edit chat name")
                onTriggered: PopupUtils.open(changeChatnameDialog)
            }
            ]
        }
    }



    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: root.width
            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }
            Avatar {  // Useravatar
                id: avatarImage
                source: "../../assets/chat.svg"
                width: parent.width / 2
                radius: 100
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }
            Label {
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: i18n.tr("Chat Settings:")
                font.bold: true
            }
            Rectangle {
                width: parent.width
                height: settingsColumn.height
                color: theme.palette.normal.background
                Column {
                    id: settingsColumn
                    width: parent.width
                    SettingsListItem {
                        name: i18n.tr("Invite friend")
                        icon: "contact-new"
                        onClicked: PopupUtils.open(inviteDialog)
                    }
                    SettingsListLink {
                        name: i18n.tr("Notifications")
                        icon: "notification"
                        page: "NotificationChatSettingsPage"
                    }
                    SettingsListItem {
                        name: i18n.tr("Leave Chat")
                        icon: "delete"
                        onClicked: PopupUtils.open(leaveChatDialog)
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }
            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
                Label {
                    id: userInfo
                    height: units.gu(2)
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(2)
                    text: memberList.count > 0 ? i18n.tr("Users in this chat (%1):").arg(memberList.count) : i18n.tr("Loading users ...")
                    font.bold: true
                }
            }

            ListView {
                id: memberList
                width: parent.width
                height: root.height / 2
                delegate: MemberListItem { }
                model: ListModel { id: model }
                z: -1
            }
        }
    }

}
