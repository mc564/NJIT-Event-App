import 'package:flutter/material.dart';

class Event {
  final String eventId;
  final String location;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String organization;
  final String description;

  Event({
    @required this.eventId,
    @required this.location,
    @required this.title,
    @required this.startTime,
    @required this.endTime,
    @required this.organization,
    @required this.description,
  });

  @override
  String toString() {
    return "Event[title: "+title+"]";
  }
}
