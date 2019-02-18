import 'package:flutter/material.dart';

import './pages/add_page.dart';
import './pages/calendar_page.dart';
import './pages/event_detail.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NJIT Event Planner',
      //look up theme: ThemeData()

      //home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/': (BuildContext context) => CalendarPage(),
        '/add': (BuildContext context) => AddPage(),
        '/detail': (BuildContext context) => EventDetailPage(),
      },
    );
  }
}

