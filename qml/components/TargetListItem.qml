import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"

ListItem {
    id: deviceListItem
    height: layout.height

    property var target

    onClicked: {
        currentTarget = target
        PopupUtils.open(targetInfoDialog)
    }

    ListItemLayout {
        id: layout
        width: parent.width
        title.text: target.device_display_name || device.device_id
        subtitle.text: target.app_display_name
        Icon {
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
            name: "phone-smartphone-symbolic"
        }
    }


}
