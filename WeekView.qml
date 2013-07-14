import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt
import "dataService.js" as DataService

Item{
    id: root
    anchors.fill: parent

    property var dayStart: new Date()

    //    onDayStartChanged: {
    //        timeLineView.scroll();
    //    }

    Label{
        id: todayLabel
        text: Qt.formatDateTime( new Date(),"d MMMM yyyy");
        fontSize: "large"
        width: parent.width
    }

    Label{
        id: timeLabel
        text: new Date(0, 0, 0, 0).toLocaleTimeString(Qt.locale(), i18n.tr("HH"))
        visible: false
    }

    WeekRibbon{
        id: weekRibbon
        startDay: dayStart.weekStart( Qt.locale().firstDayOfWeek);
        anchors.top: todayLabel.bottom
        anchors.left: timeLabel.right
        width: parent.width - timeLabel.width
        height: units.gu(10)

        onDaySelected: {
            root.dayStart = day
            weekViewPath.weekStart = day
            print( "####Day selected: "+ day)
        }
    }

    PathViewBase{
        id: weekViewPath

        property var weekStart: root.dayStart.addDays(7)

        anchors.top: weekRibbon.bottom
        width: parent.width
        height: parent.height - weekRibbon.height - units.gu(3)

        onNextItemHighlighted: {
            nextWeek();
        }

        onPreviousItemHighlighted: {
            previousWeek();
        }

        function nextWeek() {
            var weekStartDay= weekStart.weekStart( Qt.locale().firstDayOfWeek);
            weekStart = weekStartDay.addDays(7);

            dayStart = weekStart
            weekRibbon.startDay = dayStart.weekStart( Qt.locale().firstDayOfWeek);
        }

        function previousWeek(){
            var weekStartDay = weekStart.weekStart(Qt.locale().firstDayOfWeek);
            weekStart = weekStartDay.addDays(-7)

            dayStart = weekStart
            weekRibbon.startDay = dayStart.weekStart( Qt.locale().firstDayOfWeek);
        }

        delegate: WeekComponent {
            id: timeLineView

            width: parent.width
            height: parent.height

            weekStart: {
                if (index === weekViewPath.currentIndex) {
                    //print("currentIndex: "+ weekViewPath.weekStart);
                    return weekViewPath.weekStart;
                }
                var previousIndex = weekViewPath.currentIndex > 0 ? weekViewPath.currentIndex - 1 : 2
                if ( index === previousIndex ) {
                    var weekStartDay= weekViewPath.weekStart.weekStart( Qt.locale().firstDayOfWeek);
                    //print("previousIndex: "+ weekStartDay.addDays(-7));
                    return weekStartDay.addDays(-7);
                }

                var weekStartDay = weekViewPath.weekStart.weekStart( Qt.locale().firstDayOfWeek);
                //print("nextIndex: " + weekStartDay.addDays(0));
                return weekStartDay.addDays(0);
            }
        }
    }

//    WeekComponent{
//        id: timeLineView

//        weekStart: dayStart

//        anchors.top: weekRibbon.bottom
//        width: parent.width
//        height: parent.height - weekRibbon.height - units.gu(3)
//    }
}

