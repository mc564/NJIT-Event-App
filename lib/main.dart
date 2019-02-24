import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/add.dart';
import './pages/home.dart';

import './scoped_models/events.dart';
import './widgets/success_dialog.dart';

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
        theme: ThemeData(
          // Define the default Brightness and Colors
          brightness: Brightness.dark,
          primaryColor: Colors.black,
          accentColor: Colors.red,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.black,
            labelStyle: TextStyle(
              color: Colors.blueGrey,
            ),
          ),
        ),

        //home: MyHomePage(title: 'Flutter Demo Home Page'),
        routes: {
          '/': (BuildContext context) => HomePage(_model),
          '/add': (BuildContext context) => AddPage(),
        },
      ),
    );
  }
}
