#include "requestinterceptor.h"
#include "QDebug"

void RequestInterceptor::interceptRequest(QWebEngineUrlRequestInfo &info) {
    bool flag = false;
    for (const QString &l : qAsConst(mList)) {
        if (info.requestUrl().host().endsWith(l, Qt::CaseInsensitive)) {
            flag = true;
            break;
        }
    }

    if (flag) {
        info.block(false);
    } else {
        qWarning() << "Rejected site: " << info.requestUrl().host();
        info.block(true);
    }
}

void RequestInterceptor::addWhiteList(QStringList &list)
{
    mList.append(list);
}
