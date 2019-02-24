import '../models/event.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

//communicates with a web api that allows operations on a database
class Database {
  var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');

  Event getEvent(dynamic json) {
    return Event(
        eventId: json['id'],
        organization: json['organization'],
        location: json['location'],
        title: json['title'],
        startTime: DateTime.parse(json['startDateTime']),
        endTime: DateTime.parse(json['endDateTime']),
        description: json['description']);
  }

  Future<bool> addEvent(Event event) {
    Map<String, dynamic> eventMap = {
      'id': event.eventId,
      'title': event.title,
      'location': event.location,
      'startDateTime': formatter.format(event.startTime),
      'endDateTime': formatter.format(event.endTime),
      'organization': event.organization,
      'description': event.description
    };
    return http
        .post('https://web.njit.edu/~mc564/eventapi/event/add.php',
            body: json.encode(eventMap))
        .then((http.Response response) {
      return true;
    }).catchError(() {
      return false;
    });
  }

  Future<List<Event>> eventsOnDay(DateTime startDay) {
    DateTime realStart = startDay.subtract(Duration(hours: startDay.hour, 
                               minutes: startDay.minute, 
                               seconds: startDay.second,
                               milliseconds: startDay.millisecond));
    DateTime endTime = realStart.add(Duration(days:1));
    return eventsBetween(realStart, endTime);
  }

  Future<List<Event>> eventsBetween(DateTime start, DateTime end) {
    String formatStart = formatter.format(start);
    String formatEnd = formatter.format(end);
    return http
        .get("https://web.njit.edu/~mc564/eventapi/event/read.php?startdate='" +
            formatStart +
            "'&enddate='" +
            formatEnd +
            "'")
        .then((http.Response response) {
      final Map events = json.decode(response.body);
      List<Event> fetchedEventList = [];
      if (!events.containsKey('records')) return fetchedEventList;

      events['records'].forEach((eventData) {
        fetchedEventList.add(getEvent(eventData));
      });
      return fetchedEventList;
    }).catchError(() {
      return [];
    });
  }
}
