#include "config.h"
#include <stdexcept>
#include <windows.h>

Config *Config::g_config;

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
    if (retCode != ERROR_SUCCESS) {
        return NULL;
    }

    // resizing data from byte to wchar and remove double NULL termination
    data.resize(dataSize / sizeof(wchar_t) - 1);

    return QString::fromWCharArray(data.c_str());
}

const QString Config::addNeosUrlParameters(QString url)
{
    if (url.isNull() || url.isEmpty()) {
        qCritical("Cannot add NEOS parameters url is null or empty");
        return NULL;
    }
    if (url.contains(_arguments.c_str())) {
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
        urlStr.insert(insertPos, _arguments);
        return QString(urlStr.c_str());
    } catch (const std::exception &e) {
        qCritical("Couldn't add NEOS  arguments %s \\n Using original url", e.what());
        return url;
    }
}

Config::Config(const QString &serverAddress, const QString &deviceUuid)
    : _serverAddress(serverAddress)
    , _deviceUuid(deviceUuid)
{
    _arguments = "?kiosk=true&deviceUuid=" + _deviceUuid.toStdString();
}

Config *Config::GetDeviceConfig()
{
    if (g_config != nullptr) {
        return g_config;
    } else {
#ifdef _WIN32
        QString serverAddress = GetStringFromReg(HKEY_LOCAL_MACHINE,
                                                 L"SOFTWARE\\Novatice\\Edutice\\Service",
                                                 L"ServerHostname");

        QString deviceUuid = GetStringFromReg(HKEY_LOCAL_MACHINE,
                                              L"SOFTWARE\\Novatice\\Edutice\\Service",
                                              L"DeviceUUID");
        if (serverAddress.isNull() || deviceUuid.isNull()) {
            qCritical("Couldn't get device config");
            return NULL;
        }
        qDebug("Device config found. serverAddress : %s ; deviceUuid : %s",
               qUtf8Printable(serverAddress),
               qUtf8Printable(deviceUuid));
        return g_config = new Config(serverAddress, deviceUuid);
#elif __linux__
        // not implemented
        return NULL;
#endif
    }
}
