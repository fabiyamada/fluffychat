import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

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
                name: i18n.tr("About FluffyChat")
                icon: "info"
                onClicked: mainStack.push(Qt.resolvedUrl("../pages/InfoPage.qml"))
            }

            SettingsListItem {
                name: i18n.tr("Logout")
                icon: "close"
                onClicked: {
                    var callback = function () {
                        mainStack.clear ()
                        mainStack.push(Qt.resolvedUrl("../pages/LoginPage.qml"))
                    }
                    matrix.logout ( callback, callback )
                }
            }

        }
    }


    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Set status")
            TextField {
                placeholderText: i18n.tr("Enter your status")
            }
            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }
            Button {
                text: i18n.tr("Save")
                color: UbuntuColors.orange
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

}
