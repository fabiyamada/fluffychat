import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("Change your password")
        Icon {
            name: "lock"
            width: parent.width
            height: width
        }
        TextField {
            id: newPass
            placeholderText: i18n.tr("Enter your new password")
        }
        TextField {
            id: newPass2
            placeholderText: i18n.tr("Please repeat")
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
                text: i18n.tr("Change")
                color: UbuntuColors.green
                onClicked: {
                    if ( newPass.displayText !== newPass2.displayText ) {
                        toast.show ( i18n.tr("The passwords do not match") )
                    }
                    else {
                        matrix.post ( "/client/r0/account/password",
                        { new_password: newPass.displayText} )
                        PopupUtils.close(dialogue)
                    }
                }
            }
        }
    }
}
