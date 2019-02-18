import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CalendarCarousel(
        onDayPressed: (DateTime date, List<dynamic> list) {
         // Navigator.pushReplacementNamed(context, '/products')
          /*
            showDialog(
                context: context, 
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text('hi wat up'),
                  );
                });
                */
        },
      ),
    );
  }
}
