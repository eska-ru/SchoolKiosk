TEMPLATE = subdirs

CONFIG += ordered

SUBDIRS += \
    Kiosk \
    Installer

DISTFILES += \
    appveyor.yml \
    initFiles/logo.png \
    initFiles/RegTweaks.reg
