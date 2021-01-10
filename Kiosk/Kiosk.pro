QT += quick virtualkeyboard svg webengine

CONFIG += c++17 sdk_no_version_check

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/main.cpp \
        src/requestinterceptor.cpp \
        src/textcodec.cpp

RESOURCES += qml.qrc \
    fonts.qrc \
    images.qrc \
    layouts.qrc

TRANSLATIONS += \
    Kiosk_ru_RU.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Выбираем директорию сборки исполняемого файла
# в зависимости от режима сборки проекта
CONFIG(debug, debug|release) {
    DESTDIR = $$OUT_PWD/../../KioskDebug
} else {
    DESTDIR = $$OUT_PWD/../../KioskRelease
}
# разделяем по директориям все выходные файлы проекта
MOC_DIR = ../common/build/moc
RCC_DIR = ../common/build/rcc
UI_DIR = ../common/build/ui
unix:OBJECTS_DIR = ../common/build/o/unix
win:OBJECTS_DIR = ../common/build/o/win
macx:OBJECTS_DIR = ../common/build/o/mac

# в зависимости от режима сборки проекта
# запускаем win deploy приложения в целевой директории, то есть собираем все dll
CONFIG(debug, debug|release) {
    QMAKE_POST_LINK = $$(QTDIR)/bin/windeployqt --release --qmldir $$_PRO_FILE_PWD_/qml $$OUT_PWD/../../KioskDebug
} else {
    QMAKE_POST_LINK = $$(QTDIR)/bin/windeployqt --release --qmldir $$_PRO_FILE_PWD_/qml $$OUT_PWD/../../KioskRelease
}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    src/requestinterceptor.h \
    src/textcodec.h

DISTFILES += \
    settings.ini