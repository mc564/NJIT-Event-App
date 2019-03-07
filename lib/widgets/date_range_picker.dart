import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//NO, make all children widgets stateless and keep the state in the parent widget,
//the parent widget can then remake the children whenever needed
class DateRangePicker extends StatefulWidget {
  final DateTime _initialStartTime;
  final DateTime _initialEndTime;
  final Function _onStartChanged;
  final Function _onEndChanged;

  DateRangePicker(
      {DateTime initialStartTime,
      DateTime initialEndTime,
      Function onStartChanged,
      Function onEndChanged})
      : _initialStartTime = initialStartTime,
        _initialEndTime = initialEndTime,
        _onStartChanged = onStartChanged,
        _onEndChanged = onEndChanged;

  @override
  State<StatefulWidget> createState() {
    return _DateRangePickerState();
  }
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTime _startDateTime;
  DateTime _endDateTime;

  @override
  void initState() {
    super.initState();
    _startDateTime = widget._initialStartTime;
    _endDateTime = widget._initialEndTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DateTimePicker(
          label: ' Start Time:',
          dateTime: _startDateTime,
          callback: (DateTime newDateTime) {
            setState(() {
              _startDateTime = newDateTime;
              widget._onStartChanged(_startDateTime);
              if (_startDateTime.isAfter(_endDateTime)) {
                _endDateTime = _startDateTime.add(Duration(hours: 1));
                widget._onEndChanged(_endDateTime);
              }
            });
          },
        ),
        DateTimePicker(
          label: ' End Time:',
          dateTime: _endDateTime,
          callback: (DateTime newDateTime) {
            setState(() {
              _endDateTime = newDateTime;
              widget._onEndChanged(_endDateTime);
              if (_endDateTime.isBefore(_startDateTime)) {
                _startDateTime = _endDateTime.subtract(Duration(hours: 1));
                widget._onStartChanged(_startDateTime);
              }
            });
          },
        ),
      ],
    );
  }
}

//is a row with label, date and time picker in that order
//must give it the day and you can use a callback when anything changes
class DateTimePicker extends StatelessWidget {
  final String _label;
  final DateTime _dateTime;
  final Function _callback;

  DateTimePicker({String label, DateTime dateTime, Function callback})
      : _label = label,
        _dateTime = dateTime,
        _callback = callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.timer, size: 25.0, color: Colors.yellow),
          SizedBox(width: 5),
          Text(
            _label,
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(width: 10),
          DatePickerButton(_dateTime, (DateTime date) {
            DateTime newTime = DateTime(
              date.year,
              date.month,
              date.day,
              _dateTime.hour,
              _dateTime.minute,
            );
            _callback(newTime);
          }),
          SizedBox(width: 10),
          TimePickerButton(TimeOfDay.fromDateTime(_dateTime), (TimeOfDay time) {
            DateTime newTime = DateTime(
              _dateTime.year,
              _dateTime.month,
              _dateTime.day,
              time.hour,
              time.minute,
            );
            _callback(newTime);
          }),
        ],
      ),
    );
  }
}

class TimePickerButton extends StatelessWidget {
  final TimeOfDay _time;
  final Function _callback;

  String formattedTime() {
    String rtn = "";

    int hour = _time.hour;
    int minute = _time.minute;
    DayPeriod period = _time.period;

    if (hour == 0 || hour == 12 || hour == 24) {
      hour = 12;
    } else {
      hour %= 12;
    }

    if (hour >= 1 && hour <= 9) {
      rtn += "0" + hour.toString() + ":";
    } else {
      rtn += hour.toString() + ":";
    }

    if (minute >= 0 && minute <= 9) {
      rtn += "0" + minute.toString();
    } else {
      rtn += minute.toString();
    }

    if (period == DayPeriod.am) {
      rtn += " AM";
    } else {
      rtn += " PM";
    }
    return rtn;
  }

  TimePickerButton(this._time, this._callback);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.grey[200],
      padding: EdgeInsets.all(6),
      onPressed: () {
        showTimePicker(
          context: context,
          initialTime: _time,
        ).then((TimeOfDay updatedTime) {
          if (updatedTime == null) return;
          _callback(updatedTime);
        });
      },
      child: Text(
        formattedTime(),
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
      ),
    );
  }
}

class DatePickerButton extends StatelessWidget {
  final DateFormat formatter = new DateFormat('E, MMM d');
  final DateTime _date;
  final Function _callback;

  DatePickerButton(this._date, this._callback);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.grey[200],
      padding: EdgeInsets.all(6),
      onPressed: () {
        showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2018),
          lastDate: DateTime(2030),
        ).then((DateTime updatedTime) {
          if (updatedTime == null) return;
          _callback(updatedTime);
        });
      },
      child: Text(
        formatter.format(_date),
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
      ),
    );
  }
}
