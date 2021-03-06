import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Component {
    id: dialog

    Dialog {
        id: dialogue
        title: i18n.tr("New single chat")
        Icon {
            name: "message-new"
            width: parent.width
            height: width
        }
        TextField {
            id: contactTextField
            text: newContactMatrixID || ""
            placeholderText: i18n.tr("@yourfriend:" + settings.server)
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
                text: i18n.tr("Continue")
                enabled: contactTextField.displayText !== ""
                color: UbuntuColors.green
                onClicked: {

                    events.waitForSync ()
                    var data = {
                        "invite": [ contactTextField.displayText ],
                        "is_direct": true,
                        "preset": "private_chat"
                    }
                    if ( success_callback === undefined ) var success_callback = startChat_callback || null
                    matrix.post( "/client/r0/createRoom", data, success_callback )

                    PopupUtils.close(dialogue)
                }
            }
        }
    }
}
