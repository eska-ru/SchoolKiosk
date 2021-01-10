import QtQuick 2.12
import QtQuick.XmlListModel 2.0
import QtQuick.Controls 2.12

Item {
    id: root
    signal clicked(int classId, int classNumber, string classChar)
    property int classNumber
    property int schoolId

    FontLoader {
        id: boldFont
        source: "qrc:/fonts/YanoneKaffeesatz-Bold.otf"
    }

    BigIcon {
        id: logo
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50
        anchors.top: parent.top
        source: "qrc:/icons/scheduler_b_icon.svg"
    }

    Text {
        id: caption
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logo.bottom
        anchors.topMargin: 30

        font.family: boldFont.name
        font.letterSpacing: 1.2
        text: "ВЫБЕРИ КЛАСС"
        color: "#B94744"
        font.pointSize: 170
        font.bold: true
    }

    Image {
        id: firstLine
        source: "qrc:/images/line.png"
        width: sourceSize.width * 2.4
        height: sourceSize.height * 2.4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 30
        anchors.top: caption.bottom
    }

    XmlListModel {
        id: classList

        source: "https://asurso.ru/api/lacc.asp?Function=GetClassListForSchool&SchoolID="+root.schoolId
        query: "/body/list/item"

        XmlRole { name: "classId"; query: "classid/string()" }
        XmlRole { name: "className"; query: "classname/string()" }

        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                fogOn.stop();
                fog.opacity = 0;
            } else {
                fogOn.start();
            }
        }
    }

    StackView {
        id: stack

        height: 500
        width: firstLine.width
        anchors.top: firstLine.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter

        initialItem: numbers
    }

    Component {
        id: numbers

        Numbers {
            model: classList

            onClicked: {
                var item = stack.push(chars);
                item.classNumber = classNumber;
                root.classNumber = classNumber;
            }
        }
    }

    Component {
        id: chars

        Chars {
            model: classList

            onClicked: {
                root.clicked(classId, classNumber, classChar)
            }
        }
    }

    Image {
        id: secondLine
        source: "qrc:/images/line.png"
        width: sourceSize.width * 2.4
        height: sourceSize.height * 2.4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 0
        anchors.top: stack.bottom
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
            duration: 3000
            to: 0.7
            easing.type: Easing.InOutQuad
        }

        MouseArea {
            anchors.fill: parent
            enabled: fog.opacity > 0
        }
    }

    AnimatedImage {
        id: loader
        source: "qrc:/images/waiter.gif"
        visible: fog.opacity > 0
        height: 100
        width: 100
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}
