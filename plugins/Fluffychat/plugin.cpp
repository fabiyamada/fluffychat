#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "fluffychat.h"

void FluffychatPlugin::registerTypes(const char *uri) {
    //@uri Fluffychat
    qmlRegisterSingletonType<Fluffychat>(uri, 1, 0, "Fluffychat", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Fluffychat; });
}
