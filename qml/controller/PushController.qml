import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.PushNotifications 0.1
import Qt.labs.settings 1.0

PushClient {
    id: pushClient

    Component.onCompleted: {
        notificationsChanged.connect(console.log)
        error.connect(console.warn)
    }

    function setPusher ( intent, callback, error_callback ) {
        var data = {
            "app_display_name": "FluffyChat",
            "app_id": appId,
            "append": true,
            "data": {
                "url": "https://janian.de:7000"
            },
            "device_display_name": "UbuntuPhone",
            "lang": "en",
            "kind": intent ? "http" : null,
            "profile_tag": "xxyyzz",
            "pushkey": pushtoken
        }
        matrix.post ( "/client/r0/pushers/set", data, callback, error_callback )
    }

    appId: "fluffychat.christianpauly_hello"

}
