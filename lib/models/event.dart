import 'package:flutter/material.dart';
import './category.dart';
import './location.dart';

class Event {
  final String eventId;
  final String location;
  final Location locationCode;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String organization;
  final Category category;
  final String description;
  bool favorited;

  Event({
    @required this.eventId,
    @required this.location,
    @required this.locationCode,
    @required this.title,
    @required this.startTime,
    @required this.endTime,
    @required this.organization,
    @required this.category,
    @required this.description,
    @required this.favorited,
  });

  @override
  String toString() {
    return "Event[title: " + title + "]";
  }
}

