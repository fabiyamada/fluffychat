#ifndef FLUFFYCHAT_H
#define FLUFFYCHAT_H

#include <QObject>

class Fluffychat: public QObject {
    Q_OBJECT

public:
    Fluffychat();
    ~Fluffychat() = default;

    Q_INVOKABLE void speak();
    Q_INVOKABLE QString read( const QString &filename );
    Q_INVOKABLE void upload( const QString &path, const QString &url, const QString &token );

public slots:
    void replyFinished ();
};

#endif
