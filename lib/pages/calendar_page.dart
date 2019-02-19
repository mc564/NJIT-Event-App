import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CalendarCarousel(
        onDayPressed: (DateTime date, List<dynamic> list) {
         Navigator.pushNamed(context, '/detail');
        },
      ),
    );
  }
}
