import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:html/parser.dart';

import '../models/event.dart';
import '../models/category.dart';
import '../models/location.dart';

class NJITEventAPI {
  static DateFormat formatter = new DateFormat('yyyyMMdd');
  static final Map<String, Category> categoryOf = {
    'Arts & Entertainment': Category.ArtsAndEntertainment,
    'Alumni & Friends': Category.AlumniAndUniversity,
    'Athletics': Category.Sports,
    'Community (Newark Area)': Category.Community,
    'Conference, Fair': Category.Conferences,
    'Exams (Non-Academic)': Category.Miscellaneous,
    'Intramurals & Recreation': Category.ArtsAndEntertainment,
    'Lecture, Seminar, Workshop': Category.MeetAndLearn,
    'Market Place': Category.MarketPlace,
    'Meeting, Forum': Category.MeetAndLearn,
    'Other': Category.Miscellaneous,
    'Reception, Banquet, Party': Category.Celebrations,
    'Special University Events': Category.AlumniAndUniversity,
    'Thesis, Dissertation Defense': Category.Miscellaneous,
    'Wellness': Category.HealthAndWellness,
  };

  static String _clean(String htmlString) {
    var document = parse(htmlString);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

  static Category _getCategory(String rawCategory) {
    if (categoryOf.containsKey(rawCategory))
      return categoryOf[rawCategory];
    else
      return Category.Miscellaneous;
  }

  static Event _getEvent(dynamic json) {
    String rawCategory = _clean(json['template']);
    return Event(
      eventId: json['eventID'].toString(),
      title: _clean(json['title']),
      description: _clean(json['description']),
      organization: _clean(json['customFields'][0]['value']),
      category: _getCategory(rawCategory),
      startTime: DateTime.parse(json['startDateTime']),
      endTime: DateTime.parse(json['endDateTime']),
      location: _clean(json['location']),
      locationCode: LocationHelper.getLocationCode(_clean(json['location'])),
      favorited: false,
    );
  }

  static Future<http.Response> _apiCall(Map<String, String> args) {
    String url = 'http://25livepub.collegenet.com/calendars/NJIT_EVENTS.json?';

    args.forEach((String key, String val) {
      url += key + "=" + val + "&";
    });

    url = url.substring(0, url.length - 1);
    print('event api url: ' + url);
    return http.get(url).catchError((error) {
      throw Exception("Error in EventAPI class: " + error.toString());
    });
  }

  static Future<List<Event>> eventsOnDay(DateTime startDay) async {
    DateTime realStart = DateTime(startDay.year, startDay.month, startDay.day);
    Map<String, String> args = {
      'startdate': formatter.format(realStart),
      'months': '0',
    };
    return _apiCall(args).then((http.Response response) {
      final Iterable resultData = json.decode(response.body);

      List<Event> fetchedEventList = [];
      resultData.forEach((eventData) {
        fetchedEventList.add(_getEvent(eventData));
      });
      print("api got " + resultData.length.toString() + " results ON DAY");
      return fetchedEventList;
    }).catchError((error) {
      throw Exception("Error in EventAPI class: " + error.toString());
    });
  }

  static Future<List<Event>> eventsBetween(DateTime start, DateTime end) {
    int days = DateTime(end.year, end.month, end.day)
            .difference(DateTime(start.year, start.month, start.day))
            .inDays +
        1;

    Map<String, String> args = {
      'startdate': formatter.format(start),
      'days': days.toString(),
      'events': '1000'
    };

    return _apiCall(args).then((http.Response response) {
      final Iterable resultData = json.decode(response.body);

      List<Event> fetchedEventList = [];
      resultData.forEach((eventData) {
        fetchedEventList.add(_getEvent(eventData));
      });
      print("api got " + resultData.length.toString() + " results BETWEEN");
      return fetchedEventList;
    }).catchError((error) {
      throw Exception("Error in EventAPI class: " + error.toString());
    });
  }

  static Future<Event> getEventWithId(String eventId) {
    Map<String, String> args = {
      'eventid': eventId,
    };

    return _apiCall(args).then((http.Response response) {
      final Iterable resultData = json.decode(response.body);
      if (resultData != null && resultData.length > 0) {
        return _getEvent(resultData.first);
      } else {
        return null;
      }
    }).catchError((error) {
      throw Exception("Error in EventAPI class: " + error.toString());
    });
  }

  //bulk get events with ids
  static Future<List<Event>> getEventsWithIds(List<String> eventIds) async {
    List<Event> fetchedEventList = [];
    if (eventIds == null || eventIds.length == 0) return fetchedEventList;

    String ids = '';
    for (String id in eventIds) {
      ids += id + ",";
    }
    Map<String, String> args = {
      'eventids': ids,
    };

    return _apiCall(args).then((http.Response response) {
      final Iterable resultData = json.decode(response.body);

      resultData.forEach((eventData) {
        fetchedEventList.add(_getEvent(eventData));
      });
      return fetchedEventList;
    }).catchError((error) {
      throw Exception("Error in EventAPI class, getEventsWithIds method: " +
          error.toString());
    });
  }
}
