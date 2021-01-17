#include "cautoupdatergithub.h"
#include "updateinstaller.hpp"

#include <QCollator>
#include <QCoreApplication>
#include <QDir>
#include <QNetworkRequest>
#include <QNetworkReply>

#include <assert.h>

#if defined _WIN32
#define UPDATE_FILE_EXTENSION QLatin1String(".exe")
#elif defined __APPLE__
#define UPDATE_FILE_EXTENSION QLatin1String(".dmg")
#else
#define UPDATE_FILE_EXTENSION QLatin1String(".AppImage")
#endif

static const auto versionComparator = [](const QString& compare) {
    QRegExp re(".*(\\1\\d+)\\.(\\2\\d+)\\.(\\3\\d+)\\.(\\4\\d+)");
    re.indexIn(QCoreApplication::applicationVersion());
    int major = re.cap(1).toInt();
    int minor = re.cap(2).toInt();
    int patch = re.cap(3).toInt();
    int build = re.cap(4).toInt();

    re.indexIn(compare);
    int cMajor = re.cap(1).toInt();
    int cMinor = re.cap(2).toInt();
    int cPatch = re.cap(3).toInt();
    int cBuild = re.cap(4).toInt();

    if (major < cMajor || minor < cMinor || patch < cPatch || build < cBuild)
        return true;

    return false;
};

CAutoUpdaterGithub::CAutoUpdaterGithub(const QString& githubRepositoryAddress) :
    _updatePageAddress(githubRepositoryAddress + "/releases/")
{
	assert(githubRepositoryAddress.contains("https://github.com/"));
}

void CAutoUpdaterGithub::setUpdateStatusListener(UpdateStatusListener* listener)
{
	_listener = listener;
}

void CAutoUpdaterGithub::checkForUpdates()
{
	QNetworkReply * reply = _networkManager.get(QNetworkRequest(QUrl(_updatePageAddress)));
	if (!reply)
	{
		if (_listener)
			_listener->onUpdateError("Network request rejected.");
		return;
	}

	connect(reply, &QNetworkReply::finished, this, &CAutoUpdaterGithub::updateCheckRequestFinished, Qt::UniqueConnection);
}

void CAutoUpdaterGithub::downloadAndInstallUpdate(const QString& updateUrl)
{
	assert(!_downloadedBinaryFile.isOpen());

	_downloadedBinaryFile.setFileName(QDir::tempPath() + '/' + QCoreApplication::applicationName() + UPDATE_FILE_EXTENSION);
	if (!_downloadedBinaryFile.open(QFile::WriteOnly))
	{
		if (_listener)
			_listener->onUpdateError("Failed to open temporary file " + _downloadedBinaryFile.fileName());
		return;
	}

	QNetworkRequest request((QUrl(updateUrl)));
	request.setSslConfiguration(QSslConfiguration::defaultConfiguration()); // HTTPS
	request.setMaximumRedirectsAllowed(5);
	request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);
	QNetworkReply * reply = _networkManager.get(request);
	if (!reply)
	{
		if (_listener)
			_listener->onUpdateError("Network request rejected.");
		return;
	}

	connect(reply, &QNetworkReply::readyRead, this, &CAutoUpdaterGithub::onNewDataDownloaded);
	connect(reply, &QNetworkReply::downloadProgress, this, &CAutoUpdaterGithub::onDownloadProgress);
	connect(reply, &QNetworkReply::finished, this, &CAutoUpdaterGithub::updateDownloaded, Qt::UniqueConnection);
}

static QString match(const QString& pattern, const QString& text, int from, int& end)
{
	end = -1;

	const auto delimiters = pattern.split('*');
	if (delimiters.size() != 2)
	{
		Q_ASSERT_X(delimiters.size() != 2, __FUNCTION__, "Invalid pattern");
		return {};
	}

	const int leftDelimiterStart = text.indexOf(delimiters[0], from);
	if (leftDelimiterStart < 0)
		return {};

	const int rightDelimiterStart = text.indexOf(delimiters[1], leftDelimiterStart + delimiters[0].length());
	if (rightDelimiterStart < 0)
		return {};

	const int resultLength = rightDelimiterStart - leftDelimiterStart - delimiters[0].length();
	if (resultLength <= 0)
		return {};

	end = rightDelimiterStart + delimiters[1].length();
	return text.mid(leftDelimiterStart + delimiters[0].length(), resultLength);
}

void CAutoUpdaterGithub::updateCheckRequestFinished()
{
	auto reply = qobject_cast<QNetworkReply *>(sender());
	if (!reply)
		return;

	reply->deleteLater();

	if (reply->error() != QNetworkReply::NoError)
	{
		if (_listener)
			_listener->onUpdateError(reply->errorString());

		return;
	}

	if (reply->bytesAvailable() <= 0)
	{
		if (_listener)
			_listener->onUpdateError("No data downloaded.");
		return;
	}

	ChangeLog changelog;
	const QString changelogPattern = QStringLiteral("<div class=\"markdown-body\">\n*</div>");
	const QString versionPattern = QStringLiteral("/releases/tag/*\">");
	const QString releaseUrlPattern = QStringLiteral("<a href=\"*\"");

	const auto releases = QString(reply->readAll()).split("release-header");
	// Skipping the 0 item because anything before the first "release-header" is not a release
	for (int releaseIndex = 1, numItems = releases.size(); releaseIndex < numItems; ++releaseIndex)
	{
		const QString& releaseText = releases[releaseIndex];

		int offset = 0;
		QString updateVersion = match(versionPattern, releaseText, offset, offset);
		if (updateVersion.startsWith(QStringLiteral(".v")))
			updateVersion.remove(0, 2);
		else if (updateVersion.startsWith('v'))
			updateVersion.remove(0, 1);

        if (!versionComparator(updateVersion))
            continue;

        const QString updateChanges = match(changelogPattern, releaseText, offset, offset);

		QString url;
		offset = 0; // Gotta start scanning from the beginning again, since the release URL could be before the release description
		while (offset != -1)
		{
			const QString newUrl = match(releaseUrlPattern, releaseText, offset, offset);
			if (newUrl.endsWith(UPDATE_FILE_EXTENSION))
			{
				Q_ASSERT_X(url.isEmpty(), __FUNCTION__,"More than one suitable update URL found");
				url = newUrl;
			}
		}

		if (!url.isEmpty())
			changelog.push_back({ updateVersion, updateChanges, "https://github.com" + url });
	}

	if (_listener)
		_listener->onUpdateAvailable(changelog);
    if (changelog.size() > 0) {
        downloadAndInstallUpdate(changelog.at(0).versionUpdateUrl);
    }

}

void CAutoUpdaterGithub::updateDownloaded()
{
	_downloadedBinaryFile.close();

	auto reply = qobject_cast<QNetworkReply *>(sender());
	if (!reply)
		return;

	reply->deleteLater();

	if (reply->error() != QNetworkReply::NoError)
	{
		if (_listener)
			_listener->onUpdateError(reply->errorString());

		return;
	}

	if (_listener)
		_listener->onUpdateDownloadFinished();

    if (!UpdateInstaller::install(_downloadedBinaryFile.fileName()) && _listener) {
		_listener->onUpdateError("Failed to launch the downloaded update.");
        return;
    }

    QCoreApplication::quit();
}

void CAutoUpdaterGithub::onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
	if (_listener)
		_listener->onUpdateDownloadProgress(bytesReceived < bytesTotal ? bytesReceived * 100 / (float)bytesTotal : 100.0f);
}

void CAutoUpdaterGithub::onNewDataDownloaded()
{
	auto reply = qobject_cast<QNetworkReply*>(sender());
	if (!reply)
		return;

	_downloadedBinaryFile.write(reply->readAll());
}
