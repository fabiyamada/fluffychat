import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import "../components"

ListItem {
    property var name: ""
    height: layout.height

    ListItemLayout {
        id: layout
        title.text: name
        Avatar {
            SlotsLayout.position: SlotsLayout.Leading
        }
    }
}
