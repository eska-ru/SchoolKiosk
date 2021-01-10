# Before run make project, need to put executable file and dlls into
# $$PWD/installer/packages/ru.writeway.kioskinstaller/data

TEMPLATE = aux

# В зависимости от режима сборки, определяем, куда именно будут собираться инсталляторы
CONFIG(debug, debug|release) {
    INSTALLER_OFFLINE = $$OUT_PWD/../../InstallerDebug/Kiosk.offline
    DESTDIR_WIN = $$PWD/packages/ru.writeway.kioskinstaller/data
    DESTDIR_WIN ~= s,/,\\,g
    PWD_WIN = $$OUT_PWD/../../KioskDebug
    PWD_WIN ~= s,/,\\,g

    copydata.commands = $(COPY_DIR) $$PWD_WIN $$DESTDIR_WIN
    first.depends = $(first) copydata
    export(first.depends)
    export(copydata.commands)
    QMAKE_EXTRA_TARGETS += first copydata
} else {
    # Задаём переменные, которые будут содержать пути с названиями инсталляторов
    INSTALLER_OFFLINE = $$OUT_PWD/../../InstallerRelease/Kiosk.offline

    # Задаём переменную, которая должна содержать путь к папке с данными
    DESTDIR_WIN = $$PWD/packages/ru.writeway.kioskinstaller/data
    DESTDIR_WIN ~= s,/,\\,g
    # Задаём путь откуда всё приложение с DLL-ками нужно будет скопировать
    PWD_WIN = $$OUT_PWD/../../KioskRelease
    PWD_WIN ~= s,/,\\,g

    # Прежде, чем выполнять сборку инсталляторов, необходимо скопировать файлы
    # из выходной папки проекта вместе со всеми DLL в папку data, которая относится
    # к собираемому пакету
    copydata.commands = $(COPY_DIR) $$PWD_WIN $$DESTDIR_WIN
    first.depends = $(first) copydata
    export(first.depends)
    export(copydata.commands)
    # задаём кастомную цель сборки, при которой сначала выполним компирование файлов
    # а потом уже и остальное, что следует по скрипту QMake
    QMAKE_EXTRA_TARGETS += first copydata
}

# Создаём цель по сборке Оффлайн Инсталлятора
INPUT = $$PWD/config/config.xml $$PWD/packages
offlineInstaller.depends = copydata
offlineInstaller.input = INPUT
offlineInstaller.output = $$INSTALLER_OFFLINE
offlineInstaller.commands = C:\Qt\Tools\QtInstallerFramework\4.0\bin\binarycreator --offline-only -c $$PWD/config/config.xml -p $$PWD/packages ${QMAKE_FILE_OUT}
offlineInstaller.CONFIG += target_predeps no_link combine

QMAKE_EXTRA_COMPILERS += offlineInstaller

# репозиторий будем собирать только в случае режима release
CONFIG(release, debug|release) {
    # Сборку репозитория производим после того, как были собраны Инсталляторы
    # Для этого воспользуемся QMAKE_POST_LINK вместо QMAKE_EXTRA_COMPILERS
    # Поскольку он хорошо для этого подходит
    QMAKE_POST_LINK += C:\Qt\Tools\QtInstallerFramework\4.0\bin\repogen -p $$PWD/packages -i ru.writeway.kioskinstaller --update $$OUT_PWD/../../repository
}

DISTFILES += \
    config/installscript.js \
    packages/ru.writeway.kioskinstaller/meta/package.xml \
    config/config.xml