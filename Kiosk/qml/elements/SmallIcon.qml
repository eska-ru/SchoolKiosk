import QtQuick 2.12

Rectangle {
    id: root
    property alias source: image.source
    property alias text: title.text
    signal clicked

    FontLoader {
        id: boldFont
        source: "qrc:/fonts/YanoneKaffeesatz-Bold.otf"
    }

    Image {
        id: image
        height: 160
        width: (sourceSize.width < sourceSize.height) ? height * sourceSize.width / sourceSize.height : 160
        smooth: true
        antialiasing: true
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 40
    }

    Text {
        id: title
        font.family: boldFont.name
        font.pointSize: 72
        fontSizeMode: Text.Fit
        font.weight: Font.Bold
        font.letterSpacing: 1.2
        wrapMode:  Text.WordWrap
        height: image.height
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.capitalization: Font.AllUppercase
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: image.right
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
    }

    Rectangle {
        id: fog
        anchors.fill: parent
        color: "white"
        opacity: 0

        NumberAnimation {
            id: fogOn
            target: fog
            property: "opacity"
            duration: 100
            to: 0.6
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
