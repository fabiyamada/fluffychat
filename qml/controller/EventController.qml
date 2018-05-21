import QtQuick 2.4
import Ubuntu.Components 1.3


/* =============================== EVENT CONTROLLER ===============================

The event controller is responsible for handling all events and stay connected
with the matrix homeserver via a long polling http request
*/
Item {

    signal chatListUpdated
    signal chatStateEvent ( var chat, var event )
    signal chatTimelineEvent ( var chat, var event )
    signal chatNotificationEvent ( var chat, var event )

    property var syncRequest: null
    property var since: ""
    property var initialized: false

    function init () {
        storage.getConfig("next_batch", function( res ) {
            since = res
            initialized = true
            if ( since != null ) return sync ()
            matrix.get ("/client/r0/sync", null,function ( response ) {
                if ( waitingForSync ) progressBarRequests--
                matrix.onlineStatus = true
                handleEvents ( response )
                sync ()
            }, null, null, longPollingTimeout )
        })
    }

    function sync () {
        if (matrix.token === null || matrix.token === undefined) return
        var timeout = defaultTimeout
        if ( matrix.onlineStatus ) timeout = longPollingTimeout
        syncRequest = matrix.get ("/client/r0/sync", { "since": since, "timeout": timeout }, function ( response ) {
            if ( waitingForSync ) progressBarRequests--
            if ( matrix.token ) {
                matrix.onlineStatus = true
                handleEvents ( response )
                sync ()
            }
        }, function ( error ) {
            if ( matrix.token ) {
                matrix.onlineStatus = false
                console.log ( "You are offline!! Try to reconnect in a few seconds!" )
                if ( error.errcode === "M_INVALID" ) {
                    mainStack.clear ()
                    mainStack.push(Qt.resolvedUrl("../pages/LoginPage.qml"))
                }
                else {
                    if ( matrix.onlineStatus ) return
                    function Timer() {
                        return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root);
                    }
                    var timer = new Timer();
                    timer.interval = defaultTimeout;
                    timer.repeat = false;
                    timer.triggered.connect(sync)
                    timer.start();
                }
            }
        });
    }


    function restartSync () {
        syncRequest.abort ()
    }


    function waitForSync () {
        if ( waitingForSync ) return
        waitingForSync = true
        progressBarRequests++
    }


    function stopWaitForSync () {
        if ( !waitingForSync ) return
        waitingForSync = false
        progressBarRequests--
    }


    // This function starts handling the events, saving new data in the storage,
    // deleting data, updating data and call signals
    function handleEvents ( response ) {
        console.log ( "===============New events========", JSON.stringify ( response ) )
        var changed = false
        try {
            handleRooms ( response.rooms.join, "join" )
            handleRooms ( response.rooms.leave, "leave" )
            handleRooms ( response.rooms.invite, "invite" )
            since = response.next_batch
            storage.setConfig ( "next_batch", since )
        }
        catch ( e ) { console.log ( e ) }
        chatListUpdated ()
    }


    // Handling the synchronization events starts with the rooms
    function handleRooms ( rooms, membership ) {
        for ( var id in rooms ) {
            var room = rooms[id]

            storage.query ("INSERT OR REPLACE INTO Rooms VALUES(?, ?, COALESCE((SELECT topic FROM Rooms WHERE id='" + id + "'), ''), ?, ?, ?, COALESCE((SELECT prev_batch FROM Rooms WHERE id='" + id + "'), ''))",
            [ id,
            membership,
            (room.unread_notifications ? room.unread_notifications.highlight_count : 0),
            (room.unread_notifications ? room.unread_notifications.notification_count : 0),
            (room.timeline ? (room.timeline.limited ? 1 : 0) : 0) ])

            if ( room.state ) handleRoomEvents ( id, room.state.events, "state" )
            if ( room.invite_state ) handleRoomEvents ( id, room.invite_state.events, "invite_state" )
            if ( room.timeline ) handleRoomEvents ( id, room.timeline.events, "timeline" )
        }
    }


    // Events are all changes in a room
    function handleRoomEvents ( roomid, events, type ) {
        // We go through the events array
        for ( var i = 0; i < events.length; i++ ) {
            var event = events[i]

            // messages from the timeline will be saved, for display in the chat.
            // Only this events will call the notification signal or change the
            // current displayed chat!
            if ( type === "timeline" || type === "history" ) {
                storage.query ( "INSERT OR IGNORE INTO Roomevents VALUES(?, ?, ?, ?, ?, ?, ?, ?)",
                [ event.event_id,
                roomid,
                event.origin_server_ts,
                event.sender,
                event.content.body || null,
                event.content.msgtype || null,
                event.type,
                JSON.stringify(event.content) ])
                if ( type === "timeline" && roomid === activeChat ) chatTimelineEvent ( roomid, event )
                else if ( type === "timeline" ) chatNotificationEvent ( roomid, event )
            }

            // This event means, that the topic of a room has been changed, so
            // it has to be changed in the database
            if ( event.type === "m.room.name" ) {
                storage.query( "UPDATE Rooms SET topic=? WHERE id=?",
                [ event.content.name,
                roomid ])
                // If the affected room is the currently used room, then the
                // name has to be updated in the GUI:
                if ( activeChat === roomid ) {
                    roomnames.getById ( roomid, function ( displayname ) {
                        activeChatDisplayName = displayname
                    })
                }
            }

            // This event means, that someone joined the room, has left the room
            // or has changed his nickname
            else if ( event.type === "m.room.member") {
                storage.query( "INSERT OR REPLACE INTO Roommembers VALUES(?, ?, ?, ?, ?)",
                [ roomid,
                event.state_key,
                event.content.membership,
                event.content.displayname,
                event.content.avatar_url ])
            }
        }
    }
}
