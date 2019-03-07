import 'package:flutter/material.dart';
import '../models/event.dart';

class EventDetailPage extends StatelessWidget {
  final Event _event;

  EventDetailPage(this._event);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              _event.title,
              style: TextStyle(fontSize: 20),
            ),
            Text('by ' + _event.organization),
            Text(_event.startTime.toString()),
            Text(_event.endTime.toString()),
            Text(_event.location),
            Text(_event.description),
          ],
        ),
      ),
    );
  }
}
