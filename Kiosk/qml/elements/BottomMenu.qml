import QtQuick 2.0

Item {
    id: root
    property ListModel model
    signal clicked(string type, string data)

    ListView {
        id: row
        anchors.fill: parent
        spacing: 0
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds

        property real itemWidth: count < 7 ? width / count : width / 6

        model: parent.model

        delegate:
            SmallIcon {
            source: model.smallIconSource
            text: model.text
            color: model.color
            height: row.height
            width: row.itemWidth

            onClicked: {
                root.clicked(model.type, model.typeData);
            }
        }
    }
}
