#include <QDebug>
#include <QFile>
#include <QByteArray>
#include <QBitArray>
#include <QString>

#include "fluffychat.h"

Fluffychat::Fluffychat() {

}

void Fluffychat::speak() {
    qDebug() << "hello world!";
}

QByteArray Fluffychat::read(const QString &filename)
{
    QFile file(filename);
    char* temp;
    if (!file.open(QIODevice::ReadOnly)) {
        QByteArray blob(temp);
        return blob;
    }
    temp = new char [file.size()];
    file.read(temp,file.size());

    file.close();
    QByteArray blob(temp);

    return blob;
}

QString Fluffychat::toBase64(const QByteArray &file)
{
    return file.toBase64();
}
