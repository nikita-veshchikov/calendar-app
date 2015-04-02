# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2013, 2014 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""
Calendar app autopilot tests for the week view.
"""

# from __future__ import range
# (python3's range, is same as python2's xrange)
import sys
if sys.version_info < (3,):
    range = xrange

import datetime
from autopilot.matchers import Eventually
from testtools.matchers import Equals
from random import randint, randrange

from calendar_app.tests import CalendarAppTestCase
import logging

logger = logging.getLogger(__name__)


class TestWeekView(CalendarAppTestCase):

    def setUp(self):
        super(TestWeekView, self).setUp()
        self.week_view = self.app.main_view.go_to_week_view()

    def _assert_week_delta(self, original_week, delta):
        current_week = self.week_view.get_current_weeknumber()
        expected_week = original_week + delta

        if expected_week < 0:
            expected_week += 53
        elif expected_week > 52:
            expected_week -= 53

        self.assertEquals(current_week, expected_week)

    def test_default_view(self):
        """By default, the week view shows the current week.
        It also displays the current year and month"""

        now = datetime.datetime.now()
        expected_month_name_year = now.strftime("%B %Y")
        self.assertThat(self.app.main_view.get_month_year(self.week_view),
                        Equals(expected_month_name_year))

        # TODO: check current day is highlighted

    # These testing stubs need completed
    # def test_scroll_week_must_scroll_within_week(self):
        # """Scrolling inside the timeline should scroll the weekdays"""
        # pass

    # def test_change_week_across_month(self):
        # """Changing week across months should update the month"""
        # pass

    # def test_change_week_across_year(self):
        # """Changing week across years should update the year"""
        # pass

    # def test_month_to_week(self):
        # """Changing from a month to weekview should
        # start weekview on the first week of the month"""
        # pass

    # def test_day_to_week(self):
        # """Changing from a day to weekview should
        # start weekview on the same week as the day"""
        # pass

    def test_change_week(self):
        """It must be possible to change weeks by swiping the timeline"""
        weeks = randint(1, 6)
        direction = randrange(-1, 1, 2)
        delta = weeks * direction
        original_week = self.week_view.get_current_weeknumber()

        self.week_view.change_week(delta)
        self._assert_week_delta(original_week, delta)

    def test_selecting_a_day_switches_to_day_view(self):
        """It must be possible to show a single day by clicking on it."""
        days = self.week_view.get_days_of_week()
        day_to_select = self.app.main_view.get_label_with_text(days[0])
        expected_day = days[0]
        dayStart = self.week_view.firstDay
        expected_month = dayStart.month
        expected_year = dayStart.year

        timeLineBase = self.week_view._get_timeline_base();
        timeline = timeLineBase.select_single(objectName="timelineview")
        while (timeline.contentX != 0):
            self.app.main_view.swipe_view(-1, self.week_view)
        self.app.pointing_device.click_object(day_to_select)

        # Check that the view changed from 'Week' to 'Day'
        day_view = self.app.main_view.get_day_view()
        self.assertThat(day_view.visible, Eventually(Equals(True)))

        # Check that the 'Day' view is on the correct/selected day.
        selected_date = \
            self.app.main_view.get_day_view().get_selected_day().startDay
        self.assertThat(expected_day, Equals(selected_date.day))
        self.assertThat(expected_month, Equals(selected_date.month))
        self.assertThat(expected_year, Equals(selected_date.year))
