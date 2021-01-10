import QtQuick 2.12
import QtQuick.Controls 2.5
import QtWebEngine 1.8
import "elements"

Rectangle {
    id: root
    property ListModel model

    property real xScale: 1
    property real yScale: 1

    width: 2940 * xScale
    height: 2000 * yScale

    color: "#fcf8ec"

    Timer {
        id: timer
        running: false
        repeat: false

        onTriggered: clicked("", "")
    }

    function clicked(type, data) {
        if (type === "url") {
            timer.interval = 1000*60*5;
            timer.restart();
            var item;
            if (stack.depth > 1) {
                item = stack.replace(webViewComponent);
            } else {
                item = stack.push(webViewComponent);
            }
            item.url = "http://" + data;
        } else if (type === "scheduler") {
            timer.interval = 1000*60*10;
            timer.restart();
            while (stack.depth > 1) {
                stack.pop();
            }
            item = stack.push(scheduler);
            item.schoolId = data;
        } else {
            while (stack.depth > 1) {
                stack.pop();
            }
            timer.stop();
        }
    }

    StackView {
        id: stack
        height: 1770 * yScale
        width: parent.width

        initialItem: mainMenu

        Transition {
            id: enterTransition
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }

        Transition {
            id: exitTransition
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        pushEnter: enterTransition
        pushExit: exitTransition
        popEnter: enterTransition
        popExit: exitTransition
        replaceEnter: enterTransition
        replaceExit: exitTransition
    }

    Component {
        id: mainMenu

        MainMenu {
            model: root.model

            transform: Scale {
                xScale: root.xScale
                yScale: root.yScale
            }

            onClicked: {
                root.clicked(type, data);
            }
        }
    }

    Component {
        id: webViewComponent

        WebEngineView {
            settings.allowRunningInsecureContent: true
            onLoadProgressChanged: {
                timer.interval = 1000 * 60 * 5
                timer.restart();
            }
        }
    }

    Component {
        id: scheduler

        Scheduler {
            transform: Scale {
                xScale: root.xScale
                yScale: root.yScale
            }
        }
    }

    BottomMenu {
        id: bottomMenu

        transform: Scale {
            xScale: root.xScale
            yScale: root.yScale
        }

        model: parent.model
        y: root.height-height*root.yScale
        height: 230
        width: parent.width / root.xScale

        onClicked: {
            root.clicked(type, data);
        }
    }
}
