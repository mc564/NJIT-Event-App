import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../models/event.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/event_details.dart';
import '../models/user.dart';
import '../models/organization.dart';

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
      favorited: false,
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

  Future<List<String>> getFavorites(String ucid) {
    return http
        .get("https://web.njit.edu/~mc564/eventapi/favorite/read.php?ucid=" +
            ucid)
        .then((http.Response response) {
      final Map favorites = json.decode(response.body);
      List<String> fetchedEventIdList = [];
      if (!favorites.containsKey('records')) return fetchedEventIdList;

      favorites['records'].forEach((fave) {
        fetchedEventIdList.add(fave['eventId']);
      });
      return fetchedEventIdList;
    }).catchError((error) {
      throw Exception(
          "Error in Database class getFavorites method: " + error.toString());
    });
  }

  Future<bool> addFavorite(String eventId, String ucid) {
    print('ADDING FAVORITE');
    Map<String, dynamic> favoriteMap = {
      'ucid': ucid,
      'eventId': eventId,
    };
    return http
        .post('https://web.njit.edu/~mc564/eventapi/favorite/add.php',
            body: json.encode(favoriteMap))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class addFavorite method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception(
          "Error in Database class addFavorite method: " + error.toString());
    });
  }

  Future<bool> removeFavorite(String eventId, String ucid) {
    print('REMOVING FAVORITE');
    Map<String, dynamic> favoriteMap = {
      'ucid': ucid,
      'eventId': eventId,
    };
    return http
        .post('https://web.njit.edu/~mc564/eventapi/favorite/remove.php',
            body: json.encode(favoriteMap))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class removeFavorite method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception(
          "Error in Database class removeFavorite method: " + error.toString());
    });
  }

  Future<Event> getEventWithId(String eventId) {
    return http
        .get(
            "https://web.njit.edu/~mc564/eventapi/event/readRecord.php?eventId=" +
                eventId)
        .then((http.Response response) {
      final Map jsonResponse = json.decode(response.body);
      Event matchingEvent;
      if (!jsonResponse.containsKey('records')) return matchingEvent;
      jsonResponse['records'].forEach((record) {
        matchingEvent = getEvent(record);
      });
      return matchingEvent;
    }).catchError((error) {
      throw Exception(
          "Error in Database class getEventWithId method: " + error.toString());
    });
  }

  Future<List<Event>> getEventsWithIds(List<String> eventIds) async {
    try {
      List<Event> fetchedEventList = List<Event>();
      if (eventIds != null && eventIds.length > 0) {
        Map<String, dynamic> argMap = {'eventIds': eventIds};
        http.Response response = await http.post(
            'https://web.njit.edu/~mc564/eventapi/event/readRecords.php',
            body: json.encode(argMap));
        final Map jsonResponse = json.decode(response.body);
        jsonResponse['records'].forEach((eventData) {
          fetchedEventList.add(getEvent(eventData));
        });
      }
      return fetchedEventList;
    } catch (error) {
      throw Exception("Error in Database class getEventsWithIds method: " +
          error.toString());
    }
  }

  //basically just gets view counts for right now..
  Future<EventDetails> getEventDetails(Event event) {
    return http
        .get(
            "https://web.njit.edu/~mc564/eventapi/eventDetails/read.php?eventId=" +
                event.eventId)
        .then((http.Response response) {
      final Map jsonResponse = json.decode(response.body);
      EventDetails details = EventDetails();
      if (!jsonResponse.containsKey('records')) return details;
      jsonResponse['records'].forEach((record) {
        details.eventId = record['eventId'];
        details.thisWeekViewCount = int.parse(record['viewsThisWeek']);
        details.lastWeekViewCount = int.parse(record['viewsLastWeek']);
      });
      return details;
    }).catchError((error) {
      throw Exception("Error in Database class getEventDetails method: " +
          error.toString());
    });
  }

  Future<List<EventDetails>> bulkReadEventDetails(List<Event> events) {
    Map<String, dynamic> map = {
      'eventIds': events.map((Event e) => e.eventId).toList(),
    };
    return http
        .post("https://web.njit.edu/~mc564/eventapi/eventDetails/readBulk.php?",
            body: json.encode(map))
        .then((http.Response response) {
      final Map jsonResponse = json.decode(response.body);
      List<EventDetails> details = List<EventDetails>();
      if (!jsonResponse.containsKey('records')) return details;
      jsonResponse['records'].forEach((record) {
        EventDetails newDetail = EventDetails();
        newDetail.eventId = record['eventId'];
        newDetail.thisWeekViewCount = int.parse(record['viewsThisWeek']);
        newDetail.lastWeekViewCount = int.parse(record['viewsLastWeek']);
        details.add(newDetail);
      });
      return details;
    }).catchError((error) {
      throw Exception("Error in Database class bulkReadEventDetails method: " +
          error.toString());
    });
  }

  //called every time an event detail page is accessed
  Future<bool> incrementViewCount(Event event) {
    Map<String, dynamic> map = {
      'eventId': event.eventId,
    };
    return http
        .post('https://web.njit.edu/~mc564/eventapi/eventDetails/addView.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class incrementViewCount method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class incrementViewCount method: " +
          error.toString());
    });
  }

  //initial information for a user that would be useful to have upon login - favorites, organizations they're a part of, etc.
  Future<Map<String, dynamic>> userInitialInfo(String ucid) async {
    try {
      Map<String, dynamic> rtn = Map<String, dynamic>();
      rtn['ucid'] = ucid;
      http.Response response = await http.get(
          "https://web.njit.edu/~mc564/eventapi/user/read.php?ucid=" + ucid);
      final Map jsonResponse = json.decode(response.body);
      List<UserTypes> types = List<UserTypes>();
      if (jsonResponse.containsKey('types')) {
        for (String type in jsonResponse['types']) {
          types.add(UserTypeHelper.stringToUserType(type));
        }
      }
      rtn['types'] = types;

      List<String> favoriteIds = List<String>();
      if (jsonResponse.containsKey('favorites')) {
        for (String favorite in jsonResponse['favorites'])
          favoriteIds.add(favorite);
      }
      rtn['favorites'] = favoriteIds;

      Map<String, String> organizationalRoles = Map<String, String>();
      if (jsonResponse.containsKey('organizations')) {
        for (Map org in jsonResponse['organizations']) {
          organizationalRoles[org['organization']] = org['role'];
        }
      }
      rtn['organizations'] = organizationalRoles;
      return rtn;
    } catch (error) {
      throw Exception("Error in Database class userInitialInfo method: " +
          error.toString());
    }
  }

  Future<bool> addOrganization(Organization org) {
    Map<String, String> memberRoles = Map<String, String>();
    if (org.eBoardMemberUCIDsToRoles != null &&
        org.eBoardMemberUCIDsToRoles.length > 0) {
      memberRoles = Map<String, String>.from(org.eBoardMemberUCIDsToRoles);
    }
    if (org.regularMemberUCIDs != null && org.regularMemberUCIDs.length > 0) {
      for (String ucid in org.regularMemberUCIDs) {
        memberRoles[ucid] = 'Member';
      }
    }

    Map<String, dynamic> map = {
      'name': org.name,
      'description': org.description,
      'members': memberRoles
    };
    return http
        .post('https://web.njit.edu/~mc564/eventapi/organization/add.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class addOrganization method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class addOrganization method: " +
          error.toString());
    });
  }
}
