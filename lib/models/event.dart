import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  bool rsvpd;

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
    this.favorited = false,
    this.rsvpd = false,
  });

  @override
  String toString() {
    DateFormat dateFormatter = DateFormat("EEE, MMM d, ").add_jm();
    return "-----Event-----\n" +
        "Title: " +
        title +
        "\nLocation: " +
        location +
        "\nCategory: " +
        CategoryHelper.getString(category) +
        "\nOrganization: " +
        organization +
        "\nStart Time: " +
        dateFormatter.format(startTime) +
        "\nEnd Time: " +
        dateFormatter.format(endTime) +
        "\nDescription: " +
        description +
        "\n---------------";
  }
}

//within 2 weeks of today (both in the past and towards the future)
class RecentEvents {
  final List<Event> pastEvents;
  final List<Event> upcomingEvents;
  RecentEvents(
      {@required List<Event> pastEvents, @required List<Event> upcomingEvents})
      : pastEvents = pastEvents,
        upcomingEvents = upcomingEvents;
}
