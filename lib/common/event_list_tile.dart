import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/category.dart';
import 'package:intl/intl.dart';
import '../pages/detail/event_detail.dart';

class EventListTile extends StatelessWidget {
  final Event _event;
  final int _color;

  EventListTile(this._event, this._color);

  //formats start and end times in a nice format for reading
  String formatEventDuration(DateTime start, DateTime end) {
    DateFormat monthFormatter = DateFormat("MMMM");
    DateFormat timeFormatter = DateFormat.jm();
    if (start.day == end.day) {
      return monthFormatter.format(start) +
          " " +
          start.day.toString() +
          "  " +
          timeFormatter.format(start);
    }
    return monthFormatter.format(start) +
        " " +
        start.day.toString() +
        " - " +
        end.day.toString() +
        "  " +
        timeFormatter.format(start);
  }

  //returns a string up to 35 chars + ... if meets char limit
  String cutShort(String s) {
    if (s.length <= 35)
      return s;
    else
      return s.substring(0, 36) + "...";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(_color)),
      child: ListTile(
        leading: Image.network(
          'https://vignette.wikia.nocookie.net/line/images/b/bb/2015-brown.png/revision/latest?cb=20150808131630',
          width: 50,
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_event.title, style: TextStyle(fontSize: 18)),
            Text(cutShort(_event.location), style: TextStyle(fontSize: 15)),
            Text(formatEventDuration(_event.startTime, _event.endTime), style: TextStyle(fontSize: 14)),
            Text(CategoryHelper.getString(_event.category), style: TextStyle(fontSize: 14)),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.info,
            color: Colors.lightBlue[200],
          ),
          onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    maintainState: false,
                    builder: (BuildContext context) => EventDetailPage(_event)),
              ),
        ),
      ),
    );
  }
}
