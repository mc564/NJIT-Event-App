import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/add_page.dart';
import './pages/calendar_page.dart';

import './scoped_models/events.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final EventsModel _model = EventsModel();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<EventsModel>(
      model: _model,
      child: MaterialApp(
        title: 'NJIT Event Planner',
        //look up theme: ThemeData()

        //home: MyHomePage(title: 'Flutter Demo Home Page'),
        routes: {
          '/': (BuildContext context) => CalendarPage(),
          '/add': (BuildContext context) => AddPage(),
        },
      ),
    );
  }
}
