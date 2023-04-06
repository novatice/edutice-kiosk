#include <QDebug>
#include <QObject>

#include "process.h"
#ifdef _WIN32
#include <windows.h>
#include <winBase.h>
#endif

void handler(QProcess::ProcessState state) {}

Process::Process(QObject *parent, QQmlEngine *engine)
    : QObject{parent}, m_process(new QProcess(this)) {
  m_engine = engine;
}

void Process::start(const QString &program) {
  qDebug() << "Trying to start: " << program;
  if (this->m_process->state() == QProcess::ProcessState::NotRunning) {
    this->m_process->start(program);
  } else {
    qInfo() << "process is already running, ignoring";
  }
}

void Process::disconnect() {
#ifdef __linux__
#elif _WIN32
  m_process->startDetached("shutdown -L");
  m_process->waitForFinished(-1);
#endif
}

void Process::openTerminal(){
#ifdef __linux__
    start("konsole");
#elif _WIN32
    m_process->setCreateProcessArgumentsModifier([](QProcess::CreateProcessArguments *args){
        args->flags |= CREATE_NEW_CONSOLE;
        args->startupInfo->dwFlags &= ~STARTF_USESTDHANDLES;
        args->startupInfo->dwFlags |= STARTF_USEFILLATTRIBUTE;
        args->startupInfo->dwFillAttribute = FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_BLUE;
    });
    m_process->start("C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe");
#endif
}
