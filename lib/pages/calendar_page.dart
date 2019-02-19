import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import './event_list.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped_models/events.dart';
import '../models/event.dart';
import '../widgets/error_dialog.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CalendarCarousel(
        onDayPressed: (DateTime date, List<dynamic> list) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                //not sure if need ScopedModelDescendant here...re-evaluate later
                return ScopedModelDescendant(
                  builder:
                      (BuildContext context, Widget child, EventsModel model) {
                        return EventListPage(model.events);
                      }
                  /*
                  builder:
                      (BuildContext context, Widget child, EventsModel model) {
                    model.getEventsOnDay(date).then((bool success) {
                      print('the model.events looks like: ' +
                          model.events.toString());
                      return EventListPage(model.events);
                    }).catchError((_) {
                      return showDialog(
                          context: context,
                          builder: (BuildContext context) => ErrorDialog());
                    });
                  },
                  */
                );
              },
            ),
          );
        },
      ),
    );
  }
}
