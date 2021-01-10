import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.VirtualKeyboard 2.4
import Qt.labs.settings 1.1

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: qsTr("Kiosk")

    readonly property real xScale: window.width / 3840
    readonly property real yScale: window.height / 2160

    Settings {
        id: settings
        fileName: "settings.ini"

        property string buttonsData
        property string schoolLogoUrl
        property string schoolName
        property string schoolDescription
        property string schoolCity
    }

    // @disable-check M16
    Component.onCompleted: {
        window.showFullScreen();

        buttonsData.clear();

        var datamodel = JSON.parse(settings.buttonsData);
        for (var i = 0; i < datamodel.length; ++i) {
            buttonsData.append(datamodel[i]);
        }
    }

    ListModel {
        id: buttonsData
    }

    MainScreen {
        id: mainScreen
        x: 822 * window.xScale
        y: 82 * window.yScale
        xScale: window.xScale
        yScale: window.yScale

        model: buttonsData
    }

    Image {
        id: bgWithTransparent
        source: "qrc:/images/bg_with_transparent.png"
        anchors.fill: parent
    }

    SchoolInfoScreen {
        logoUrl: settings.schoolLogoUrl
        schoolName: settings.schoolName
        schoolDescription: settings.schoolDescription
        schoolCity: settings.schoolCity
        transform: Scale {
            xScale: window.xScale
            yScale: window.yScale
        }

        onClicked: {
            mainScreen.clicked("", "");
        }
    }

    InputPanel {
        id: inputPanel
        z: 99
        y: window.height
        width: window.width / 3
        anchors.horizontalCenter: parent.horizontalCenter

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: window.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
