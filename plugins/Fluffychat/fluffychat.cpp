#include <QDebug>
#include <QFile>

#include "fluffychat.h"

Fluffychat::Fluffychat() {

}

void Fluffychat::speak() {
    qDebug() << "hello world!";
}

QByteArray Fluffychat::read(const QString &filename)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly))
        return QByteArray();

    return file.readAll();
}
