import QtQuick 2.0
import QtQuick.XmlListModel 2.0

Item {
    property XmlListModel model
    signal clicked(int classNumber);

    id: root

    Connections {
        target: model

        onStatusChanged: {
            listModel.clear();
            if (model.status != XmlListModel.Ready) {
                return;
            }

            var numbersArray = []
            for (var i = 0; i < model.count; ++i) {
                var str = parseInt(model.get(i).className.match('\\d+'));
                if (!(numbersArray.includes(str))) {
                    numbersArray.push(str);
                }
            }

            numbersArray.sort((a, b) => a - b);

            for (i = 0; i < numbersArray.length; ++i) {
                listModel.append({
                                     "number": numbersArray[i]
                                 })
            }
        }
    }

    GridView {
        id: gridView

        anchors.fill: parent

        model: ListModel {
            id: listModel
        }

        cellHeight: 240
        cellWidth: width / 6

        delegate: Item {
            width: gridView.cellWidth
            height: gridView.cellHeight

            Image {
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height / 1.2
                width: parent.width
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/numbers/level_" + number + ".svg"
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
                    root.clicked(number)
                }
            }
        }
    }


    function range(start, stop, step) {
        var a = [start], b = start;
        while (b <= stop) {
            a.push(b += step || 1);
        }
        return a;
    }
}
