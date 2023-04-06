cmake_minimum_required(VERSION 3.14)

project(edutice-kiosk VERSION 0.1 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(QT webengine)


# Make Qt Creator aware of where the QML modules live
set (_QML_IMPORT_PATHS "")

## Add new module paths here.
list (APPEND _QML_IMPORT_PATHS ${CMAKE_CURRENT_SOURCE_DIR}/qml/)

set (
    QML_IMPORT_PATH
    ${_QML_IMPORT_PATHS}
    CACHE
    STRING
    "Path used to locate CMake modules by Qt Creator"
    FORCE
)


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(QT NAMES Qt5 REQUIRED COMPONENTS Core Quick WebEngine QuickControls2)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick WebEngine QuickControls2)

set(TS_FILES edutice-kiosk_fr_FR.ts)

set(PROJECT_SOURCES
        main.cpp
        process.cpp
        inactivity-filter.cpp
        process.h
        inactivity-filter.h
        qml.qrc
        ${TS_FILES}
)


add_executable(edutice-kiosk
        ${PROJECT_SOURCES}
        )

target_compile_definitions(edutice-kiosk
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)


target_link_libraries(edutice-kiosk
  PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Quick Qt${QT_VERSION_MAJOR}::WebEngine Qt5::QuickControls2)

set_target_properties(edutice-kiosk PROPERTIES WIN32_EXECUTABLE TRUE)
