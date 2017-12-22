/*
 * Copyright (C) 2013-2016 Canonical Ltd
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
import Qt.labs.settings 1.0
import "CustomPickers"

Page {
    id: settingsPage
    objectName: "settings"

    property EventListModel eventModel
    property Settings settings: undefined
	
	function openHourPicker (element, caller, callerProperty) {
		element.highlighted = true;
		var picker = NewPickerPanel.openDatePicker(caller, callerProperty, "Hours");
		if (!picker) return;
		picker.closed.connect(function () {
		    element.highlighted = false;
		});
	}
	
    Binding {
        target: settingsPage.settings
        property: "showWeekNumber"
        value: weekCheckBox.checked
        when: settings
    }

    Binding {
        target: settingsPage.settings
        property: "showLunarCalendar"
        value: lunarCalCheckBox.checked
        when: settings
    }
	
	Binding {
        target: settingsPage.settings
        property: "workingHourStart"
        value: workingHours.hourStart
        when: settings
    }
	
    visible: false

    header: PageHeader {
        title: i18n.tr("Settings")
        leadingActionBar.actions: Action {
            text: i18n.tr("Back")
            iconName: "back"
            onTriggered: pop()
        }
    }

    RemindersModel {
        id: remindersModel
    }

    Column {
        id: settingsColumn
        objectName: "settingsColumn"

        spacing: units.gu(0.5)
        anchors { top: settingsPage.header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }

        ListItem {
            height: weekNumberLayout.height + divider.height
            ListItemLayout {
                id: weekNumberLayout
                title.text: i18n.tr("Show week numbers")
                CheckBox {
                    id: weekCheckBox
                    objectName: "weekCheckBox"
                    SlotsLayout.position: SlotsLayout.Last
                    checked: settings ? settings.showWeekNumber : false
                }
            }
        }

        ListItem {
            height: lunarCalLayout.height + divider.height
            ListItemLayout {
                id: lunarCalLayout
                title.text: i18n.tr("Show lunar calendar")
                CheckBox {
                    id: lunarCalCheckBox
                    objectName: "lunarCalCheckbox"
                    SlotsLayout.position: SlotsLayout.Last
                    checked: settings ? settings.showLunarCalendar : false
                }
            }
        }
        
        
        // Working hours
        ListItem {
            id: workingHours
            
            property date hourStart: new Date();
            property date hourEnd: new Date();
            
            
            height: workingHourLayout.height + divider.height
            ListItemLayout {
                id: workingHourLayout
                title.text: i18n.tr("Working hours")
                
                
                NewEventEntryField{
				    id: workingHourStartPicker
				    objectName: "workingHourStartPicker"

				    text: "From: " + settings? workingHours.hourStart.getDay(): "0" 
				    width: parent.width / 8
				    horizontalAlignment: Text.AlignRight

				    MouseArea{
				        anchors.fill: parent
				        onClicked: openHourPicker(workingHourStartPicker, workingHours, "hourStart")
				    }
				}
                
                NewEventEntryField{
				    id: workingHourEndPicker
				    objectName: "workingHourEndPicker"

				    text: "To: "+ settings? workingHours.hourEnd.getDay(): "0" 
				    width: parent.width / 8
				    horizontalAlignment: Text.AlignRight

				    MouseArea{
				        anchors.fill: parent
				        onClicked: openHourPicker(workingHourEndPicker, workingHours, "hourEnd")
				    }
				}
                
            }
        }
		
		//Reminder:
        ListItem {
            id: defaultReminderItem

            visible: defaultReminderOptionSelector.model && defaultReminderOptionSelector.model.count > 0
            height: visible ? defaultReminderLayout.height + divider.height : 0

            Connections {
                target: remindersModel
                onLoaded: {
                    if (!defaultReminderOptionSelector.model) {
                        return
                    }

                    for (var i=0; i<defaultReminderOptionSelector.model.count; ++i) {
                        var reminder = defaultReminderOptionSelector.model.get(i)
                        if (reminder.value === settings.reminderDefaultValue) {
                            defaultReminderOptionSelector.selectedIndex = i
                            return
                        }
                    }

                    defaultReminderOptionSelector.selectedIndex = 0
                }
            }

            SlotsLayout {
                id: defaultReminderLayout

                mainSlot: Item {
                    height: defaultReminderOptionSelector.height

                    OptionSelector {
                        id: defaultReminderOptionSelector

                        text: i18n.tr("Default reminder")
                        model: remindersModel
                        containerHeight: itemHeight * 4

                        delegate: OptionSelectorDelegate {
                            text: label
                            height: units.gu(4)
                        }

                       onDelegateClicked: settings.reminderDefaultValue = model.get(index).value
                    }
                }
            }
        }

        ListItem {
            visible: defaultCalendarOptionSelector.model && defaultCalendarOptionSelector.model.length > 0
            height: visible ? defaultCalendarLayout.height + divider.height : 0

            Component.onCompleted: {
                if (!eventModel || !defaultCalendarOptionSelector.model) {
                    return
                }

                var defaultCollectionId = eventModel.getDefaultCollection().collectionId
                for (var i=0; i<defaultCalendarOptionSelector.model.length; ++i) {
                    if (defaultCalendarOptionSelector.model[i].collectionId === defaultCollectionId) {
                        defaultCalendarOptionSelector.selectedIndex = i
                        return
                    }
                }

                defaultCalendarOptionSelector.selectedIndex = 0
            }

            SlotsLayout {
                id: defaultCalendarLayout

                mainSlot: Item {
                    height: defaultCalendarOptionSelector.height

                    OptionSelector {
                        id: defaultCalendarOptionSelector

                        text: i18n.tr("Default calendar")
                        model: settingsPage.eventModel ? settingsPage.eventModel.getWritableAndSelectedCollections() : []
                        containerHeight: (model && (model.length > 1) ? itemHeight * model.length : itemHeight)

                        Connections {
                            target: settingsPage.eventModel ? settingsPage.eventModel : null
                            onModelChanged: {
                                defaultCalendarOptionSelector.model = settingsPage.eventModel.getWritableAndSelectedCollections()
                            }
                            onCollectionsChanged: {
                                defaultCalendarOptionSelector.model = settingsPage.eventModel.getWritableAndSelectedCollections()
                            }
                        }

                        delegate: OptionSelectorDelegate {
                            text: modelData.name
                            height: units.gu(4)

                            UbuntuShape{
                                anchors {
                                    right: parent.right
                                    rightMargin: units.gu(4)
                                    verticalCenter: parent.verticalCenter
                                }

                                 width: height
                                 height: parent.height - units.gu(2)
                                 color: modelData.color
                            }
                        }

                        onDelegateClicked: settingsPage.eventModel.setDefaultCollection(model[index].collectionId)
                    }
                }
            }
        }
    }
}
