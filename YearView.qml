import QtQuick 2.0
import Ubuntu.Components 0.1

import "dateExt.js" as DateExt

PathViewBase {
    id: root

    property var currentYear: DateExt.today();

    signal monthSelected(var date);

    anchors.fill: parent

    onNextItemHighlighted: {
        currentYear = getDateFromYear(currentYear.getFullYear() + 1);
    }

    onPreviousItemHighlighted: {
        currentYear = getDateFromYear(currentYear.getFullYear() - 1);
    }

    function getDateFromYear(year) {
        return new Date(year,0,1,0,0,0,0);
    }

    QtObject{
        id: intern
        property var startYear: getDateFromYear(currentYear.getFullYear()-1);
    }

    delegate: Flickable{
        id: yearView
        clip: true

        property var year: getYear();

        function getYear(){
            if (index === root.currentIndex) {
                return intern.startYear;
            }
            var previousIndex = root.currentIndex > 0 ? root.currentIndex - 1 : 2

            if ( index === previousIndex ) {
                return getDateFromYear(intern.startYear.getFullYear() - 1);
            }

            return getDateFromYear(intern.startYear.getFullYear() + 1);
        }

        width: parent.width
        height: parent.height

        contentHeight: yearGrid.height + yearLabel.height + units.gu(2)
        contentWidth: width

        Column{
            width: parent.width
            spacing: units.gu(1.5)
            anchors.top: parent.top
            anchors.topMargin: units.gu(1.5)

            TodayLabel{
                id: todayLabel
            }

            Label{
                id: yearLabel
                text: yearView.year.getFullYear()
                fontSize: "x-large"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Grid{
                id: yearGrid
                rows: 6
                columns: 2

                width: parent.width - ((columns-1)* yearGrid.spacing)
                spacing: units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater{
                    model: yearGrid.rows * yearGrid.columns
                    delegate: MonthComponent{
                        monthDate: new Date(yearView.year.getFullYear(),index,1,0,0,0,0)
                        width: (parent.width - units.gu(2))/2
                        height: width * 2
                        dayLabelFontSize:"x-small"
                        dateLabelFontSize: "medium"
                        monthLabelFontSize: "medium"

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                root.monthSelected(monthDate);
                            }
                        }
                    }
                }
            }
        }
    }
}
