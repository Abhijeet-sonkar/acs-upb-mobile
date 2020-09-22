import 'package:acs_upb_mobile/pages/classes/model/class.dart';
import 'package:acs_upb_mobile/pages/timetable/model/academic_calendar.dart';
import 'package:acs_upb_mobile/pages/timetable/model/events/uni_event.dart';
import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

class AllDayUniEvent extends UniEvent {
  LocalDate startDate;
  LocalDate endDate;

  AllDayUniEvent({
    String name,
    String location,
    @required LocalDate start,
    @required LocalDate end,
    @required String id,
    Color color,
    UniEventType type,
    ClassHeader classHeader,
    AcademicCalendar calendar,
  })  : startDate = start,
        endDate = end,
        super(
            name: name,
            location: location,
            start: start.atMidnight(),
            duration: Period.differenceBetweenDates(start, end.addDays(1)),
            id: id,
            color: color,
            type: type,
            classHeader: classHeader,
            calendar: calendar);

  Iterable<UniEventInstance> generateInstances(
      {DateInterval intersectingInterval}) sync* {
    String name = this.name ?? classHeader?.acronym ?? '';

    yield UniEventInstance(
      id: id,
      title: name,
      mainEvent: this,
      start: startDate.atMidnight(),
      end: endDate.addDays(1).atMidnight(),
      color: color,
    );
  }
}