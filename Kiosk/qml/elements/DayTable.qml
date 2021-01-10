import QtQuick 2.0
import QtQuick.XmlListModel 2.0

Item {
    property int dayOfWeek
    property XmlListModel model

    height: listView.x + listView.height
    width: background.width * 1.2

    Connections {
        target: model

        onStatusChanged: {
            if (model.status != XmlListModel.Ready) {
                return;
            }

            listModel.clear();

            for (var i = 0; i < model.count; ++i) {
                var item = model.get(i);

                var day = Date.fromLocaleDateString(Qt.locale(), item.day, "dd.MM.yyyy");
                var _dayOfWeek = day.getDay();


                if (_dayOfWeek !== dayOfWeek) {
                    continue;
                }

                var last;
                if (listModel.count > 0) {
                    last = listModel.get(listModel.count - 1);
                }

                if (last !== undefined && last.starttime === item.starttime) {
                    if (last.subjname !== appCodec.fromCP1251ToUtf8(item.subjname)) {
                        last.subjname = last.subjname + "\n" +
                                appCodec.fromCP1251ToUtf8(item.subjname);
                    }
                    last.roomname = last.roomname + "\n" +
                            appCodec.fromCP1251ToUtf8(item.roomname);
                } else {
                    listModel.append({
                                        starttime: item.starttime,
                                        subjname: appCodec.fromCP1251ToUtf8(item.subjname),
                                        roomname: appCodec.fromCP1251ToUtf8(item.roomname)
                                     })
                }
            }
        }
    }

    onDayOfWeekChanged: {
        switch (dayOfWeek) {
        case 1: caption.text = "ПОНЕДЕЛЬНИК"; break;
        case 2: caption.text = "ВТОРНИК"; break;
        case 3: caption.text = "СРЕДА"; break;
        case 4: caption.text = "ЧЕТВЕРГ"; break;
        case 5: caption.text = "ПЯТНИЦА"; break;
        case 6: caption.text = "СУББОТА"; break;
        }
    }

    FontLoader {
        id: regularFont
        source: "qrc:/fonts/YanoneKaffeesatz-Regular.otf"
    }

    FontLoader {
        id: thinFont
        source: "qrc:/fonts/YanoneKaffeesatz-Thin.otf"
    }

    Text {
        id: caption
        anchors.left: background.left
        anchors.right: background.right
        color: "#3F8DAA"
        font.pixelSize: 70
        font.family: regularFont.name
        horizontalAlignment: Text.AlignHCenter
    }

    Image {
        id: blueLine
        source: "qrc:/images/blueLine.svg"
        anchors.top: caption.bottom
        anchors.left: background.left
        anchors.right: background.right
    }

    Image {
        id: background

        anchors.top: blueLine.bottom
        anchors.topMargin: 10
        anchors.right: parent.right
        source: "qrc:/images/dayGrid.svg"
        height: sourceSize.height * 2
        width: sourceSize.width * 2
    }

    ListView {
        id: listView

        model: ListModel {
            id: listModel
        }

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: background.top
        anchors.bottom: background.bottom
        anchors.topMargin: 14
        anchors.bottomMargin: 4
        spacing: 4
        boundsBehavior: Flickable.StopAtBounds

        delegate: Item {
            height: listView.height/8 - listView.spacing
            width: parent.width

            Text {
                id: lessonTime
                width: background.width * 0.2
                height: parent.height
                text: starttime
                font.pixelSize: parent.height * 0.4
                font.family: thinFont.name
                color: "grey"
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: lessonName
                width: background.width * 0.73 - anchors.leftMargin
                height: parent.height
                anchors.left: lessonTime.right
                anchors.leftMargin: 6
                text: subjname
                font.pixelSize: parent.height * 0.5
                font.family: thinFont.name
                font.weight: Font.Light
                fontSizeMode: Text.Fit
                minimumPixelSize: 0
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: roomNumber
                width: background.width * 0.27 - anchors.leftMargin
                height: parent.height
                anchors.left: lessonName.right
                anchors.leftMargin: 10
                text: roomname
                font.pixelSize: parent.height * 0.5
                font.family: thinFont.name
                font.weight: Font.Light
                fontSizeMode: Text.Fit
                minimumPixelSize: 0
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
