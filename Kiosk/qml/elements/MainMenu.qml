import QtQuick 2.0

Item {
    id: root
    property ListModel model
    signal clicked(string type, string data)

    height: 1770
    width: 2940

    GridView {
        id: mainMenu

        anchors.fill: parent
        cellWidth: 910
        cellHeight: 815
        topMargin: 140
        leftMargin: 210

        boundsBehavior: Flickable.StopAtBounds

        model: parent.model

        delegate: BigIcon {
            source: model.bigIconSource
            text: (model.type === "url") ? model.typeData : ""

            onClicked: {
                root.clicked(model.type, model.typeData);
            }
        }
    }
}
