import 'package:flutter/material.dart';
import './event_list_tile.dart';
import '../models/event.dart';

class DailyEventList extends StatelessWidget {
  final List<Event> _events;
  final DateTime _day;

  DateTime get day => _day;

  List<Event> get list => _events;

  DailyEventList({@required List<Event> events, DateTime day, Key key})
      : _events = events,
        _day = day,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<int> colors = [
      0xffffdde2,
      0xffFFFFCC,
      0xffdcf9ec,
      0xffFFFFFF,
      0xffF0F0F0,
    ];

    if (_events.length == 0) return Center(child: Text('No events matching the criteria on this day!'));

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (BuildContext context, int index) {
        return EventListTile(_events[index], colors[index % colors.length]);
      },
    );
  }
}
