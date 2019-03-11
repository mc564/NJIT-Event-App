import 'package:flutter/material.dart';

//keeps track of a certain day, its week end and start
class DateProvider{

  DateTime _day;
  DateTime _weekStart;
  DateTime _weekEnd;

  DateProvider({@required initialDay}){
    _day = initialDay;
    _resetWeekStartAndEnd();
  }

  DateTime get currentDay => _day;
  DateTime get currentWeekStart => _weekStart;
  DateTime get currentWeekEnd => _weekEnd;

  void _resetWeekStartAndEnd() {
    int weekday = (_day.weekday % 7);
    _weekStart = _day.subtract(Duration(days: weekday));
    _weekEnd = _day.add(Duration(days: 6 - weekday));
  }

  void addOneDay(){
    //add 2 more hours to account for daylight savings time, then create a new object
    //with all other smaller and equal time units set to 0
    _day = _day.add(Duration(hours:26));
    _day = DateTime(_day.year, _day.month, _day.day);
    _resetWeekStartAndEnd();
  }

  void subtractOneDay(){
    _day = _day.subtract(Duration(hours:26));
    _day = DateTime(_day.year, _day.month, _day.day);
    _resetWeekStartAndEnd();
  }

  void addOneWeek(){
    _day = _day.add(Duration(days:7));
    _day = DateTime(_day.year, _day.month, _day.day);
    _resetWeekStartAndEnd();
  }

  void subtractOneWeek(){
    _day = _day.subtract(Duration(days:7));
    _day = DateTime(_day.year, _day.month, _day.day);
    _resetWeekStartAndEnd();
  }

  //resets day to the first of the next month
  void addOneMonth(){
    int month = _day.month;
    int year = _day.year;
    if(month==12) _day = DateTime(year+1, 1, 1);
    else _day = DateTime(year, month+1, 1);
    _resetWeekStartAndEnd();
  }

  //resets day to the first of the previous month
  void subtractOneMonth(){
    int month = _day.month;
    int year = _day.year;
    if(month==1) _day = DateTime(year-1, 12, 1);
    else _day = DateTime(year, month-1, 1);
    _resetWeekStartAndEnd();
  }
}