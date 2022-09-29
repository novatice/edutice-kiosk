#ifndef PROCESS_H
#define PROCESS_H

#include <QProcess>

class Process : public QObject {
  Q_OBJECT
public:
  explicit Process(QObject *parent = nullptr);
  Q_INVOKABLE void start(const QString &program);

private:
  QProcess *m_process = nullptr;
  bool running = false;

signals:
};

#endif // PROCESS_H
