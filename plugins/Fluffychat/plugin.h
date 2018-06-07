#ifndef FLUFFYCHATPLUGIN_H
#define FLUFFYCHATPLUGIN_H

#include <QQmlExtensionPlugin>

class FluffychatPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);
};

#endif
