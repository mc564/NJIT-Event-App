import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
      ),
      body: ListView.builder(itemBuilder: (BuildContext context, int index) {

      },),
    );
  }
}
