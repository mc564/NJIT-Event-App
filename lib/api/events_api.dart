import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';

import '../models/event.dart';

class EventAPI {
  Future<http.Response> apiCall(Map<String, String> args) {
    //strip out last character later
    String url = 'http://25livepub.collegenet.com/calendars/NJIT_EVENTS.json?';

    args.forEach((String key, String val) {
      url += key + "=" + val + "&";
    });

    url = url.substring(0, url.length - 1);
    return http.get(url);
  }

  //returns all events happening on this particular day
  Future<List<Event>> eventsOnDay(DateTime startDay) {
    DateTime endDay = startDay.add(new Duration(days: 1));
    var formatter = new DateFormat('yyyyMMdd');

    Map<String, String> args = {
      'startdate': formatter.format(startDay),
      'enddate': formatter.format(endDay),
    };

    return apiCall(args).then((http.Response response) {
      final Iterable resultData = json.decode(response.body);

      List<Event> fetchedEventList = [];
      resultData.forEach((event) {
        fetchedEventList.add(Event(
          title: event['title'],
          description: event['description'],
          organization: 'spongebob land',
          //organization: event['customFields']['value'],
          time: DateTime.parse(event['startDateTime']),
          location: event['location'],
        ));
      });
      return fetchedEventList;
    }).catchError((Function onError) {
      return [];
    });
  }
}
