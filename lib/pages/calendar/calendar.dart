import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import './calendar_widgets.dart';
import '../../blocs/event_bloc.dart';

class CalendarPage extends StatelessWidget {
  final EventBloc _eventBloc;
  final DateTime _selectedDay;

  CalendarPage({@required EventBloc eventBloc, @required DateTime selectedDay}) : _eventBloc = eventBloc,
  _selectedDay = selectedDay;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: CalendarCarousel(
        selectedDateTime: _selectedDay,
        onDayPressed: (DateTime dayPressed, List<dynamic> list) {
          //TODO new feature - make it so that you can see the current event counts on the calendar
          print('day pressed');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return DailyEventListPage(
                    day: dayPressed,
                    eventBloc: _eventBloc,
                    key: PageStorageKey<String>(DateTime.now().toString()));
              },
            ),
          );
        },
      ),
    );
  }
}
