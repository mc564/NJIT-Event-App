import 'package:flutter/material.dart';

import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event _event;

  EventCard(this._event);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Text('Title: ${_event.title}', style: TextStyle(fontSize: 20)),
          Text('Location: ${_event.location}'),
          Text('Description: ${_event.description}'),
        ],
      ),
    );
  }
}
