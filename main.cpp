#include <QCommandLineParser>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QLocale>
#include <QTranslator>
#include <QtQuickControls2/QQuickStyle>
#include <QtWebEngineQuick/QtWebEngineQuick>

#include "inactivity-filter.h"
#include "process.h"
#include "config.h"

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
  QtWebEngineQuick::initialize();
  QGuiApplication app(argc, argv);


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
  Config* deviceConfig = Config::GetDeviceConfig();
  if (deviceConfig == nullptr) {
      ::exit(2);
  }
  deviceConfig->SetProxy();
  bool totem = deviceConfig->SetTotemMode();

  QQmlApplicationEngine engine;

  engine.addImportPath("qrc:/qml/"); /* Insert relative path to your
                                                import directory here */

  qmlRegisterSingletonType<Process>("Process", 1, 0, "Process", get_process_singleton);

  qmlRegisterSingletonType<InactivityFilter>("InactivityWatcher",
                                             1,
                                             0,
                                             "InactivityWatcher",
                                             get_inactivity_filter);

  const QUrl qmlUrl(QStringLiteral("qrc:/qml/main.qml"));
  QObject::connect(
      &engine,
      &QQmlApplicationEngine::objectCreated,
      &app,
      [qmlUrl](QObject *obj, const QUrl &objUrl) {
          if (!obj && qmlUrl == objUrl)
              QCoreApplication::exit(-1);
      },
      Qt::QueuedConnection);
  Process *process = new Process(&engine);
  QObject::
      connect(QCoreApplication::instance(), SIGNAL(aboutToQuit()), process, SLOT(disconnect()));
  //We could possibly change to only deviceConfig in the futur
  engine.rootContext()->setContextProperty("urlToLoad", deviceConfig->GetUrl());
  engine.rootContext()->setContextProperty("totem", totem);
  engine.rootContext()->setContextProperty("automatic", deviceConfig->GetAutomaticMode());
  engine.rootContext()->setContextProperty("deviceConfig", deviceConfig);

  logger.debug() << "just before start";

  engine.load(qmlUrl);

  if (!totem) {
      app.installEventFilter(keyEater);
  }

  return app.exec();
}

