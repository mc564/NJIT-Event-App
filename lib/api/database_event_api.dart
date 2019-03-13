import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../models/event.dart';
import '../models/category.dart';
import '../models/location.dart';

//communicates with a web api that allows operations on a database
class DatabaseEventAPI {
  var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');

  Event getEvent(dynamic json) {
    return Event(
      eventId: json['id'],
      organization: json['organization'],
      location: json['location'],
      locationCode:
          LocationHelper.abbrevStringToLocationCode(json['locationCode']),
      title: json['title'],
      startTime: DateTime.parse(json['startDateTime']),
      endTime: DateTime.parse(json['endDateTime']),
      description: json['description'],
      category: CategoryHelper.getCategory(json['category']),
    );
  }

  Future<bool> addEvent(Event event) {
    print('ADDING EVENT');
    Map<String, dynamic> eventMap = {
      'id': event.eventId,
      'title': event.title,
      'location': event.location,
      'locationCode': LocationHelper.getAbbreviation(
          LocationHelper.getLocationCode(event.location)),
      'startDateTime': formatter.format(event.startTime),
      'endDateTime': formatter.format(event.endTime),
      'category': CategoryHelper.getString(event.category),
      'organization': event.organization,
      'description': event.description
    };
    return http
        .post('https://web.njit.edu/~mc564/eventapi/event/add.php',
            body: json.encode(eventMap))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class addEvent method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception(
          "Error in Database class addEvent method: " + error.toString());
    });
  }

  //update the database record
  Future<bool> editEvent(Event event) {
    print('EDITING EVENT');
    Map<String, dynamic> eventMap = {
      'id': event.eventId,
      'title': event.title,
      'location': event.location,
      'locationCode': LocationHelper.getAbbreviation(
          LocationHelper.getLocationCode(event.location)),
      'startDateTime': formatter.format(event.startTime),
      'endDateTime': formatter.format(event.endTime),
      'category': CategoryHelper.getString(event.category),
      'organization': event.organization,
      'description': event.description
    };
    return http
        .post('https://web.njit.edu/~mc564/eventapi/event/edit.php',
            body: json.encode(eventMap))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class editEvent method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception(
          "Error in Database class editEvent method: " + error.toString());
    });
  }

  Future<List<Event>> eventsOnDay(DateTime startDay) async {
    DateTime realStart = startDay.subtract(Duration(
        hours: startDay.hour,
        minutes: startDay.minute,
        seconds: startDay.second,
        milliseconds: startDay.millisecond));
    DateTime endTime = realStart.add(Duration(days: 1));
    try {
      return await eventsBetween(realStart, endTime);
    } catch (error) {
      throw Exception(
          "Error in Database class eventsOnDay method: " + error.toString());
    }
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
    }).catchError((error) {
      throw Exception(
          "Error in Database class eventsBetween method: " + error.toString());
    });
  }
}
