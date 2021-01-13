#include "updatercontroller.h"

UpdaterController::UpdaterController(bool autoUpdater, QObject *parent) : QObject(parent)
{
    _updater = new CAutoUpdaterGithub("https://github.com/eska-ru/SchoolKiosk");
    _listener = new UpdateStatusListenerImpl;
    _updater->setUpdateStatusListener(_listener);

    if (autoUpdater) {
        QTimer* timer = new QTimer(this);
        timer->setInterval(1000*60*60);
        timer->callOnTimeout([this](){ _updater->checkForUpdates(); });
        timer->start();

        _updater->checkForUpdates();
    }
}

void UpdateStatusListenerImpl::onUpdateAvailable(CAutoUpdaterGithub::ChangeLog changelog)
{
    if (changelog.size()) {
        qDebug() << "Available updates:";
    } else {
        qDebug() << "No updates";
    }
    for (const auto &i : changelog) {
        qDebug() << i.versionChanges << i.versionString << i.versionUpdateUrl;
    }
}

void UpdateStatusListenerImpl::onUpdateDownloadProgress(float)
{
}

void UpdateStatusListenerImpl::onUpdateDownloadFinished()
{
    qDebug() << "Update Download Finished";
}

void UpdateStatusListenerImpl::onUpdateError(QString errorMessage)
{
    qDebug() << "Update Download Error: " << errorMessage;
}
