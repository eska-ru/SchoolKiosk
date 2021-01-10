#ifndef REQUESTINTERCEPTOR_H
#define REQUESTINTERCEPTOR_H

#include <QWebEngineUrlRequestInterceptor>

class RequestInterceptor : public QWebEngineUrlRequestInterceptor
{
    Q_OBJECT
    // QWebEngineUrlRequestInterceptor interface
public:
    void interceptRequest(QWebEngineUrlRequestInfo &info) override;
    void addWhiteList(QStringList &list);


private:
    QStringList mList;
};

#endif // REQUESTINTERCEPTOR_H
