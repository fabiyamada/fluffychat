import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.PushNotifications 0.1

PushClient {
    id: pushClient

    Component.onCompleted: {
        notificationsChanged.connect(console.log)
        error.connect(console.warn)
    }

    function setPusher ( intent, callback, error_callback ) {
        var data = {
            "app_display_name": "FluffyChat",
            "app_id": "fluffychat.christianpauly_fluffychat",
            "append": false,
            "data": {
                "url": "http://janian.de:7000"
            },
            "device_display_name": "UbuntuPhone",
            "lang": "en",
            "kind": intent ? "http" : null,
            "profile_tag": "xxyyzz",
            "pushkey": pushtoken
        }
        matrix.post ( "/client/r0/pushers/set", data, callback, error_callback )
    }

    appId: 'fluffychat.christianpauly_fluffychat'

}
