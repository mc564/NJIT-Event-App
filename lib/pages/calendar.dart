import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import './event_list.dart';
import '../scoped_models/events.dart';

class CalendarPage extends StatelessWidget {
  final EventsModel _model;

  CalendarPage(this._model);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CalendarCarousel(
        onDayPressed: (DateTime dayPressed, List<dynamic> list) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                _model.getEventsOnDay(dayPressed);
                return EventListPage(_model);
              },
            ),
          );
        },
      ),
    );
  }
}
