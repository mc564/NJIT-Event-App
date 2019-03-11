import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ViewDropDown extends StatelessWidget {
  final DateFormat dayFormatter = DateFormat('EEE, MMM d, y');
  final DateFormat weekDayFormatter = DateFormat('EEE, MMM d');
  final DateFormat monthFormatter = DateFormat('MMMM y');
  final Function _onChanged;
  final DateTime _day;
  final DateTime _weekStart;
  final DateTime _weekEnd;

  ViewDropDown(
      {Function onChanged, DateTime day, DateTime weekStart, DateTime weekEnd})
      : _onChanged = onChanged,
        _day = day,
        _weekStart = weekStart,
        _weekEnd = weekEnd;

  Container _buildColoredTag(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 14)),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropDownButton(
        'Click me to change the view!',
        [
          DropdownMenuItem(
            value: 'dailyView',
            child: Row(
              children: <Widget>[
                _buildColoredTag('Day', Color(0xffFFB2FF)),
                Text(
                  dayFormatter.format(_day),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'weeklyView',
            child: Row(
              children: <Widget>[
                _buildColoredTag('Week', Colors.yellow),
                Text(
                  weekDayFormatter.format(_weekStart) +
                      " - " +
                      weekDayFormatter.format(_weekEnd),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'monthlyView',
            child: Row(
              children: <Widget>[
                _buildColoredTag('Month', Colors.cyan),
                Text(
                  monthFormatter.format(_day),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
        (String value) {
          _onChanged(value);
        },
      ),
    );
  }
}

class DropDownButton extends StatefulWidget {
  final String _hint;
  final List<DropdownMenuItem> _items;
  final Function _callback;

  DropDownButton(this._hint, this._items, this._callback);

  @override
  State<StatefulWidget> createState() {
    return _DropDownButtonState();
  }
}

class _DropDownButtonState extends State<DropDownButton> {
  String _value;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      isExpanded: true,
      hint: Text(widget._hint, style: TextStyle(fontSize: 14)),
      items: widget._items,
      onChanged: (value) {
        setState(() {
          print(value);
          _value = value;
          widget._callback(_value);
        });
      },
      value: _value,
    );
  }
}