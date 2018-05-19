import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Rectangle {
    property var event
    property var sent: event.sender.toLowerCase() === matrix.matrixid.toLowerCase()

    width: root.width
    height: messageBubble.height + units.gu(1)
    color: "transparent"

    Avatar {
        id: avatar
        name: "contact"
        mxc: event.avatar_url
        anchors.left: sent ? undefined : parent.left
        anchors.right: sent ? parent.right : undefined
        anchors.top: parent.top
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)

        //Component.onCompleted: if ( event.avatar_url ) source = event.avatar_url
    }

    Rectangle {
        id: messageBubble
        z: 2
        anchors.left: sent ? undefined : avatar.right
        anchors.right: sent ? avatar.left : undefined
        anchors.top: parent.top
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)
        border.width: 1
        border.color: UbuntuColors.silk
        anchors.margins: 5
        color: sent ? "#FFFFFF" : "#5625BA"
        radius: 50
        height: messageLabel.height + metaLabel.height + units.gu(2)
        width: Math.max( messageLabel.width, metaLabel.width ) + units.gu(2)

        Text {
            id: messageLabel
            text: event.content_body
            color: sent ? "black" : "white"
            wrapMode: Text.Wrap
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: units.gu(1)
            Component.onCompleted: {
                var maxWidth = root.width - avatar.width - units.gu(8)
                if ( width > maxWidth ) width = maxWidth
            }
        }
        Label {
            id: metaLabel
            text: (event.displayname || event.sender) + " " + stamp.getChatTime ( event.origin_server_ts )
            anchors.top: messageLabel.bottom
            anchors.left: parent.left
            anchors.leftMargin: units.gu(1)
            color: UbuntuColors.silk
            textSize: Label.Small
        }
    }


}
