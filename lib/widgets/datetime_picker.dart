import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class DateTimePicker extends StatefulWidget {
  final String _label;
  Function _update;

  DateTimePicker(this._label, this._update);

  @override
  State<StatefulWidget> createState() {
    return _DateTimePickerState(_label, _update);
  }
}

class _DateTimePickerState extends State<DateTimePicker> {
  String _label;
  DateTime _time;
  Function _update;

  _DateTimePickerState(String label, Function update) {
    this._label = label;
    _time = DateTime.now();
    _update = update;
    _update(_time);
  }

  @override
  Widget build(BuildContext context) {
    var dateFormatter = new DateFormat('MMM E d ');
    var timeFormatter = new DateFormat.jm();

    return FlatButton(
      onPressed: () {
        DatePicker.showDateTimePicker(context,
            showTitleActions: true, onConfirm: (date) {
          print(date.toLocal());
          setState(() {
            _time = date;
            _update(date);
          });
        }, currentTime: _time, locale: LocaleType.en);
      },
      child: Text(
        _label +
            " " +
            dateFormatter.format(_time) +
            timeFormatter.format(_time),
        style: TextStyle(
          color: Color(0xFF33FF33),
          fontSize: 20.0,
        ),
      ),
    );
  }
}
