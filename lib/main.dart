import 'package:flutter/material.dart';

import './pages/add.dart';
import './pages/home.dart';
import 'models/event.dart';

//import './scoped_models/events.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NJIT Event Planner',
        routes: {
          '/': (BuildContext context) => HomePage(),
          '/add': (BuildContext context) => AddPage(
              getSimilarEvents: EventHelper.getSimilarEvents,
              addEvent: EventHelper.addEvent),
        },
      ),
    );
  }
}
