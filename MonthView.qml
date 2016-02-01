/*
 * Copyright (C) 2013-2014 Canonical Ltd
 *
 * This file is part of Ubuntu Calendar App
 *
 * Ubuntu Calendar App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Calendar App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.4
import Ubuntu.Components 1.3
import "dateExt.js" as DateExt
import "colorUtils.js" as Color

PageWithBottomEdge {
    id: monthViewPage
    objectName: "monthViewPage"

    property var selectedDay;

    signal dateSelected(var date);
    signal dateHighlighted(var date);

    Keys.forwardTo: [monthViewPath]

    Action {
        id: calendarTodayAction
        objectName:"todaybutton"
        iconName: "calendar-today"
        text: i18n.tr("Today")
        onTriggered: {
            currentDate = new Date().midnight()
        }
    }

    currentDate: DateExt.today();
    header: PageHeader {
        id: pageHeader

        leadingActionBar.actions: tabs.tabsAction
        trailingActionBar.actions: [
            calendarTodayAction,
            commonHeaderActions.showCalendarAction,
            commonHeaderActions.reloadAction,
            commonHeaderActions.syncCalendarAction,
            commonHeaderActions.settingsAction
        ]
        title: {
            // TRANSLATORS: this is a time formatting string,
            // see http://qt-project.org/doc/qt-5/qml-qtqml-date.html#details for valid expressions.
            // It's used in the header of the month and week views
            var monthName = currentDate.toLocaleString(Qt.locale(),i18n.tr("MMMM yyyy"))
            return monthName[0].toUpperCase() + monthName.substr(1, monthName.length - 1)
        }

        flickable: null
    }

    PathViewBase{
        id: monthViewPath
        objectName: "monthViewPath"

        property var startMonth: currentDate;

        anchors {
            fill: parent
            topMargin: header.height
        }

        onNextItemHighlighted: {
            nextMonth();
        }

        onPreviousItemHighlighted: {
            previousMonth();
        }

        function nextMonth() {
            currentDate = addMonth(currentDate, 1);
        }

        function previousMonth() {
            currentDate = addMonth(currentDate, -1);
        }

        function addMonth(date,month) {
            return  new Date(date.getFullYear(), date.getMonth() + month, 1, 0, 0, 0);
        }

        delegate: Loader {
            width: parent.width - units.gu(4)
            height: parent.height

            sourceComponent: delegateComponent
            asynchronous: index !== monthViewPath.currentIndex

            Component {
                id: delegateComponent

                MonthComponent {
                    isCurrentItem: index === monthViewPath.currentIndex

                    showEvents: true

                    displayWeekNumber: mainView.displayWeekNumber;

                    anchors.fill: parent

                    currentMonth: monthViewPath.addMonth(monthViewPath.startMonth,
                                                         monthViewPath.indexType(index));

                    selectedDay: monthViewPage.selectedDay
                    isYearView: false

                    onDateSelected: {
                        monthViewPage.dateSelected(date);
                    }

                    onDateHighlighted: {
                        monthViewPage.dateHighlighted(date);
                    }
                }
            }
        }
    }
}
