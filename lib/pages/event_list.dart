import 'package:flutter/material.dart';
import '../widgets/event_card.dart';
import '../models/event.dart';
import '../scoped_models/events.dart';

class EventListPage extends StatelessWidget {
  List<Event> _events;

  EventListPage(this._events);

  @override
  Widget build(BuildContext context) {
    if (_events == null){
      return Scaffold(
        appBar: AppBar(
          title: Text('null _events eventlist'),
        ),
      );
    }

    print('list length is: ' + _events.length.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
      ),
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(title: Text('title')); //EventCard(_eventList[index]);
        },
      ),
    );
  }
}
