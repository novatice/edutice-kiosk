#include <QDebug>
#include <QObject>

#include "process.h"

void handler(QProcess::ProcessState state) {}

Process::Process(QObject *parent, QQmlEngine *engine)
    : QObject{parent}, m_process(new QProcess(this)) {
    m_engine=engine;
}

void Process::start(const QString &program) {
  qDebug() << "Trying to start: " << program;
  if (this->m_process->state() == QProcess::ProcessState::NotRunning) {
    this->m_process->start(program);
  } else {
    qInfo() << "process is already running, ignoring";
  }
}

void Process::disconnect (){
#ifdef __linux__
    m_engine->quit();
#elif _WIN32
    m_process->startDetached("shutdown -L");
    m_process->waitForFinished(-1);
#endif
}
