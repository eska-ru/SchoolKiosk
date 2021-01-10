import QtQuick 2.12

Item {
    id: root
    width: 800
    height: 2160

    signal clicked();
    property alias logoUrl: logo.source
    property alias schoolName: name.text
    property alias schoolDescription: description.text
    property alias schoolCity: city.text

    FontLoader {
        id: boldFont
        source: "qrc:/fonts/YanoneKaffeesatz-Bold.otf"
    }

    Image {
        id: logo
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.top: parent.top
        anchors.topMargin: 300
        height: width
        fillMode: Image.PreserveAspectFit
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.top: logo.bottom
        anchors.topMargin: 50
        spacing: 40

        Text {
            id: name
            width: parent.width
            font.family: boldFont.name
            wrapMode: Text.WordWrap
            font.pixelSize: 100
            color: "#fcf8ec"
            font.bold: true
        }
        Text {
            id: description
            width: parent.width
            font.family: boldFont.name
            wrapMode: Text.WordWrap
            font.pixelSize: 70
            color: "#fcf8ec"
            font.bold: true
        }
        Rectangle {
            id: line
            color: "#fcf8ec"
            width: parent.width
            height: 4
            radius: 2
        }

        Text {
            id: city
            width: parent.width
            font.family: boldFont.name
            wrapMode: Text.WordWrap
            font.pixelSize: 70
            color: "#fcf8ec"
            font.bold: true
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked();
    }
}
