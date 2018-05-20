import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

ScrollView {

    id: chatScrollView

    // If this property is not 1, then the user is not in the chat, but is reading the history
    property var historyPosition: 0
    property var historyCount: 50
    property var updated: false
    property var enteredMinusConent: false
    property var count: messagesList.children.length

    function update () {
        storage.transaction ( "SELECT events.id, events.type, events.content_json, events.content_body, events.origin_server_ts, events.sender, members.displayname, members.avatar_url " +
        " FROM Roomevents events LEFT JOIN Roommembers members " +
        " WHERE events.roomsid='" + activeChat +
        "' AND members.roomsid=events.roomsid " +
        " AND members.state_key=events.sender " +
        " AND events.type IN ('m.room.member','m.room.message','m.room.invite') " +
        " ORDER BY events.origin_server_ts DESC" +
        " LIMIT " + (historyCount+1) + " OFFSET " + (historyCount*historyPosition) + " "
        , function (res) {
            // We now write the rooms in the column
            if ( historyPosition > 0 && res.rows.length === 0 ) {
                historyPosition--
                requestHistory ()
            }
            else {
                "Go to next page"
                messagesList.children = ""
                for ( var i = res.rows.length-1; i >= 0; i-- ) {
                    var event = res.rows.item(i)
                    addEventToList ( event )
                }
                updated = true
            }
        })
    }


    function requestHistory () {
        storage.transaction ( "SELECT prev_batch FROM Rooms WHERE id='" + activeChat + "'", function (rs) {
            var data = {
                from: rs.rows[0].prev_batch,
                dir: "b",
                limit: historyCount
            }
            matrix.get( "/client/r0/rooms/" + activeChat + "/messages", data, function ( result ) {
                if ( result.chunk.length > 0 ) {
                    events.handleJoinedRoomTimelineEvents( activeChat, result.chunk, false )
                    storage.transaction ( "UPDATE Rooms SET prev_batch='" + result.end + "' WHERE id='" + activeChat + "'", function () {
                        if ( historyPosition > 0 ) historyPosition++
                        update ()
                    })
                }
                else updated = true
            }, function () { updated = true } )
        } )
    }


    // This function writes the event in the chat. The event MUST have the format
    // of a database entry, described in the storage controller
    function addEventToList ( event ) {
        if ( event.type === "m.room.message" ) {
            var newMessageListItem = Qt.createComponent("../components/Message.qml")
            newMessageListItem.createObject(messagesList, { "event": event })
        }
        else {
            var newMessageListItem = Qt.createComponent("../components/Event.qml")
            newMessageListItem.createObject(messagesList, { "event": event })
        }
    }


    // This function handles new events, based on the signal from the event
    // controller. It just has to format the event to the database format
    function handleNewEvent ( event ) {
        if ( historyPosition === 0 ) update ()
        else toast.show (i18n.tr("New message at the bottom of the chat"))
    }


    width: parent.width
    height: parent.height - 2*header.height
    anchors.bottom: chatInput.top
    flickableItem.contentY: flickableItem.contentHeight>height ? flickableItem.contentHeight - height : 0
    flickableItem {
        onContentYChanged: {
            if ( !enteredMinusConent && updated && flickableItem.contentY < -50 ) {
                console.log("Scrolling up")
                updated = false
                enteredMinusConent = true
                historyPosition++
                update ()
            }
            else if ( flickableItem.contentY > flickableItem.contentHeight-height+50 ) {
                console.log("Scrolling down")
                if ( historyPosition > 0 ) {
                    updated = false
                    enteredMinusConent = true
                    historyPosition--
                    update ()
                }
            }
            else if ( flickableItem.contentY >= 0 ||
                flickableItem.contentY <= flickableItem.contentHeight-height ){
                    enteredMinusConent = false
                }
        }
    }

    contentItem: Column {
        id: messagesList
        width: root.width
        anchors.top: parent.top
    }
}
