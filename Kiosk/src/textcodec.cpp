#include "textcodec.h"

#include <QTextCodec>

QString TextCodec::fromCP1251ToUtf8(QString from)
{
    QTextCodec *codec = QTextCodec::codecForName("CP1251");
    QString to = codec->toUnicode(from.toLatin1());
    return to;
}

TextCodec::TextCodec(QObject *parent) : QObject(parent)
{
}
