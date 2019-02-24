import 'package:flutter/material.dart';

import '../scoped_models/events.dart';
import '../pages/calendar.dart';

class HomePage extends StatelessWidget {
  EventsModel _model;

  HomePage(this._model);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            leading: Icon(Icons.search, color: Colors.blueGrey),
            title: Text('NJIT Event Planner'),
            bottom: TabBar(
              indicatorWeight: 3.0,
              tabs: <Widget>[
                Tab(child: Text('Calendar')),
                Tab(child: Text('Map')),
              ],
            )),
        body: TabBarView(
          children: <Widget>[
            CalendarPage(_model),
            Container(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add Event',
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, '/add');
          },
        ),
      ),
    );
  }
}
