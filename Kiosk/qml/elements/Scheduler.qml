import QtQuick 2.12
import QtQuick.Controls 2.12

StackView {
    property int schoolId

    id: stack

    height: 1770
    width: 2940

    initialItem: classChooser

    Component {
        id: classChooser
        SchedulerClassChooser {
            schoolId: stack.schoolId
            onClicked: {
                var item = stack.push(table);
                item.classId = classId;
                item.classNumber = classNumber;
                item.classChar = classChar;
            }
        }
    }

    Component {
        id: table
        SchedulerTable {
        }
    }
}
