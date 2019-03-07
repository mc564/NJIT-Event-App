import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import './daily_event_list.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatelessWidget {
  final DateFormat dayFormatter = DateFormat('EEE, MMM d, yyyy');

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
                return DailyEventListPage(
                    title: 'Events for ' + dayFormatter.format(dayPressed),
                    day: dayPressed);
              },
            ),
          );
        },
      ),
    );
  }
}
