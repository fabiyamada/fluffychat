# FluffyChat

Minimalistic Messenger for Ubuntu Touch, based on matrix.org.
FluffyChat is very early progress and still under development. Please report all bugs and help me, to make this project more complete!

Planned features for the far future:
 * All common matrix.org features
 * Push Notifications
 * Find friends by phone number, using vector.im

Download from the Open Store: https://open-store.io/app/fluffychat.christianpauly

Chatroom for FluffyChat: #fluffychat:matrix.org

Follow me on Mastodon: https://metalhead.club/@krille

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
### FAQ

#### Why are you not just contributing to uMatriks?
Because I first tried to build a XMPP Messenger in pure qml. But the stream management looks like rocket science. So, just for fun,
I have implemented some matrix api calls in the same user interface and only a few minutes later I have got a working matrix client.
uMatriks is great and I would like to work with the developers together, so that we can benefit from each other. But I don't like C++
and FluffyChat does'nt use any libraries. It is still pure qml and that's fine. Also I have my vision of a user interface, which I want
to implement, which looks more like common messengers (Telegram, whatsapp etc.) and not like a collaborative plattform like Riot and uMatriks. Because it is pure qml, it should also possible to bring FluffyChat to Android and iOS too.

#### Why fluffy? Why is it pink and why are there so much emojis in the source code?
The most opensource messengers, like Conversations (XMPP) or Riot (Matrix) are great but have a very technical design. They are not much more complicated then messengers like Telegram or Whatsapp but I think they *feel* complicated, because of the user interface.
FluffyChat should look like a messenger, which targets also children. Because then, it will *feel* like "easy as a snap".
You don't like the colors? In the next versions, you will be able to change the colors and themes in the settings, so don't worry. ;-)

#### How are push notifications working?
The notifications are sent from the matrix homeserver to the fluffychat push-gateway at: https://github.com/ChristianPauly/fluffychat-push-gateway
This gateway just beams the push to https://push.ubports.com/notify via https. The push-gateway is currently on my own server! I am NOT saving any data! It is just forwarding! However you can just host your own gateway if you want. There is currently no end-to-end encryption in fluffychat so you should not send any message-content from your homeserver, if you don't trust fluffychat or ubports!
