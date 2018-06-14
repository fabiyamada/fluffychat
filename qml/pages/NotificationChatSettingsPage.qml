import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

Page {
    anchors.fill: parent


    function setPushRule ( action ) {
        matrix.put ( "/client/r0/pushrules/global/room/%1".arg(activeChat), {"actions": [ action ] }, update )
    }


    function update () {
        scrollView.opacity = 0.5
        matrix.get ( "/client/r0/pushrules/global/room/%1".arg(activeChat), null, function ( response ) {
            scrollView.opacity = 1
            notify.visible = response.actions.indexOf("notify") !== -1
            dont_notify.visible = response.actions.indexOf("dont_notify") !== -1
        }, function ( error ) {
            scrollView.opacity = 1
            if ( error.errcode === "M_NOT_FOUND" ) {
                notify.visible = true
            }
        } )
    }

    header: FcPageHeader {
        title: i18n.tr('Notifications')
    }

    Component.onCompleted: update ()

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: root.width
            SettingsListItem {
                name: i18n.tr("Notify")
                Icon {
                    id: "notify"
                    visible: false
                    name: "toolkit_tick"
                    width: units.gu(3)
                    height: width
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }
                icon: "audio-volume-high"
                onClicked: setPushRule ( "notify" )
            }
            SettingsListItem {
                name: i18n.tr("Don't notify")
                Icon {
                    id: "dont_notify"
                    visible: false
                    name: "toolkit_tick"
                    width: units.gu(3)
                    height: width
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                }
                icon: "audio-volume-muted"
                onClicked: setPushRule ( "dont_notify" )
            }

        }
    }
}
