import 'package:flutter/material.dart';
import '../widgets/daily_event_list.dart';
import '../models/event.dart';

class DailyEventListPage extends StatefulWidget {
  final DateTime _day;
  final String _title;

  DailyEventListPage({String title, DateTime day})
      : _title = title,
        _day = day;

  @override
  State<StatefulWidget> createState() {
    return _DailyEventListPageState();
  }
}

class _DailyEventListPageState extends State<DailyEventListPage> {
  List<Event> _events;

  @override
  Widget build(BuildContext context) {

    if (_events == null) {
      EventHelper.getEventsOnDay(widget._day).then((List<Event> events) {
        setState(() {
          _events = events;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: _events == null
          ? Center(child: CircularProgressIndicator())
          : DailyEventList(day: widget._day, events: _events),
    );
  }
}
