#ifndef PROCESS_H
#define PROCESS_H

#include "qqmlengine.h"
#include <QProcess>

class Process : public QObject {
  Q_OBJECT
public:
  explicit Process(QObject *parent = nullptr,QQmlEngine *engine = nullptr);
  Q_INVOKABLE void start(const QString &program);
  Q_INVOKABLE void disconnect();
  Q_INVOKABLE void openTerminal();

private:
  QProcess *m_process = nullptr;
  QQmlEngine *m_engine = nullptr;
  bool running = false;

signals:
};

#endif // PROCESS_H
