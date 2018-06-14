#include <QDebug>
#include <QFile>
#include <QByteArray>
#include <QBitArray>
#include <QString>
#include <QNetworkAccessManager>
#include <string>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QLoggingCategory>
#include <QTextStream>

#include "fluffychat.h"

Fluffychat::Fluffychat() {

}

void Fluffychat::speak() {
    qDebug() << "hello world!";
}

QString Fluffychat::read(const QString &filename)
{
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly))
    return QByteArray();

    return file.readAll();
}

void Fluffychat::upload ( const QString &path, const QString &urlstr, const QString &token ) {
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
    // add image
    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader,QVariant("form-data; name=\"image\"; filename=\"upload.jpg\""));
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/jpeg"));

    // open file
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "# Could not upload file, could not open file";
        return;
    }

    // read file and set data into object
    QByteArray fileContent(file.readAll());
    imagePart.setBody(fileContent);
    multiPart->append(imagePart);

    // set url
    QUrl url( urlstr );
    QNetworkRequest request(url);
    request.setRawHeader("Authorization", QByteArray(token.toLatin1()));

    QLoggingCategory::setFilterRules("qt.network.ssl.w arning=false");

    // create network manager
    QNetworkAccessManager * manager;
    manager = new QNetworkAccessManager();
    connect(manager, SIGNAL(finished(QNetworkReply*)),this, SLOT(replyFinished(QNetworkReply*)));

    manager->post(request, multiPart);

    qDebug() << "# Done sending upload request";
}

void Fluffychat::replyFinished()
{
    qDebug() << "it is working";
}
