import 'package:flutter/material.dart';

class Event {
  final String location;
  final String title;
  final DateTime time;
  final String organization;
  final String description;

  Event({
    @required this.location,
    @required this.title,
    @required this.time,
    @required this.organization,
    @required this.description,
  });
}
