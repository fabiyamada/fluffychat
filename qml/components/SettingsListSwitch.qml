import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3

ListItem {
    property var name: ""
    property var icon: "settings"
    property var isChecked: true
    property var isEnabled: false
    property var onSwitching
    height: layout.height

    ListItemLayout {
        id: layout
        title.text: name
        Icon {
            name: icon
            width: units.gu(4)
            height: units.gu(4)
            SlotsLayout.position: SlotsLayout.Leading
        }

        Switch {
            id: switcher
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: units.gu(2)
            checked: isChecked
            enabled: isEnabled
            onCheckedChanged: onSwitching ()
        }
    }
    onClicked: switcher.checked ? switcher.checked = false : switcher.checked = true
}
