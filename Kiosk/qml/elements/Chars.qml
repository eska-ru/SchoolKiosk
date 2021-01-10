import QtQuick 2.0
import QtQuick.XmlListModel 2.0

Item {
    property XmlListModel model
    property int classNumber
    signal clicked(var classId, string classChar)

    id: root

    onClassNumberChanged: {
        listModel.clear();
        if (model.status != XmlListModel.Ready) {
            return;
        }

        for (var i = 0; i < model.count; ++i) {
            var item = model.get(i);
            var className = appCodec.fromCP1251ToUtf8(item.className);
            var number = parseInt(className.match('\\d+'));
            if (number !== classNumber) {
                continue;
            }

            var c = className.match('\\D');
            listModel.append({
                                 "charValue": (c.length > 0) ? c[0] : "",
                                 "classId": item.classId
                             })
        }
    }

    Image {
        id: numberImg

        height: 480
        width: sourceSize.width / sourceSize.height * height
        fillMode: Image.PreserveAspectFit
        source: (classNumber > 0) ? "qrc:/images/numbers/level_" + classNumber + ".svg" : ""
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
        id: vLine
        source: "qrc:/images/vline.png"
        height: numberImg.height
        width: sourceSize.width / sourceSize.height * height
        fillMode: Image.PreserveAspectFit
        anchors.left: numberImg.right
        anchors.leftMargin: 30
        anchors.verticalCenter: parent.verticalCenter
    }


    GridView {
        id: gridView

        anchors.left: vLine.right
        anchors.leftMargin: 30
        anchors.right: parent.right
        height: parent.height

        model: ListModel {
            id: listModel
        }

        cellHeight: 240
        cellWidth: width/5

        delegate: Item {
            width: gridView.cellWidth
            height: gridView.cellHeight

            Image {
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height / 1.2
                width: parent.width
                fillMode: Image.PreserveAspectFit
                smooth: true

                Component.onCompleted: {
                    source = "qrc:/images/chars/3" + gridView.getCharImageUrl(charValue) + ".png";
                }
            }


            Rectangle {
                id: fog
                anchors.fill: parent
                color: "white"
                opacity: 0
                radius: 30

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
                    fogOn.start();
                }

                onReleased: {
                    fogOff.start();
                }

                onClicked: {
                    root.clicked(classId, charValue)
                }
            }
        }

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
