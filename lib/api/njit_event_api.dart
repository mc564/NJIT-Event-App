import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:html/parser.dart';

import '../models/event.dart';
import '../models/category.dart';
import '../models/location.dart';

class NJITEventAPI {
  var formatter = new DateFormat('yyyyMMdd');
  final Map<String, Category> categoryOf = {
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

  String clean(String htmlString) {
    var document = parse(htmlString);
    String parsedString = parse(document.body.text).documentElement.text;
    return parsedString;
  }

  Category getCategory(String rawCategory) {
    if (categoryOf.containsKey(rawCategory))
      return categoryOf[rawCategory];
    else
      return Category.Miscellaneous;
  }

  Event getEvent(dynamic json) {
    String rawCategory = clean(json['template']);
    return Event(
      eventId: json['eventID'].toString(),
      title: clean(json['title']),
      description: clean(json['description']),
      organization: clean(json['customFields'][0]['value']),
      category: getCategory(rawCategory),
      startTime: DateTime.parse(json['startDateTime']),
      endTime: DateTime.parse(json['endDateTime']),
      location: clean(json['location']),
      locationCode: LocationHelper.getLocationCode(clean(json['location'])),
    );
  }

  Future<http.Response> apiCall(Map<String, String> args) {
    String url = 'http://25livepub.collegenet.com/calendars/NJIT_EVENTS.json?';

    args.forEach((String key, String val) {
      url += key + "=" + val + "&";
    });

    url = url.substring(0, url.length - 1);
    print('event api url: '+url);
    return http.get(url).catchError((error) {
      throw Exception("Error in EventAPI class: " + error.toString());
    });
  }

  Future<List<Event>> eventsOnDay(DateTime startDay) async {
    DateTime realStart = DateTime(startDay.year, startDay.month, startDay.day);
    Map<String, String> args = {
      'startdate': formatter.format(realStart),
      'months': '0',
    };
    return apiCall(args).then((http.Response response) {
      final Iterable resultData = json.decode(response.body);

      List<Event> fetchedEventList = [];
      resultData.forEach((eventData) {
        fetchedEventList.add(getEvent(eventData));
      });
      print("api got " + resultData.length.toString() + " results ON DAY");
      return fetchedEventList;
    }).catchError((error) {
      throw Exception("Error in EventAPI class: " + error.toString());
    });
  }

  Future<List<Event>> eventsBetween(DateTime start, DateTime end) {
    int days = DateTime(end.year, end.month, end.day)
            .difference(DateTime(start.year, start.month, start.day))
            .inDays +
        1;

    Map<String, String> args = {
      'startdate': formatter.format(start),
      'days': days.toString(),
      'events': '1000'
    };

    return apiCall(args).then((http.Response response) {
      final Iterable resultData = json.decode(response.body);

      List<Event> fetchedEventList = [];
      resultData.forEach((eventData) {
        fetchedEventList.add(getEvent(eventData));
      });
      print("api got " + resultData.length.toString() + " results BETWEEN");
      return fetchedEventList;
    }).catchError((error) {
      throw Exception("Error in EventAPI class: " + error.toString());
    });
  }
}
