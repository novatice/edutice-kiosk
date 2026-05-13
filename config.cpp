#include "config.h"
#include <qdir.h>
#include <qjsondocument.h>
#include <qjsonobject.h>
#include <stdexcept>

#ifdef _WIN32
#include <windows.h>
#endif _WIN32

Config *Config::g_config;

#ifdef _WIN32
const static std::wstring g_kioskSubkey{L"SOFTWARE\\Novatice\\Edutice\\Kiosk"};

QString GetStringFromReg(HKEY hKey, std::wstring path, std::wstring value)
{
    DWORD dataSize;
    LONG retCode = RegGetValueW(hKey,
                                path.c_str(),
                                value.c_str(),
                                RRF_RT_REG_SZ,
                                nullptr,
                                nullptr,
                                &dataSize);
    if (retCode != ERROR_SUCCESS) {
        qWarning("Coulndn't get REG_SZ value %s from Registry :: error = %s",
                 value.c_str(),
                 qUtf8Printable(std::to_string(retCode).c_str()));
        return NULL;
    }
    std::wstring data;
    data.resize(dataSize / sizeof(wchar_t));

    retCode = RegGetValueW(hKey,
                           path.c_str(),
                           value.c_str(),
                           RRF_RT_REG_SZ,
                           nullptr,
                           &data[0],
                           &dataSize);
    //we need to do something to be able to log value
    if (retCode != ERROR_SUCCESS) {
        qWarning("Coulndn't get REG_SZ value %s from Registry :: error = %s",
                 value.c_str(),
                 qUtf8Printable(std::to_string(retCode).c_str()));
        return NULL;
    }

    // resizing data from byte to wchar and remove double NULL termination
    data.resize(dataSize / sizeof(wchar_t) - 1);

    return QString::fromWCharArray(data.c_str());
}


DWORD GetDwordFromReg(HKEY hKey, std::wstring path, std::wstring value)
{
    DWORD data{};
    DWORD dataSize = sizeof(data);
    LONG retCode = RegGetValueW(hKey,
                                path.c_str(),
                                value.c_str(),
                                RRF_RT_REG_DWORD,
                                nullptr,
                                &data,
                                &dataSize);

    //we need to do something to be able to log value
    if (retCode != ERROR_SUCCESS) {
        qWarning("Coulndn't get DWORD value %s from Registry :: error = %s",
                 value.c_str(),
                 qUtf8Printable(std::to_string(retCode).c_str()));
        return NULL;
    }
    return data;
}
#endif

Config::Config(const QString &url,
               const bool &automatic,
               const QString &serverAddress,
               const QString &deviceUuid,
               const QString &proxyHostname,
               const int &proxyPort)
    : _serverAddress(serverAddress)
    , _deviceUuid(deviceUuid)
    , _url(url)
    , _automatic(automatic)
    , _proxyHostname(proxyHostname)
    , _proxyPort(proxyPort)
{
    if (!_serverAddress.isNull() && !_deviceUuid.isNull()) {
        _arguments = "?kiosk=true&deviceUuid=" + _deviceUuid.toStdString();
    }
    if (!_url.isNull()) {
        if (!_url.startsWith("http://") && !_url.startsWith("https://")) {
            _url = "https://" + url;
        }
    }
}

const QString Config::addNeosUrlParameters(QString url)
{
    if (url.isNull() || url.isEmpty()) {
        qCritical("Cannot add NEOS parameters url is null or empty");
        return NULL;
    }
    if (_serverAddress.isNull()|| _serverAddress.isEmpty()){
        qCritical("Cannot add NEOS parameters server address is null");
        return url;
    }
    if (url.contains(_arguments.c_str())) {
        return url;
    }
    if (_arguments.empty()) {
        qWarning("Arguments are empty. Cannot add them to url");
        return url;
    }
    auto urlStr = url.toStdString();
    size_t findPos = urlStr.find(_serverAddress.toStdString());
    if (findPos == std::string::npos) {
        return url;
    }
    qInfo("url %s is a NEOS server URL.", qUtf8Printable(url));
    try {
        if (urlStr.size() < (findPos + _serverAddress.size())) {
            throw std::invalid_argument("Url is smaller than find position");
        }
        size_t insertPos = urlStr.find("/neos", findPos + _serverAddress.size());
        if (insertPos == std::string::npos) {
            qDebug("Couldn't find '/neos' in url. Using original url");
            return url;
        } else if (urlStr.find('#', insertPos) == std::string::npos) {
            qDebug("Couldn't find '#' with '/neos' in url. Using original url");
            return url;
        }
        // we add 5 to the position for the number of characters in '/neos'
        insertPos += 5;
        if (insertPos > urlStr.size()) {
            throw std::invalid_argument("Url is smaller than insert position");
        }
        size_t argPos = urlStr.find('?', insertPos);
        if (argPos != std::string::npos) {
            //we want to add our arguments before the arguments that are already present
            //we erase the current '?'
            urlStr.erase(argPos, 1);
            //we append w/ '&' to seperate the current and added arguments
            _arguments.append("&");
            urlStr.insert(argPos, _arguments);
        }
        urlStr.insert(insertPos, _arguments);
        return QString(urlStr.c_str());
    } catch (const std::exception &e) {
        qCritical("Couldn't add NEOS  arguments %s \\n Using original url", e.what());
        return url;
    }
}

Config *Config::GetDeviceConfig()
{
    if (g_config != nullptr) {
        return g_config;
    } else {
#ifdef _WIN32
        QString url = GetStringFromReg(HKEY_LOCAL_MACHINE, g_kioskSubkey, L"Url");

        DWORD automatic = GetDwordFromReg(HKEY_LOCAL_MACHINE, g_kioskSubkey, L"Automatic");

        if (!url.isNull()) {
            QString proxyHostname = GetStringFromReg(HKEY_LOCAL_MACHINE,
                                                     g_kioskSubkey,
                                                     L"ProxyHostname");

            DWORD dwordPort = GetDwordFromReg(HKEY_LOCAL_MACHINE, g_kioskSubkey, L"ProxyPort");

            QString serverAddress = GetStringFromReg(HKEY_LOCAL_MACHINE,
                                                     g_kioskSubkey,
                                                     L"ServerHostname");

            QString deviceUuid = GetStringFromReg(HKEY_LOCAL_MACHINE, g_kioskSubkey, L"DeviceUUID");

            qDebug(
                "Device config found. url : %s ; automatic : %d ; serverAddress : %s ; " "deviceuui"
                                                                                         "d : %s",
                qUtf8Printable(url),
                automatic,
                qUtf8Printable(serverAddress),
                qUtf8Printable(deviceUuid));

            bool totem = GetDwordFromReg(HKEY_LOCAL_MACHINE, g_kioskSubkey, L"Totem") == 1 ? true : false;
            g_config = new Config(url,
                                         automatic,
                                         serverAddress,
                                         deviceUuid,
                                         proxyHostname,
                                         dwordPort);
            g_config->_totem = totem;
            return g_config;
        } else {
            return nullptr;
        }
#elif __linux__
        QFile configurationFile = QFile("/etc/edutice-kiosk/kiosk.json");

        if (!configurationFile.exists()) {
            qCritical() << "Unable to find configuration file";
            return nullptr;
        }
        if (!configurationFile.open(QIODevice::ReadOnly)) {
            qCritical() << "Unable to find \"url\" key in configuration";
            return nullptr;
        }
        QString content = configurationFile.readAll();
        QJsonObject configuration = QJsonDocument::fromJson(content.toUtf8()).object();

        QJsonValue urlValue = configuration.value("url");
        QJsonValue totemValue = configuration.value("totem");
        bool automaticMode = configuration.value("automatic").toBool();

        if (urlValue.isUndefined()) {
            qCritical() << "Unable to find \"url\" key in configuration";
            return nullptr;
        }
        bool totem;
        if (totemValue.isUndefined()) {
            totem = false;
        } else {
            totem = true;
        }
        QString proxyHost;
        int proxyPort = NULL;

        g_config = new Config(urlValue.toString(), automaticMode, NULL, NULL, proxyHost, proxyPort);
        g_config->_totem = totem;
        return g_config;
#endif
    }
}

bool Config::SetProxy()
{
    if (_proxyHostname.isEmpty() || _proxyHostname.isNull() || _proxyPort == NULL) {
        qInfo("No proxy configuration found.");
        _proxy.setType(QNetworkProxy::NoProxy);
        QNetworkProxy::setApplicationProxy(_proxy);
        return false;
    }
    _proxy.setType(QNetworkProxy::HttpProxy);
    _proxy.setHostName(_proxyHostname);
    _proxy.setPort(_proxyPort);
    QNetworkProxy::setApplicationProxy(_proxy);
    qInfo("Proxy found %s on port : %d", qUtf8Printable(_proxy.hostName()), _proxy.port());
    return true;
}

