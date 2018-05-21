import QtQuick 2.4
import Ubuntu.Components 1.3

/*============================= STORAGE CONTROLLER =============================

This is a little helper controller to get a display text from a room event, which
is NOT a message. Currently, only invitations, create and member changes are displayed.
*/

Item {
    function getDisplay ( event ) {
        event.content = JSON.parse (event.content_json)
        var body = i18n.tr("Unknown Event: ") + event.type
        var displayname =  event.content.displayname || event.displayname || event.sender || i18n.tr("Someone")
        if ( event.type === "m.room.member" ) {
            if ( event.content.membership === "join" ) {
                body = displayname + i18n.tr(" has entered the chat")
            }
            else if ( event.content.membership === "invite" ) {
                body = displayname + i18n.tr(" has invited ") + event.sender
            }
            else if ( event.content.membership === "leave" ) {
                body = displayname + i18n.tr(" has left the chat")
            }
            else if ( event.content.membership === "ban" ) {
                body = displayname + i18n.tr(" has been banned from the chat")
            }
        }
        else if ( event.type === "m.room.create" ) {
            body = i18n.tr("The chat has been created")
        }
        else if ( event.type === "m.room.name" ) {
            body = displayname + i18n.tr(" has changed the chat name")
        }
        else if ( event.type === "m.room.topic" ) {
            body = displayname + i18n.tr(" has changed the chat topic")
        }
        else if ( event.type === "m.room.history_visibility" ) {
            body = displayname + i18n.tr(" has set the chat history visible to: ")
            if ( event.content.history_visibility === "shared" ) {
                body += i18n.tr("All chat participants")
            }
            else if ( event.content.history_visibility === "joined" ) {
                body += i18n.tr("All joined chat participants")
            }
            else if ( event.content.history_visibility === "invited" ) {
                body += i18n.tr("All invited chat participants")
            }
            else if ( event.content.history_visibility === "world_readable" ) {
                body += i18n.tr("Everyone")
            }
        }
        else if ( event.type === "m.room.join_rules" ) {
            body = displayname + i18n.tr(" has set the join rules to: ")
            if ( event.content.join_rule === "invite" ) {
                body += i18n.tr("Only invited users")
            }
            else if ( event.content.join_rule === "public" ) {
                body += i18n.tr("Public")
            }
            else if ( event.content.join_rule === "private" ) {
                body += i18n.tr("Private")
            }
            else if ( event.content.join_rule === "knock" ) {
                body += i18n.tr("Knock")
            }
        }
        else if ( event.type === "m.room.guest_access" ) {
            body = displayname + i18n.tr(" has set the guest access to: ")
            if ( event.content.guest_access === "can_join" ) {
                body += i18n.tr("Can join")
            }
            else if ( event.content.guest_access === "forbidden" ) {
                body += i18n.tr("Forbidden")
            }
        }
        else if ( event.type === "m.room.aliases" ) {
            body = i18n.tr("The chat aliases have been changed to: ")
            for ( var i = 0; i < event.content.aliases; i++ ) {
                body += event.content.aliases[i] + " "
            }
        }
        else if ( event.type === "m.room.canonical_alias" ) {
            body = i18n.tr("The canonical chat alias has been changed to: ") + event.content.alias
        }
        else if ( event.type === "m.room.power_levels" ) {
            body = i18n.tr("The chat permissions have been changed")
        }
        body += "."
        return body
    }
}
