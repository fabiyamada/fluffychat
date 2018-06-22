import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0
import Fluffychat 1.0


Rectangle {
    id: avatarRect
    // rounded corners for img
    width: units.gu(6)
    height: width
    color: settings.darkmode ? UbuntuColors.jet : UbuntuColors.porcelain
    border.width: 1
    border.color: settings.darkmode ? UbuntuColors.slate : UbuntuColors.silk
    radius: units.gu(1)
    z:1
    clip: true

    //property alias name: avatar.name
    property alias source: avatar.source
    property var mxc: null
    property var onClickFunction: null
    property var name


    MouseArea {
        anchors.fill: parent
        onClicked: onClickFunction !== null ? onClickFunction () : undefined
    }


    Image {
        id: avatar
        source:  mxc !== null && mxc !== "" ? media.getThumbnailLinkFromMxc ( mxc, width, height ) : "../../assets/contact.svg"
        anchors.fill: parent
        cache: true
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }
        visible: status == Image.Ready
    }


    Image {
        id: tempAvatar
        visible: !avatar.visible
        source: "../../assets/contact.svg"
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }
    }


    Rectangle {
        id: mask
        anchors.fill: parent
        radius: parent.radius
        visible: false
    }

}
