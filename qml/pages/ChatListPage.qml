import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent
    id: chatListPage


    // This is the most importent function of this page! It updates all rooms, based
    // on the informations in the sqlite database!
    Component.onCompleted: {

        // First step is obviously clearing the column
        chatListColumn.children = ""

        // On the top are the rooms, which the user is invited to
        storage.transaction ("SELECT rooms.id, rooms.topic, rooms.membership, rooms.notification_count, " +
        " events.id AS eventsid, ifnull(events.origin_server_ts, DateTime('now')) AS origin_server_ts, events.content_body, events.sender, events.content_json, events.type " +
        " FROM Rooms rooms LEFT JOIN Roomevents events " +
        " ON rooms.id=events.roomsid " +
        " WHERE rooms.membership!='leave' " +
        " AND (events.origin_server_ts IN (" +
        " SELECT MAX(origin_server_ts) FROM Roomevents WHERE roomsid=rooms.id " +
        ") OR rooms.membership='invite')" +
        " ORDER BY origin_server_ts DESC "
        , function(res) {
            // We now write the rooms in the column
            for ( var i = 0; i < res.rows.length; i++ ) {
                var room = res.rows.item(i)
                // We request the room name, before we continue
                var newChatListItem = Qt.createComponent("../components/ChatListItem.qml")
                newChatListItem.createObject(chatListColumn,{ "room": room,})
                if ( activeChat === room.id && room.notification_count > 0 ) matrix.post( "/client/r0/rooms/" + activeChat + "/receipt/m.read/" + room.eventsid, null )
            }
        })
    }


    /* When the app receives a new synchronization object, the chat list should be
     * updated, without loading it new from the database. There are several types
     * of changes:
     * - Join a new chat
     * - Invited to a chat
     * - Leave a chat
     * - New message in the last-message-field ( Which needs reordering the chats )
     * - Update the counter of unseen messages
    */
    function update ( sync ) {
        var items = chatListColumn.children

        // This helper function helps us to reduce code. Rooms with the type
        // "join" and "invite" are just handled the same, and "leave" is very
        // near to this
        for ( var type in sync.rooms ) {
            for ( var id in sync.rooms[type] ) {
                var room = sync.rooms[type][id]

                // Check if the user is already in this chat
                var roomExists = false
                for ( var j = 0; j < items.length; j++ ) {
                    if ( items[j].room.id === id ) {
                        roomExists = true
                        if ( type === "leave" ) items[j].destroy ()
                        break
                    }
                }

                // Nothing more to show for the type "leave"
                if ( type === "leave" ) return

                // Add the room to the list, if it does not exist
                if ( !roomExists ) {
                    var roomItem = {
                        "id": id,
                        "topic": "",
                        "membership": type
                    }
                    var newChatListItem = Qt.createComponent("../components/ChatListItem.qml")
                    newChatListItem.createObject(chatListColumn,{ "room": roomItem,})
                }

                // Update the type
                items[j].room.membership = type

                // Update the notification count
                items[j].room.notification_count = room.unread_notifications ? room.unread_notifications.notification_count : 0

                // Check the timeline events and add the latest event to the chat list
                // as the latest message of the chat
                if ( room.timeline.events.length > 0 ) {
                    var lastEvent = room.timeline.events[ room.timeline.events.length - 1 ]
                    items[j].room.eventsid = lastEvent.event_id
                    items[j].room.origin_server_ts = lastEvent.origin_server_ts
                    items[j].room.content_body = lastEvent.content.body || ""
                    items[j].room.sender = lastEvent.sender
                    items[j].room.content_json = JSON.stringify( lastEvent.content )
                    items[j].room.type = lastEvent.type
                    // Now reorder this item
                    while ( j > 0 && items[j].room.origin_server_ts > items[j-1].room.origin_server_ts ) {
                        console.log("move up")
                        var tempRoom = JSON.parse(JSON.stringify(items[j-1].room))
                        items[j-1].room = JSON.parse(JSON.stringify(items[j].room))
                        items[j].room = tempRoom
                        items[j].updateAll()
                        j--
                    }
                }
                items[j].updateAll()
            }
        }

        // Now we call the helper function with three different types:
    }


    Connections {
        target: events
        onChatListUpdated: update ( response )
    }


    header: FcPageHeader {
        trailingActionBar {
            actions: [
            Action {
                iconName: "settings"
                onTriggered: mainStack.push(Qt.resolvedUrl("./MainSettingsPage.qml"))
            },
            Action {
                iconName: "add"
                onTriggered: mainStack.push(Qt.resolvedUrl("./AddChatPage.qml"))
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
            id: chatListColumn
            width: root.width
        }
    }

    Label {
        text: i18n.tr('Swipe from the bottom to start a new chat')
        anchors.centerIn: parent
        visible: chatListColumn.children.length === 0
    }

    // ============================== BOTTOM EDGE ==============================
    BottomEdge {
        id: bottomEdge
        height: parent.height

        contentComponent: Rectangle {
            width: root.width
            height: root.height
            color: "white"
            AddChatPage { }
        }
    }

}
