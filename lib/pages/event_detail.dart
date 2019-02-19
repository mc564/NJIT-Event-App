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
      body: Container(//TODO put event information here in nice ui
      ),
    );
  }
}
