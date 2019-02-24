import 'package:flutter/material.dart';
import '../widgets/event_card.dart';
import '../models/event.dart';
import '../scoped_models/events.dart';

import 'package:scoped_model/scoped_model.dart';

class EventListPage extends StatefulWidget {
  EventsModel _model;

  EventListPage(this._model);

  @override
  State<StatefulWidget> createState() {
    return EventListPageState();
  }
}

class EventListPageState extends State<EventListPage> {
  List<Event> _events = [];

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, EventsModel model) {
        _events = widget._model.events;
        return Scaffold(
          appBar: AppBar(
            title: Text('Event List'),
          ),
          body: widget._model.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(_events[index].title),
                    ); //EventCard(_eventList[index]);
                  },
                ),
        );
      },
    );
  }
}
