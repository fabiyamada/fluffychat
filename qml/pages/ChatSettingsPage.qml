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
    property var memberlist
    property var blocked: false
    property var newContactMatrixID

    function init () {

        // Get the member status of the user himself
        storage.transaction ( "SELECT membership FROM Rooms WHERE id='" + activeChat + "'", function (res) {
            membership = res.rows.length > 0 ? res.rows[0].membership : "unknown"
        })

        // Request the full memberlist, from the server
        matrix.get ( "/client/r0/rooms/%1/members".arg(activeChat), null, function (response) {
            memberlist = response.chunk
            //for ( i = 0; i < memberlist.length; i++ ) memberlist[i].content.displayname = "User " + (i+1)
            for ( var i = 0; i < Math.min(memberlist.length, max); i++ ) {
                var member =memberlist[i]
                var newMemberListItem = Qt.createComponent("../components/MemberListItem.qml")
                newMemberListItem.createObject(memberList, {
                    name: member.content.displayname || usernames.transformFromId( member.state_key ),
                    id: member.state_key,
                    membership: member.content.membership,
                    avatar_url: member.content.avatar_url
                } )
            }
        })
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
            Column {
                width: parent.width
                SettingsListItem {
                    name: i18n.tr("Invite friend")
                    icon: "contact-new"
                    onClicked: PopupUtils.open(inviteDialog)
                }
                SettingsListItem {
                    name: i18n.tr("Notifications")
                    icon: "notification"
                    Icon {
                        name: "toolkit_chevron-ltr_1gu"
                        width: units.gu(3)
                        height: width
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: units.gu(2)
                    }
                    onClicked: mainStack.push(Qt.resolvedUrl("./NotificationChatSettingsPage.qml"))
                }
                SettingsListItem {
                    name: i18n.tr("Leave Chat")
                    icon: "delete"
                    onClicked: PopupUtils.open(leaveChatDialog)
                }
            }
            Rectangle {
                width: parent.width
                height: units.gu(2)
                color: theme.palette.normal.background
            }
            Label {
                id: userInfo
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: memberList.children.length > 0 ? i18n.tr("Users in this chat (%1):").arg(memberlist.length) : i18n.tr("Loading users ...")
                font.bold: true
            }

            Column {
                id: memberList
                width: parent.width
            }
        }

        // On scrolling, the view should display another part of the list
        flickableItem {
            onContentYChanged: {
                // User has scrolled to the bottom
                if ( flickableItem.contentY > flickableItem.contentHeight - height*2 ) {
                    if ( position+1+max < memberlist.length ) {
                        // Put one more item at the end of the list
                        var member = memberlist[ position++ + max ]
                        var newMemberListItem = Qt.createComponent("../components/MemberListItem.qml")
                        newMemberListItem.createObject(memberList, {
                            name: member.content.displayname || usernames.transformFromId( member.state_key ),
                            id: member.state_key,
                            membership: member.content.membership,
                            avatar_url: member.content.avatar_url
                        } )
                    }
                }
            }
        }
    }
}
