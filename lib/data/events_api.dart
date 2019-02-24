import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:html_unescape/html_unescape.dart';

import '../models/event.dart';

class EventAPI {
  var unescape = new HtmlUnescape();
  var formatter = new DateFormat('yyyyMMdd');

  String clean(String input) {
    //can edit to add tag stripping later
    return unescape.convert(input);
  }

  Event getEvent(dynamic json) {
    return Event(
      eventId: json['eventID'].toString(),
      title: clean(json['title']),
      description: clean(json['description']),
      organization: clean(json['customFields'][0]['value']),
      //edit to reflect offset as well
      startTime: DateTime.parse(json['startDateTime']),
      endTime: DateTime.parse(json['endDateTime']),
      location: clean(json['location']),
    );
  }

  Future<http.Response> apiCall(Map<String, String> args) {
    //strip out last character later
    String url = 'http://25livepub.collegenet.com/calendars/NJIT_EVENTS.json?';

    args.forEach((String key, String val) {
      url += key + "=" + val + "&";
    });

    url = url.substring(0, url.length - 1);
    return http.get(url);
  }

  //maybe combine event on day and events between?
  //returns all events happening on this particular day
  Future<List<Event>> eventsOnDay(DateTime startDay) {
    DateTime realStart = startDay.subtract(Duration(hours: startDay.hour, 
                               minutes: startDay.minute, 
                               seconds: startDay.second,
                               milliseconds: startDay.millisecond));
    DateTime endTime = realStart.add(Duration(days:1));
    return eventsBetween(realStart, endTime);
  }

  Future<List<Event>> eventsBetween(DateTime start, DateTime end) {
    Map<String, String> args = {
      'startdate': formatter.format(start),
      'enddate': formatter.format(end),
    };

    return apiCall(args).then((http.Response response) {
      final Iterable resultData = json.decode(response.body);

      List<Event> fetchedEventList = [];
      resultData.forEach((eventData) {
        fetchedEventList.add(getEvent(eventData));
      });
      return fetchedEventList;
    }).catchError((Function onError) {
      print("api error");
      return [];
    });
  }
}
