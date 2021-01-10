#ifndef TEXTCODEC_H
#define TEXTCODEC_H

#include <QObject>

class TextCodec : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE QString fromCP1251ToUtf8(QString from);
    explicit TextCodec(QObject *parent = nullptr);

signals:

};

#endif // TEXTCODEC_H
