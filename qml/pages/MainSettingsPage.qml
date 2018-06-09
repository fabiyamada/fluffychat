import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent


    function getPushers () {
        matrix.get("/client/r0/pushers", null, function ( res ) {
            var issettoken = false
            for( var i = 0; i < res.pushers.length; i++ ) {
                var pusher = res.pushers[i]
                    console.log(JSON.stringify(pusher))
                if ( pusher.pushkey === pushtoken ) {
                    issettoken = true
                    //break
                }
            }
            switchPush.checked = issettoken
            switchPush.enabled = true
        },console.warn)
    }

    header: FcPageHeader {
        title: i18n.tr('Settings')

        trailingActionBar {
            actions: [
            Action {
                iconSource: matrix.onlineStatus ? "../../assets/online.svg" : "../../assets/offline.svg"
                onTriggered: {
                    for ( var c in pushclient ) console.log(c + ": (" + typeof pushclient[c] + ") " + pushclient[c])
                    //var notifies = pushclient.getNotifications()
                    //console.log( notifies, JSON.stringify(notifies))
                    //events.restartSync()
                }
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
            width: root.width

            SettingsListItem {
                name: i18n.tr("Notifications (Beta)")
                icon: "notification"
                Switch {
                    id: switchPush
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(2)
                    checked: true
                    onCheckedChanged: {
                        if ( enabled ) {
                            enabled = false
                            pushclient.setPusher ( checked, getPushers, function ( error ) {
                                if ( error.errcode === "NO_UBUNTUONE" ) toast.show ( error.error )
                                else toast.show ( error.errcode + ": " + error.error )
                                checked = !checked
                                enabled = true
                            })
                        }
                    }
                    enabled: false
                    Component.onCompleted: getPushers ()
                }
                onClicked: switchPush.checked ? switchPush.checked = false : switchPush.checked = true
            }

            SettingsListItem {
                name: i18n.tr("Change nickname")
                icon: "account"
                onClicked: PopupUtils.open(dialog)
            }

            SettingsListItem {
                name: i18n.tr("About FluffyChat")
                icon: "info"
                onClicked: mainStack.push(Qt.resolvedUrl("../pages/InfoPage.qml"))
            }

            SettingsListItem {
                name: i18n.tr("Logout")
                icon: "close"
                onClicked: matrix.logout ()
            }
        }
    }


    ChangeDisplaynameDialog { id: dialog }

}
