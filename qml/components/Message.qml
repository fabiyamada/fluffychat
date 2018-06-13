import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Rectangle {
    id: message
    property var event
    property var sending: event.sending || false
    property var sent: event.sender.toLowerCase() === matrix.matrixid.toLowerCase()

    width: root.width
    height: messageBubble.height + units.gu(1)
    color: "transparent"
    opacity: sending ? 0.5 : 1


    // When the width of the "window" changes (rotation for example) then the maxWidth
    // of the message label must be calculated new. There is currently no "maxwidth"
    // property in qml.
    onWidthChanged: {
        messageLabel.width = undefined
        var maxWidth = width - avatar.width - units.gu(5)
        if ( messageLabel.width > maxWidth ) messageLabel.width = maxWidth
        else messageLabel.width = undefined
    }


    // When there something changes inside this message component, then this function
    // must be triggered.
    function update () {
        metaLabel.text = (event.displayname || event.sender) + " " + stamp.getChatTime ( event.origin_server_ts )
        avatar.mxc = event.avatar_url
    }

    Avatar {
        id: avatar
        mxc: event.avatar_url
        anchors.left: sent ? undefined : parent.left
        anchors.right: sent ? parent.right : undefined
        anchors.top: parent.top
        anchors.leftMargin: units.gu(1)
        anchors.rightMargin: units.gu(1)
        opacity: event.sameSender ? 0 : 1
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
        color: sent ? "#FFFFFF" : mainColor
        radius: units.gu(2)
        height: messageLabel.height + metaLabel.height + thumbnail.height + units.gu(2)
        width: Math.max( messageLabel.width + units.gu(2), (metaLabel.width + (event.sending ? units.gu(2) : 0)) + units.gu(2), thumbnail.width )

        MouseArea {
            width: thumbnail.width
            height: thumbnail.height
            Image {
                id: thumbnail
                visible: event.content.msgtype === "m.image"
                width: visible ? Math.max( units.gu(24), messageLabel.width + units.gu(2) ) : 0
                //height: width
                source: event.content.url ? media.getThumbnailLinkFromMxc ( event.content.url, width, width ) : ""
                anchors.top: parent.top
                anchors.left: parent.left
                //anchors.margins: units.gu(1)
                fillMode: Image.PreserveAspectCrop
                onStatusChanged: {
                    if ( status === Image.Error ) {
                        source = "../../assets/network-cellular-none.svg"
                    }
                }
            }
            onClicked: Qt.openUrlExternally(matrix.getImageLinkFromMxc ( event.content.url ) )
        }


        Button {
            id: downloadButton
            text: i18n.tr("Download")
            onClicked: Qt.openUrlExternally(matrix.getImageLinkFromMxc ( event.content.url ) )
            visible: [ "m.file", "m.audio", "m.video" ].indexOf( event.content.msgtype ) !== -1
            height: visible ? units.gu(4) : 0
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: units.gu(1)
        }


        // In this label, the body of the matrix message is displayed. This label
        // is main responsible for the width of the message bubble.
        Text {
            id: messageLabel
            text: event.content_body
            color: sent ? "black" : "white"
            wrapMode: Text.Wrap
            anchors.bottom: metaLabel.top
            anchors.left: parent.left
            anchors.topMargin: units.gu(1)
            anchors.leftMargin: units.gu(1)
            onLinkActivated: Qt.openUrlExternally(link)
            // Intital calculation of the max width and display URL's
            Component.onCompleted: {
                console.log(event.content.msgtype)
                var maxWidth = message.width - avatar.width - units.gu(5)
                if ( width > maxWidth ) width = maxWidth
                var urlRegex = /(https?:\/\/[^\s]+)/g;
                text = text.replace(urlRegex, function(url) {
                    return '<a href="%1"><font color="%2">%1</font></a>'.arg(url).arg(messageLabel.color)
                })
            }
        }


        // This label is for the meta-informations, which means it displays the
        // display name of the sender of this message and the time.
        Label {
            id: metaLabel
            text: (event.displayname || event.sender) + " " + stamp.getChatTime ( event.origin_server_ts )
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: units.gu(1)
            color: UbuntuColors.silk
            textSize: Label.Small
        }
        // When the message is just sending, then this activity indicator is visible
        ActivityIndicator {
            id: activity
            visible: sending
            running: visible
            anchors.left: metaLabel.right
            anchors.top: messageLabel.bottom
            anchors.leftMargin: units.gu(0.5)
            width: units.gu(1.5)
            height: width
        }

    }


}
