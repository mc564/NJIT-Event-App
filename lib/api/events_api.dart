import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';

import '../models/event.dart';

class EventAPI {
  //returns all events happening on this particular day
  Future<List<Event>> eventsOnDay(DateTime startDay) {
    DateTime endDay = startDay.add(new Duration(days: 1));
    var formatter = new DateFormat('yyyyMMdd');
    String startDayString = formatter.format(startDay);
    String endDayString = formatter.format(endDay);

    print('http://25livepub.collegenet.com/calendars/NJIT_EVENTS.json?startdate=$startDayString&enddate=$endDayString');

    //get? post? ..
    return http
        .get(
            'http://25livepub.collegenet.com/calendars/NJIT_EVENTS.json?startdate=$startDayString&enddate=$endDayString')
        .then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('BAD RESPONSE');
        return null;
      }
      final Map<String, dynamic> resultData = json.decode(response.body);
      print('THIS IS RESULT DATA: ' + resultData.toString());

      List<Event> fetchedEventList = [
        Event(
            description: 'Another day',
            organization: 'njit',
            time: DateTime.now(),
            title: 'title',
            location: 'loc'),
      ];
      return fetchedEventList;
    }).catchError((Function onError) {
      print('IN CATCH ERROR');
      return null;
    });
    /*
    resultData.forEach((String key, dynamic data){
      fetchedEventList.add(Event());
    });
    */
  }
}
