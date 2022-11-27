import QtQuick 2.0
import QtQuick.XmlListModel 2.0

Item {
    property int classId
    property int classNumber
    property string classChar

    id: root

    onClassIdChanged: {
        var now = new Date(),
            after = new Date();
        after.setDate(after.getDate() + 6);

        var url = "https://asurso.ru/api/lacc.asp?Function=GetScheduleForClass&ClassID=" +
                classId + "&StartDate=" + formatDate(now) + "&EndDate=" + formatDate(after);

        lessonsList.source = url;
    }

    function formatDate(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getYear()-100;

        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;

        return [day, month, year].join('.');
    }

    XmlListModel {
        id: lessonsList

        query: "/body/list/item"

        XmlRole { name: "day"; query: "day/string()" }
        XmlRole { name: "relay"; query: "relay/number()" }
        XmlRole { name: "num"; query: "num/number()" }
        XmlRole { name: "starttime"; query: "starttime/string()" }
        XmlRole { name: "endtime"; query: "endtime/string()" }
        XmlRole { name: "subjname"; query: "subjname/string()" }
        XmlRole { name: "subjabbr"; query: "subjabbr/string()" }
        XmlRole { name: "sgname"; query: "sgname/string()" }
        XmlRole { name: "tlastname"; query: "tlastname/string()" }
        XmlRole { name: "tfirstname"; query: "tfirstname/string()" }
        XmlRole { name: "tmidname"; query: "tmidname/string()" }
        XmlRole { name: "roomname"; query: "roomname/string()" }

        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                fogOn.stop();
                fog.opacity = 0;
            } else {
                fogOn.start();
            }
        }
    }

    Item {
        anchors.topMargin: 50
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: gridView.left

        BigIcon {
            id: logo
            anchors.horizontalCenter: parent.horizontalCenter

            source: "qrc:/icons/scheduler_b_icon.svg"
        }

        Item {
            height: 400
            width: numberImg.width + charImg.width + charImg.anchors.leftMargin
            anchors.top: logo.bottom
            anchors.topMargin: 200
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                id: numberImg

                height: parent.height
                width: sourceSize.width / sourceSize.height * height
                fillMode: Image.PreserveAspectFit
                source: (classNumber > 0) ? "qrc:/images/numbers/level_" + classNumber + ".svg" : ""
            }
            Image {
                id: charImg

                height: parent.height *.7
                width: sourceSize.width / sourceSize.height * height
                fillMode: Image.PreserveAspectFit
                anchors.left: numberImg.right
                anchors.bottom: numberImg.bottom
                anchors.leftMargin: 40
                source: (classChar != "") ?
                            "qrc:/images/chars/3" + getCharImageUrl(classChar) + ".png" : ""

                function getCharImageUrl(val) {
                    val = val.toUpperCase();
                    switch(val) {
                    case 'А': return "1";
                    case 'Б': return "2";
                    case 'В': return "3";
                    case 'Г': return "4";
                    case 'Д': return "5";
                    case 'Е': return "6";
                    case 'Ж': return "7";
                    case 'З': return "8";
                    case 'К': return "9";
                    case 'И': return "10";
                    }
                }
            }
        }
    }


    GridView {
        id: gridView

        anchors.fill: parent
        anchors.leftMargin: 1000
        cellWidth: width/3
        cellHeight: height/2
        boundsBehavior: Flickable.StopAtBounds

        model: ListModel {
            id: gridModel

            ListElement {
                day : 1
            }
            ListElement {
                day : 2
            }
            ListElement {
                day : 3
            }
            ListElement {
                day : 4
            }
            ListElement {
                day : 5
            }
            ListElement {
                day : 6
            }
        }

        delegate: Item {
            height: gridView.cellHeight
            width: gridView.cellWidth
            DayTable {
                dayOfWeek: day
                model: lessonsList
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
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
