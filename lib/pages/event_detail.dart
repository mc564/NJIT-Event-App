import 'package:flutter/material.dart';
import '../models/event.dart';

class EventDetailPage extends StatelessWidget {
  Event _event;

  EventDetailPage(this._event);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: Card(
        color: Colors.red,
      ),
    );
  }
}
