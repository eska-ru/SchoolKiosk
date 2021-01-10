import QtQuick 2.0

Item {
    id: root
    property alias source: image.source
    property alias text: url.text
    signal clicked

    FontLoader {
        id: lightFont
        source: "qrc:/fonts/YanoneKaffeesatz-Light.otf"
    }

    height: 675
    width: 700

    Image {
        id: image
        width: parent.width
        height: width * sourceSize.height/sourceSize.width
        fillMode: Image.PreserveAspectFit
        anchors.bottom: url.top
    }

    Text {
        id: url
        font.family: lightFont.name
        width: parent.width
        font.pointSize: 46
        fontSizeMode: Text.HorizontalFit
        font.weight: Font.Light
        color: "#7FC6E6"
        horizontalAlignment: Text.AlignHCenter
        font.capitalization: Font.AllUppercase
        anchors.bottom: parent.bottom
    }

    Rectangle {
        id: fog
        anchors.fill: parent
        color: "white"
        opacity: 0
        radius: 50

        NumberAnimation {
            id: fogOn
            target: fog
            property: "opacity"
            duration: 100
            to: 0.4
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            id: fogOff
            target: fog
            property: "opacity"
            duration: 500
            to: 0
            easing.type: Easing.InOutQuad
        }
    }


    MouseArea {
        anchors.fill: parent

        onPressed: {
            fogOn.start()
        }

        onReleased: {
            fogOff.start()
        }

        onClicked: root.clicked();
    }
}
