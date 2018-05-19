import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import "../components"

ListItem {
    id: chatListItem

    property var room
    property var timeorder: 0

    height: layout.height

    onClicked: {
        activeChat = room.id
        mainStack.push (Qt.resolvedUrl("../pages/ChatPage.qml"))
    }

    ListItemLayout {
        id: layout
        width: parent.width - stampLabel.width
        title.text: i18n.tr("Unknown chat")
        title.font.bold: true
        subtitle.text: i18n.tr("No previous messages")
        Avatar {
            source: "../../assets/background.svg"
            SlotsLayout.position: SlotsLayout.Leading
        }
        Component.onCompleted: {
            // Get the room name
            roomnames.getById ( room.id, function (displayname) {
                var name = displayname
                if ( room.type === "invite" ) name = "+ " + displayname
                title.text = name
            })

            // Get the last message
            if ( room.type === "invite" ) {
                subtitle.text = i18n.tr("You have been invited to this chat")
            }
            else {
                storage.transaction ("SELECT * FROM Roomevents " +
                " WHERE roomsid='" + room.id + "' " +
                " AND type='m.room.message' " +
                " ORDER BY origin_server_ts DESC "
                , function (res) {
                    if ( res.rows.length > 0 ) {
                        var eventElem = res.rows[0]
                        var lastMessage = eventElem.content_body
                        if ( eventElem.sender === matrix.matrixid ) lastMessage = i18n.tr("You: ") + lastMessage
                        subtitle.text = lastMessage
                        stampLabel.text = stamp.getChatTime ( eventElem.origin_server_ts )
                        timeorder = eventElem.origin_server_ts
                    }
                })
            }
        }
    }


    Label {
        id: stampLabel
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: units.gu(2)
        text: ""
        textSize: Label.Small
        visible: text != ""
    }
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: units.gu(2)
        width: unreadLabel.width + units.gu(1)
        height: units.gu(2)
        color: UbuntuColors.purple
        radius: 90
        Label {
            id: unreadLabel
            anchors.centerIn: parent
            text: room.notification_count
            textSize: Label.Small
            color: UbuntuColors.porcelain
        }
        visible: room.notification_count != 0
    }
    // Delete Button
    leadingActions: ListItemActions {
        actions: [
        Action {
            iconName: "delete"
            onTriggered: {
                matrix.post("/client/r0/rooms/" + room.id + "/leave", null, function () {
                    chatListItem.destroy ()
                })
            }
        },
        Action {
            iconName: "info"
            onTriggered: {
                activeChat = room.id
                mainStack.push (Qt.resolvedUrl("../pages/ChatSettingsPage.qml"))
            }
        }
        ]
    }
}
