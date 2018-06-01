# FluffyChat

Minimalistic Messenger for Ubuntu Touch, based on matrix.org.
FluffyChat is very early progress and still under development. Please report all bugs and help me, to make this project more complete!

Planned features for the far future:
 * All common matrix.org features
 * Push Notifications
 * Find friends by phone number, using vector.im

Download from the Open Store: https://open-store.io/app/fluffychat.christianpauly

Chatroom for FluffyChat: #fluffychat:matrix.org

### How to build

1. Install clickable as described here: https://github.com/bhdouglass/clickable

2. Clone this repo:
```
git clone https://github.com/ChristianPauly/fluffychat
cd fluffychat
```

3. Build with clickable
```
clickable click-build
```
### How Push Notifications are working

The notifications are sent from the matrix homeserver to the fluffychat push-gateway at: https://github.com/ChristianPauly/fluffychat-push-gateway
This gateway just beams the push to https://push.ubports.com/notify via https. The push-gateway is currently on my own server! I am NOT saving any data! It is just forwarding! However you can just host your own gateway if you want. There is currently no end-to-end encryption in fluffychat so you should not send any message-content from your homeserver, if you don't trust fluffychat or ubports!
