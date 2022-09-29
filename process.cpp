#include <QDebug>
#include <QObject>

#include "process.h"

void handler(QProcess::ProcessState state) {}

Process::Process(QObject *parent)
    : QObject{parent}, m_process(new QProcess(this)) {}

void Process::start(const QString &program) {
  qDebug() << "Trying to start: " << program;
  if (this->m_process->state() == QProcess::ProcessState::NotRunning) {
    this->m_process->start(program);
  } else {
    qInfo() << "process is already running, ignoring";
  }
}
