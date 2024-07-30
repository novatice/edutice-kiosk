#ifndef CONFIG_H
#define CONFIG_H

#include <QString>
#include <QtQml/qqmlregistration.h>
#include "qobject.h"

class Config : public QObject
{
    Q_OBJECT
public:
    Config(const QString &serverAddress, const QString &deviceUuid);

    const QString &GetServerAddress() { return _serverAddress; }
    const QString &GetDeviceUuid() { return _deviceUuid; }
    Q_INVOKABLE const QString addNeosUrlParameters(QString url);

    static Config *GetDeviceConfig();

protected:
    static Config *g_config;

private:
    Q_PROPERTY(QString serverAddress READ GetServerAddress CONSTANT)
    QString _serverAddress;
    Q_PROPERTY(QString deviceUuid READ GetDeviceUuid CONSTANT)
    QString _deviceUuid;
    std::string _arguments;
};
#endif // CONFIG_H
