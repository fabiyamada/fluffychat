#ifndef FLUFFYCHAT_H
#define FLUFFYCHAT_H

#include <QObject>

class Fluffychat: public QObject {
    Q_OBJECT

public:
    Fluffychat();
    ~Fluffychat() = default;

    Q_INVOKABLE void speak();
    Q_INVOKABLE QByteArray read(const QString &filename);
};

#endif
