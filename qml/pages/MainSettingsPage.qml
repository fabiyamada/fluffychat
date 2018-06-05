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
                if ( pusher.pushkey === pushtoken ) {
                    issettoken = true
                    break;
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
                onTriggered: events.restartSync()
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

    /*Component {
        id: dialog

        Dialog {
            id: dialogue
            title: i18n.tr("Change nickname")
            TextField {
                id: displaynameTextField
                placeholderText: i18n.tr("Enter your new nickname")
                Component.onCompleted: {
                    storage.transaction ( "SELECT displayname FROM Roommembers WHERE state_key='%1'".arg(matrix.matrixid), function ( res ) {
                        if ( res.rows.length > 1 ) {
                            displaynameTextField.text = res.rows[0].displayname
                        }
                    })
                }
            }
            Row {
                width: parent.width
                spacing: units.gu(1)
                Button {
                    width: (parent.width - units.gu(1)) / 2
                    text: i18n.tr("Cancel")
                    onClicked: PopupUtils.close(dialogue)
                }
                Button {
                    width: (parent.width - units.gu(1)) / 2
                    text: i18n.tr("Save")
                    color: UbuntuColors.green
                    onClicked: {
                        matrix.put ( "/client/r0/profile/%1/displayname".arg(matrix.matrixid),
                        { displayname: displaynameTextField.displayText} )
                        PopupUtils.close(dialogue)
                    }
                }
            }
        }
    }*/

}
