#ifndef CONFIG_H
#define CONFIG_H

#include <QString>
#include <QtQml/qqmlregistration.h>
#include "qobject.h"
#include <qnetworkproxy.h>

class Config : public QObject
{
    Q_OBJECT
public:
    Config(const QString &url,
           const bool &automatic,
           const QString &serverAddress,
           const QString &deviceUuid,
           const QString &proxyHostname,
           const int &proxyPort);

    const QString &GetServerAddress() { return _serverAddress; }
    const QString &GetDeviceUuid() { return _deviceUuid; }
    const bool &GetAutomaticMode() { return _automatic; }
    const QString &GetUrl() { return _url; }
    const bool &GetTotemMode(){return _totem;}
    const bool &GetTabMode(){return _tabMode;}
    const bool &GetPrintAllowed(){return _printAllowed;}
    const int &GetInactivityDelay(){return _inactivityDelay;}
    const int &GetWarningDuration(){return _warningDuration;}

    //Adds the kiosk arguments to the url to be recognized as such
    //@param param1 url string to change
    Q_INVOKABLE const QString addNeosUrlParameters(QString url);

    bool SetProxy();
    //bool GetTotemMode();

    //Gets device's config from NEOS Registry keys
    static Config *GetDeviceConfig();

protected:
    static Config *g_config;

private:
    Q_PROPERTY(QString serverAddress READ GetServerAddress CONSTANT)
    QString _serverAddress;
    Q_PROPERTY(QString deviceUuid READ GetDeviceUuid CONSTANT)
    QString _deviceUuid;
    Q_PROPERTY(QString urlToLoad READ GetUrl CONSTANT)
    QString _url;
    Q_PROPERTY(bool automatic READ GetAutomaticMode CONSTANT)
    bool _automatic;
    Q_PROPERTY(bool tabMode READ GetTabMode CONSTANT)
    bool _tabMode = false;
    Q_PROPERTY(bool totem READ GetTotemMode CONSTANT)
    bool _totem = false;
    Q_PROPERTY(bool printAllowed READ GetPrintAllowed CONSTANT)
    bool _printAllowed = false;
    Q_PROPERTY(int inactivityDelay READ GetInactivityDelay CONSTANT)
    int _inactivityDelay = 300;
    Q_PROPERTY(int warningDuration READ GetWarningDuration CONSTANT)
    int _warningDuration = 20;

    QString _proxyHostname;
    int _proxyPort;
    QNetworkProxy _proxy;

    std::string _arguments;

    static void ApplyInactivityTimings(Config *config,
                                       int inactivityDelay,
                                       int warningDuration,
                                       bool hasInactivityDelay,
                                       bool hasWarningDuration);
#ifdef __linux__
    static void LoadLinuxInactivityConfig(Config *config);
#endif
};
#endif // CONFIG_H
