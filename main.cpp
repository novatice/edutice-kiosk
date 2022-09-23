#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCommandLineParser>

#include <QLocale>
#include <QTranslator>
#include <QtQuickControls2/QQuickStyle>
#include <QtWebEngine/QtWebEngine>

QString normalizeUrl(QString url) {
    if (url.startsWith("http://") || url.startsWith("https://")) {
        return url;
    }

    return "https://" + url;
}

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    QtWebEngine::initialize();

    QMessageLogger logger;

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "edutice-kiosk_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }



    QFile configurationFile = QFile("/etc/edutice-kiosk/kiosk.json");

    if(!configurationFile.exists()) {
        logger.critical() << "Unable to find configuration file";
        ::exit(1);
    } else {
        bool opened = configurationFile.open(QIODevice::ReadOnly);
        if (opened) {
            QString content = configurationFile.readAll();
            QJsonObject configuration = QJsonDocument::fromJson(content.toUtf8()).object();

            QJsonValue urlValue = configuration.value("url");

            if (urlValue.isUndefined()) {
                logger.critical() << "Unable to find \"url\" key in configuration";
                ::exit(3);
            }

            QString url = normalizeUrl(urlValue.toString());

            QQmlApplicationEngine engine;


            const QUrl qmlUrl(QStringLiteral("qrc:/main.qml"));
            QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                             &app, [qmlUrl](QObject *obj, const QUrl &objUrl) {
                if (!obj && qmlUrl == objUrl)
                    QCoreApplication::exit(-1);
            }, Qt::QueuedConnection);
            engine.rootContext()->setContextProperty("urlToLoad", url);

            engine.load(qmlUrl);


            return app.exec();

        } else {
            logger.critical() << "Unable to open configuration file";
            ::exit(2);
        }
    }
}
