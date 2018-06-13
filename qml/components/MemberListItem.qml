import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

ListItem {
    property var name: ""
    property var membership: ""
    property var avatar_url: null
    property var id: ""
    height: layout.height

    Component.onCompleted: {
        if ( membership === "join" ) layout.subtitle.text = i18n.tr("Member")
        else if ( membership === "invite" ) layout.subtitle.text = i18n.tr("Was invited")
        else if ( membership === "leave" ) layout.subtitle.text = i18n.tr("Has left the chat")
        else if ( membership === "knock" ) layout.subtitle.text = i18n.tr("Has knocked")
        else if ( membership === "ban" ) layout.subtitle.text = i18n.tr("Was banned from the chat")
    }

    onClicked: {
        newContactMatrixID = id
        PopupUtils.open( newContactDialog )
    }

    opacity: membership === "leave" ? 0.5 : 1

    ListItemLayout {
        id: layout
        title.text: name
        subtitle.text: membership
        Avatar {
            SlotsLayout.position: SlotsLayout.Leading
            mxc: avatar_url
        }
    }
}
