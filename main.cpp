#include <QCommandLineParser>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QLocale>
#include <QTranslator>
#include <QtQuickControls2/QQuickStyle>
#include <QtWebEngine/QtWebEngine>

#include "inactivity-filter.h"
#include "process.h"

static QObject *get_process_singleton(QQmlEngine *engine,
                                      QJSEngine *scriptEngine) {
  // Q_UNUSED(engine)
  Q_UNUSED(scriptEngine)

  Process *process = new Process(engine);
  return process;
}

QString normalizeUrl(QString url) {
  if (url.startsWith("http://") || url.startsWith("https://")) {
    return url;
  }

  return "https://" + url;
}

// this has to be declared here because Qt 5.12 qmlRegisterSingletonType doesn't
// support usage of lambda
// if we update, trying to put this in main and use a lambda would be good
InactivityFilter *keyEater = new InactivityFilter();

static QObject *get_inactivity_filter(QQmlEngine *engine,
                                      QJSEngine *scriptEngine) {
  // Q_UNUSED(engine)
  Q_UNUSED(scriptEngine)

  return keyEater;
}

int main(int argc, char *argv[]) {

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
#ifdef __linux__
  QFile configurationFile = QFile("/etc/edutice-kiosk/kiosk.json");
#elif _WIN32
  QFile configurationFile =
      QFile("C:\\Program Files\\Novatice Technologies\\kiosk\\webportal.txt");
#endif
  if (!configurationFile.exists()) {
    logger.critical() << "Unable to find configuration file";
    ::exit(1);
  } else {
    bool opened = configurationFile.open(QIODevice::ReadOnly);
    if (opened) {
      QString content = configurationFile.readAll();
      QJsonObject configuration =
          QJsonDocument::fromJson(content.toUtf8()).object();

      QJsonValue urlValue = configuration.value("url");
      QJsonValue totemValue = configuration.value("totem");
      bool automaticMode = configuration.value("automatic").toBool();

      if (urlValue.isUndefined()) {
        logger.critical() << "Unable to find \"url\" key in configuration";
        ::exit(3);
      }
      bool totem;
      if (totemValue.isUndefined()) {
        totem = false;
      } else {
        totem = true;
      }

      QString url = normalizeUrl(urlValue.toString());

      QQmlApplicationEngine engine;

      engine.addImportPath("qrc:/qml/"); /* Insert relative path to your
                                                import directory here */

      qmlRegisterSingletonType<Process>("Process", 1, 0, "Process",
                                        get_process_singleton);

      qmlRegisterSingletonType<InactivityFilter>("InactivityWatcher", 1, 0,
                                                 "InactivityWatcher",
                                                 get_inactivity_filter);

      const QUrl qmlUrl(QStringLiteral("qrc:/qml/main.qml"));
      QObject::connect(
          &engine, &QQmlApplicationEngine::objectCreated, &app,
          [qmlUrl](QObject *obj, const QUrl &objUrl) {
            if (!obj && qmlUrl == objUrl)
              QCoreApplication::exit(-1);
          },
          Qt::QueuedConnection);
      engine.rootContext()->setContextProperty("urlToLoad", url);
      engine.rootContext()->setContextProperty("totem", totem);
      engine.rootContext()->setContextProperty("automatic", automaticMode);

      logger.debug() << "just before start";

      engine.load(qmlUrl);

      app.installEventFilter(keyEater);

      return app.exec();

    } else {
      logger.critical() << "Unable to open configuration file";
      ::exit(2);
    }
  }
}
