import 'dart:async';
import '../providers/date_provider.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

//manages the current date as shown by the view
class DateBloc {
  //changed this to DateLoaded because I don't have any
  //async processing in the datebloc
  final StreamController<DateLoaded> _dateController;
  final DateProvider _dateProvider;
  DateLoaded _initialDate;

  //TODO fix the daylight savings issue...

  DateBloc({@required DateTime initialDay})
      : assert(initialDay != null),
        _dateProvider = DateProvider(initialDay: initialDay),
        _dateController = StreamController() {
    _initialDate = DateLoaded(
        day: _dateProvider.currentDay,
        weekStart: _dateProvider.currentWeekStart,
        weekEnd: _dateProvider.currentWeekEnd);
  }

  DateLoaded get initialState => _initialDate;

  Stream get getDate => _dateController.stream;

  void _alertDateLoaded() {
    _dateController.sink.add(DateLoaded(
        day: _dateProvider.currentDay,
        weekStart: _dateProvider.currentWeekStart,
        weekEnd: _dateProvider.currentWeekEnd));
  }

  void toNextDay() {
    _dateProvider.addOneDay();
    _alertDateLoaded();
    print('to next day: ' + _dateProvider.currentDay.toString());
  }

  void toPrevDay() {
    _dateProvider.subtractOneDay();
    _alertDateLoaded();
    print('to prev day: ' + _dateProvider.currentDay.toString());
  }

  void toNextWeek() {
    _dateProvider.addOneWeek();
    _alertDateLoaded();
  }

  void toPrevWeek() {
    _dateProvider.subtractOneWeek();
    _alertDateLoaded();
  }

  void toNextMonth() {
    _dateProvider.addOneMonth();
    _alertDateLoaded();
  }

  void toPrevMonth() {
    _dateProvider.subtractOneMonth();
    _alertDateLoaded();
  }

  void dispose() {
    _dateController.close();
  }
}

abstract class DateState extends Equatable {
  DateState([List args = const []]) : super(args);
}

class DateLoaded extends DateState {
  final DateTime day;
  final DateTime weekStart;
  final DateTime weekEnd;
  DateLoaded(
      {@required this.day, @required this.weekStart, @required this.weekEnd})
      : super([day, weekStart, weekEnd]);
}
