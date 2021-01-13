#ifndef UPDATERCONTROLLER_H
#define UPDATERCONTROLLER_H

#include <QObject>
#include <QTimer>
#include "cautoupdatergithub.h"

class UpdateStatusListenerImpl : public CAutoUpdaterGithub::UpdateStatusListener {
public:
    void onUpdateAvailable(CAutoUpdaterGithub::ChangeLog changelog);
    void onUpdateDownloadProgress(float percentageDownloaded);
    void onUpdateDownloadFinished();
    void onUpdateError(QString errorMessage);
};

class UpdaterController : public QObject
{
    Q_OBJECT
public:
    explicit UpdaterController(bool autoUpdater, QObject *parent = nullptr);

private:
    CAutoUpdaterGithub* _updater;
    UpdateStatusListenerImpl* _listener;

signals:

};

#endif // UPDATERCONTROLLER_H
