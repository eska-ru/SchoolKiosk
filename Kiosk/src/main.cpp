#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QtWebEngine>
#include <QQuickWebEngineProfile>
#include "requestinterceptor.h"
#include "textcodec.h"

int main(int argc, char *argv[])
{
    QtWebEngine::initialize();
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
    qputenv("QT_VIRTUALKEYBOARD_LAYOUT_PATH", QByteArray(":/layouts"));

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    QDir::setCurrent(QCoreApplication::applicationDirPath());

    QSettings settings("settings.ini", QSettings::IniFormat);
    settings.setIniCodec("UTF-8");
    settings.value("buttonsData", "").toString();

    RequestInterceptor *ri = new RequestInterceptor;
    QStringList whitelist = settings.value("whitelist", QStringList()).toStringList();
    ri->addWhiteList(whitelist);
    QQuickWebEngineProfile::defaultProfile()->setUrlRequestInterceptor(ri);

    QQmlApplicationEngine engine;

    TextCodec codec;
    engine.rootContext()->setContextProperty("appCodec", &codec);

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
