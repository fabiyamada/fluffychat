import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0


Rectangle {
    // rounded corners for img
    width: units.gu(6)
    height: width
    color: "transparent"
    border.width: 1
    border.color: UbuntuColors.silk
    radius: 20
    z:1

    property alias name: avatar.name
    property alias source: avatar.source
    property var mxc: null

    Icon {
        id: avatar
        name: "contact"
        anchors.fill: parent
    }

    Component.onCompleted: {
        // Download the icon:
        if ( false && mxc !== null ) {
            var mxcID = mxc.replace("mxc://","")
            matrix.get ( "/media/r0/download/" + mxcID, null, function (blob){
                avatar.source = "image://" + blob
            } )
        }
    }


}
