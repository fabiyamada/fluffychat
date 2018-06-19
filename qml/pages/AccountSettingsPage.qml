import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

Page {
    anchors.fill: parent

    header: FcPageHeader {
        title: i18n.tr('Account')
    }

    ScrollView {
        id: scrollView
        width: parent.width
        height: parent.height - header.height
        anchors.top: header.bottom
        contentItem: Column {
            width: root.width

            SettingsListItem {
                name: i18n.tr("Change nickname")
                icon: "edit"
                onClicked: PopupUtils.open(dialog)
            }

            SettingsListItem {
                name: i18n.tr("Change password")
                icon: "lock"
                //onClicked: PopupUtils.open(dialog)
            }

            SettingsListItem {
                name: i18n.tr("Disable Account")
                icon: "edit-delete"
                //onClicked: PopupUtils.open(dialog)
            }

            SettingsListItem {
                name: i18n.tr("Logout")
                icon: "erase"
                onClicked: matrix.logout ()
            }
        }
    }

    ChangeDisplaynameDialog { id: dialog }
}
