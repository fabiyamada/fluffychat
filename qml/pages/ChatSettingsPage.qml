import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent

    property var membership: "unknown"

    function init () {
        storage.transaction ( "SELECT membership FROM Rooms WHERE id='" + activeChat + "'", function (res) {
            membership = res.rows[0].membership
        })
        storage.transaction ( "SELECT * FROM Roommembers WHERE roomsid='" + activeChat + "'", function (res) {
            for ( var i = 0; i < res.rows.length; i++ ) {
                var newMemberListItem = Qt.createComponent("../components/MemberListItem.qml")
                newMemberListItem.createObject(memberList, { name: res.rows[i].displayname || usernames.transformFromId(res.rows[i].state_key) })
            }
        })
    }

    Component.onCompleted: init ()

    header: FcPageHeader {
        id: header
        title: activeChatDisplayName

        trailingActionBar {
            numberOfSlots: 2
            actions: [
            Action {
                iconName: "message-new"
                text: i18n.tr("Join this chat")
                onTriggered: {
                    var success_callback = function () { membership = "join" }
                    matrix.post("/client/r0/join/" + encodeURIComponent(activeChat), null, success_callback)
                }
                visible: membership !== "join"
            },
            Action {
                iconName: "delete"
                text: i18n.tr("Leave chat")
                onTriggered: matrix.post("/client/r0/rooms/" + activeChat + "/leave", null, mainStack.toStart)
                visible: membership in ["join","invite"]
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
            }
            Avatar {  // Useravatar
                id: avatarImage
                source: "../../assets/background.svg"
                width: parent.width / 2
                radius: 100
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Rectangle {
                width: parent.width
                height: units.gu(2)
            }
            Label {
                id: userInfo
                height: units.gu(2)
                anchors.left: parent.left
                anchors.leftMargin: units.gu(2)
                text: i18n.tr("Users in this chat:")
                font.bold: true
            }

            Column {
                id: memberList
                width: parent.width
            }

        }
    }
}
