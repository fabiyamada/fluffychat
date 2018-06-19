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
                onTriggered: {
                    matrix.get("/client/r0/presence/list/%1".arg(matrix.matrixid), null, function (m) { console.log(JSON.stringify(m))})
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
                name: i18n.tr("Notifications")
                icon: "notification"
                onClicked: mainStack.push(Qt.resolvedUrl("../pages/NotificationSettingsPage.qml"))
            }

            SettingsListItem {
                name: i18n.tr("Account")
                icon: "account"
                onClicked: mainStack.push(Qt.resolvedUrl("../pages/AccountSettingsPage.qml"))
            }

            SettingsListItem {
                name: i18n.tr("Theme")
                icon: "image-x-generic-symbolic"
                onClicked: mainStack.push(Qt.resolvedUrl("../pages/ThemeSettingsPage.qml"))
            }

            SettingsListItem {
                name: i18n.tr("About FluffyChat")
                icon: "info"
                onClicked: mainStack.push(Qt.resolvedUrl("../pages/InfoPage.qml"))
            }

        }
    }

}
