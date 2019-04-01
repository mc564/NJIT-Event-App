import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../models/event.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/event_details.dart';
import '../models/user.dart';
import '../models/organization.dart';
import '../models/message.dart';

//communicates with a web api that allows operations on a database
class DatabaseEventAPI {
  static DateFormat formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');

  static Event _getEvent(dynamic json) {
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

  static Future<bool> addEvent(Event event) {
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
  static Future<bool> editEvent(Event event) {
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

  static Future<List<Event>> eventsOnDay(DateTime startDay) async {
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

  static Future<List<Event>> eventsBetween(DateTime start, DateTime end) {
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
        fetchedEventList.add(_getEvent(eventData));
      });
      return fetchedEventList;
    }).catchError((error) {
      throw Exception(
          "Error in Database class eventsBetween method: " + error.toString());
    });
  }

  static Future<List<String>> getFavorites(String ucid) {
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

  static Future<bool> addFavorite(String eventId, String ucid) {
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

  static Future<bool> removeFavorite(String eventId, String ucid) {
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

  static Future<Event> getEventWithId(String eventId) {
    return http
        .get(
            "https://web.njit.edu/~mc564/eventapi/event/readRecord.php?eventId=" +
                eventId)
        .then((http.Response response) {
      final Map jsonResponse = json.decode(response.body);
      Event matchingEvent;
      if (!jsonResponse.containsKey('records')) return matchingEvent;
      jsonResponse['records'].forEach((record) {
        matchingEvent = _getEvent(record);
      });
      return matchingEvent;
    }).catchError((error) {
      throw Exception(
          "Error in Database class getEventWithId method: " + error.toString());
    });
  }

  static Future<List<Event>> getEventsWithIds(List<String> eventIds) async {
    try {
      List<Event> fetchedEventList = List<Event>();
      if (eventIds != null && eventIds.length > 0) {
        Map<String, dynamic> argMap = {'eventIds': eventIds};
        http.Response response = await http.post(
            'https://web.njit.edu/~mc564/eventapi/event/readRecords.php',
            body: json.encode(argMap));
        final Map jsonResponse = json.decode(response.body);
        jsonResponse['records'].forEach((eventData) {
          fetchedEventList.add(_getEvent(eventData));
        });
      }
      return fetchedEventList;
    } catch (error) {
      throw Exception("Error in Database class getEventsWithIds method: " +
          error.toString());
    }
  }

  //basically just gets view counts for right now..
  static Future<EventDetails> getEventDetails(Event event) {
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

  static Future<List<EventDetails>> bulkReadEventDetails(List<Event> events) {
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
  static Future<bool> incrementViewCount(Event event) {
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

  //user types
  static Future<List<UserTypes>> userTypes(String ucid) async {
    try {
      List<UserTypes> types = List<UserTypes>();
      http.Response response = await http.get(
          "https://web.njit.edu/~mc564/eventapi/user/read.php?ucid=" + ucid);
      final Map jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('types')) {
        for (Map typeMap in jsonResponse['types']) {
          if (typeMap.containsKey('isAdmin') && typeMap['isAdmin'] == true) {
            types.add(UserTypes.Admin);
          } else if (typeMap.containsKey('isEboardMember') &&
              typeMap['isEboardMember'] == true) {
            types.add(UserTypes.E_Board);
          } else if (typeMap.containsKey('isBanned') &&
              typeMap['isBanned'] == true) {
            types.add(UserTypes.Banned);
          }
          types.add(UserTypes.Student);
        }
      }
      return types;
    } catch (error) {
      throw Exception(
          "Error in Database class userTypes method: " + error.toString());
    }
  }

  static Future<bool> banUser(String ucid) {
    Map<String, dynamic> map = {'ucid': ucid};

    return http
        .post('https://web.njit.edu/~mc564/eventapi/user/ban.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class banUser method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception(
          "Error in Database class banUser method: " + error.toString());
    });
  }

  static Future<bool> unbanUser(String ucid) {
    Map<String, dynamic> map = {'ucid': ucid};

    return http
        .post('https://web.njit.edu/~mc564/eventapi/user/unban.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class unbanUser method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception(
          "Error in Database class unbanUser method: " + error.toString());
    });
  }

  static Future<List<User>> fetchBannedUsers() async {
    try {
      http.Response response = await http
          .get("https://web.njit.edu/~mc564/eventapi/user/readBanned.php");
      final Map jsonResponse = json.decode(response.body);
      List<User> bannedUsers = List<User>();
      if (jsonResponse.containsKey('bannedUsers')) {
        for (String bannedUserUCID in jsonResponse['bannedUsers']) {
          bannedUsers.add(User(name: '', ucid: bannedUserUCID));
        }
      }
      return bannedUsers;
    } catch (error) {
      throw Exception("Error in Database class fetchBannedUsers method: " +
          error.toString());
    }
  }

  static Future<bool> assignEboardMemberType(String ucid) {
    Map<String, dynamic> map = {'ucid': ucid};

    return http
        .post(
            'https://web.njit.edu/~mc564/eventapi/user/assignEboardMemberType.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class assignEboardMemberType method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception(
          "Error in Database class assignEboardMemberType method: " +
              error.toString());
    });
  }

  static Future<bool> registerOrganization(Organization org) {
    List<List<String>> memberRoles = List<List<String>>();
    List<OrganizationMember> eBoardMembers = org.eBoardMembers;
    List<OrganizationMember> regularMembers = org.regularMembers;
    if (eBoardMembers != null && eBoardMembers.length > 0) {
      for (OrganizationMember eBoardMember in eBoardMembers) {
        memberRoles.add(<String>[eBoardMember.ucid, eBoardMember.role]);
      }
    }
    if (regularMembers != null && regularMembers.length > 0) {
      for (OrganizationMember regularMember in regularMembers) {
        memberRoles.add(<String>[regularMember.ucid, regularMember.role]);
      }
    }

    Map<String, dynamic> map = {
      'status': OrganizationStatusHelper.getString(org.status),
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
            "Error in Database class registerOrganization method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class registerOrganization method: " +
          error.toString());
    });
  }

  static Future<bool> updateOrganization(Organization org) {
    List<List<String>> memberRoles = List<List<String>>();
    List<OrganizationMember> eBoardMembers = org.eBoardMembers;
    List<OrganizationMember> regularMembers = org.regularMembers;
    if (eBoardMembers != null && eBoardMembers.length > 0) {
      for (OrganizationMember eBoardMember in eBoardMembers) {
        memberRoles.add(<String>[eBoardMember.ucid, eBoardMember.role]);
      }
    }
    if (regularMembers != null && regularMembers.length > 0) {
      for (OrganizationMember regularMember in regularMembers) {
        memberRoles.add(<String>[regularMember.ucid, regularMember.role]);
      }
    }

    Map<String, dynamic> map = {
      'status': OrganizationStatusHelper.getString(org.status),
      'name': org.name,
      'description': org.description,
      'members': memberRoles
    };

    return http
        .post('https://web.njit.edu/~mc564/eventapi/organization/update.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class updateOrganization method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class updateOrganization method: " +
          error.toString());
    });
  }

  static Future<bool> requestEboardChange(Organization org) {
    List<List<String>> memberRoles = List<List<String>>();
    List<OrganizationMember> eBoardMembers = org.eBoardMembers;
    if (eBoardMembers != null && eBoardMembers.length > 0) {
      for (OrganizationMember eBoardMember in eBoardMembers) {
        memberRoles.add(<String>[eBoardMember.ucid, eBoardMember.role]);
      }
    }

    Map<String, dynamic> map = {'name': org.name, 'eboardMembers': memberRoles};

    return http
        .post(
            'https://web.njit.edu/~mc564/eventapi/organization/requestEboardChange.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class requestEboardChange method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class requestEboardChange method: " +
          error.toString());
    });
  }

  static Future<bool> approveEboardChange(Organization org) {
    Map<String, dynamic> map = {'name': org.name};
    return http
        .post(
            'https://web.njit.edu/~mc564/eventapi/organization/approveEboardChange.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class approveEboardChange method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class approveEboardChange method: " +
          error.toString());
    });
  }

  static Future<bool> approveOrganization(Organization org) {
    Map<String, dynamic> map = {'name': org.name};

    return http
        .post('https://web.njit.edu/~mc564/eventapi/organization/approve.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class approveOrganization method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class approveOrganization method: " +
          error.toString());
    });
  }

  static Future<bool> removeOrganization(Organization org) {
    Map<String, dynamic> map = {'name': org.name};

    return http
        .post('https://web.njit.edu/~mc564/eventapi/organization/remove.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class removeOrganization method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class removeOrganization method: " +
          error.toString());
    });
  }

  static Future<Organization> getOrganizationInfo(String name) async {
    try {
      Organization org = Organization();
      http.Response response = await http.get(
          "https://web.njit.edu/~mc564/eventapi/organization/read.php?name=" +
              name);
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class getOrganizationInfo method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      final Map jsonResponse = json.decode(response.body);
      org.setName(jsonResponse['name']);
      if (jsonResponse.containsKey('status'))
        org.setStatus(
            OrganizationStatusHelper.getStatus(jsonResponse['status']));
      if (jsonResponse.containsKey('eBoardMembers')) {
        List<OrganizationMember> eBoardMembers = List<OrganizationMember>();
        var eBoardMemberRecords = jsonResponse['eBoardMembers'];
        for (var eboardMember in eBoardMemberRecords) {
          String ucid = eboardMember['ucid'];
          String role = eboardMember['role'];
          eBoardMembers.add(OrganizationMember(ucid: ucid, role: role));
        }
        org.setEboardMembers(eBoardMembers);
      }
      if (jsonResponse.containsKey('regularMembers')) {
        List<OrganizationMember> regularMembers = List<OrganizationMember>();
        var regularMemberRecords = jsonResponse['regularMembers'];
        for (var regularMember in regularMemberRecords) {
          String ucid = regularMember['ucid'];
          String role = regularMember['role'];
          regularMembers.add(OrganizationMember(ucid: ucid, role: role));
        }
        org.setMembers(regularMembers);
      }
      return org;
    } catch (error) {
      throw Exception("Error in Database class getOrganizationInfo method: " +
          error.toString());
    }
  }

  static Future<List<Organization>> getViewableOrganizations() {
    List<Organization> rtn = List<Organization>();
    return http
        .get(
            "https://web.njit.edu/~mc564/eventapi/organization/readViewable.php")
        .then((http.Response response) {
      final Map jsonResponse = json.decode(response.body);
      int numRecords = jsonResponse['numRecords'];
      if (numRecords <= 0) return rtn;
      jsonResponse['viewableOrganizations'].forEach((record) {
        Organization org = Organization();
        org.setName(record['name']);
        org.setDescription(record['description']);
        org.setStatus(OrganizationStatusHelper.getStatus(record['status']));
        List<OrganizationMember> eBoardMembers = List<OrganizationMember>();
        List<OrganizationMember> regularMembers = List<OrganizationMember>();
        if (record.containsKey('eBoardMembers')) {
          var eBoardMemberRecords = record['eBoardMembers'];
          for (var eboardMember in eBoardMemberRecords) {
            String ucid = eboardMember['ucid'];
            String role = eboardMember['role'];
            eBoardMembers.add(OrganizationMember(ucid: ucid, role: role));
          }
          org.setEboardMembers(eBoardMembers);
        }
        if (record.containsKey('regularMembers')) {
          var regularMemberRecords = record['regularMembers'];
          for (var regularMember in regularMemberRecords) {
            String ucid = regularMember['ucid'];
            String role = regularMember['role'];
            regularMembers.add(OrganizationMember(ucid: ucid, role: role));
          }
          org.setMembers(regularMembers);
        }
        rtn.add(org);
      });
      return rtn;
    }).catchError((error) {
      throw Exception(
          "Error in Database class getViewableOrganizations method: " +
              error.toString());
    });
  }

  static Future<List<OrganizationUpdateRequestData>>
      getOrganizationsAwaitingEboardChange() {
    List<OrganizationUpdateRequestData> rtn =
        List<OrganizationUpdateRequestData>();
    return http
        .get(
            "https://web.njit.edu/~mc564/eventapi/organization/readAwaitingEboardChange.php")
        .then((http.Response response) {
      final Map jsonResponse = json.decode(response.body);

      int numRecords = jsonResponse['numRecords'];
      if (numRecords <= 0) return rtn;
      jsonResponse['organizations'].forEach((record) {
        Organization originalOrg = Organization();
        Organization updatedOrg = Organization();
        originalOrg.setName(record['name']);
        originalOrg.setDescription(record['description']);
        originalOrg
            .setStatus(OrganizationStatusHelper.getStatus(record['status']));
        updatedOrg.setName(record['name']);
        updatedOrg.setDescription(record['description']);
        updatedOrg
            .setStatus(OrganizationStatusHelper.getStatus(record['status']));

        //assign requested eboard members
        if (record.containsKey('requestedEboardMembers')) {
          var requestedEboardMemberRecords = record['requestedEboardMembers'];
          List<OrganizationMember> requestedEboardMembers =
              List<OrganizationMember>();

          for (var eboardMember in requestedEboardMemberRecords) {
            String ucid = eboardMember['ucid'];
            String role = eboardMember['role'];
            requestedEboardMembers
                .add(OrganizationMember(ucid: ucid, role: role));
          }
          updatedOrg.setEboardMembers(requestedEboardMembers);
        }

        //assign current eboard members
        if (record.containsKey('currentEboardMembers')) {
          var currentEboardMemberRecords = record['currentEboardMembers'];
          List<OrganizationMember> currentEboardMembers =
              List<OrganizationMember>();

          for (var eboardMember in currentEboardMemberRecords) {
            String ucid = eboardMember['ucid'];
            String role = eboardMember['role'];
            currentEboardMembers
                .add(OrganizationMember(ucid: ucid, role: role));
          }
          originalOrg.setEboardMembers(currentEboardMembers);
        }

        //assign regular members
        if (record.containsKey('regularMembers')) {
          List<OrganizationMember> regularMembers = List<OrganizationMember>();
          var regularMemberRecords = record['regularMembers'];
          for (var regularMember in regularMemberRecords) {
            String ucid = regularMember['ucid'];
            String role = regularMember['role'];
            regularMembers.add(OrganizationMember(ucid: ucid, role: role));
          }
          originalOrg.setMembers(regularMembers);
          updatedOrg.setMembers(regularMembers);
        }
        rtn.add(OrganizationUpdateRequestData(
            original: originalOrg, updated: updatedOrg));
      });
      return rtn;
    }).catchError((error) {
      throw Exception(
          "Error in Database class getOrganizationsAwaitingEboardChange method: " +
              error.toString());
    });
  }

  static Future<List<Organization>> getOrganizationsAwaitingApproval() {
    List<Organization> rtn = List<Organization>();
    return http
        .get(
            "https://web.njit.edu/~mc564/eventapi/organization/readAwaitingApproval.php")
        .then((http.Response response) {
      final Map jsonResponse = json.decode(response.body);
      int numRecords = jsonResponse['numRecords'];
      if (numRecords <= 0) return rtn;
      jsonResponse['organizations'].forEach((record) {
        Organization org = Organization();
        org.setName(record['name']);
        org.setDescription(record['description']);
        org.setStatus(OrganizationStatusHelper.getStatus(record['status']));
        List<OrganizationMember> eBoardMembers = List<OrganizationMember>();
        List<OrganizationMember> regularMembers = List<OrganizationMember>();
        var eBoardMemberRecords = record['eBoardMembers'];
        for (var eboardMember in eBoardMemberRecords) {
          String ucid = eboardMember['ucid'];
          String role = eboardMember['role'];
          eBoardMembers.add(OrganizationMember(ucid: ucid, role: role));
        }
        org.setEboardMembers(eBoardMembers);
        var regularMemberRecords = record['regularMembers'];
        for (var regularMember in regularMemberRecords) {
          String ucid = regularMember['ucid'];
          String role = regularMember['role'];
          regularMembers.add(OrganizationMember(ucid: ucid, role: role));
        }
        org.setMembers(regularMembers);
        rtn.add(org);
      });
      return rtn;
    }).catchError((error) {
      throw Exception(
          "Error in Database class getOrganizationsAwaitingApproval method: " +
              error.toString());
    });
  }

  static Future<bool> setOrganizationStatus(
      OrganizationStatus status, Organization org) {
    Map<String, dynamic> map = {
      'status': OrganizationStatusHelper.getString(status),
      'name': org.name,
    };
    return http
        .post('https://web.njit.edu/~mc564/eventapi/organization/setStatus.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class setOrganizationStatus method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class setOrganizationStatus method: " +
          error.toString());
    });
  }

  static Future<bool> sendMessage(
      String senderUCID,
      List<String> recipientUCIDS,
      String title,
      String body,
      DateTime expirationDate) {
    Map<String, dynamic> map = {
      'senderUCID': senderUCID,
      'recipientUCIDs': recipientUCIDS,
      'title': title,
      'body': body,
      'timeCreated': formatter.format(DateTime.now()),
      'expirationDate': formatter.format(expirationDate)
    };

    return http
        .post('https://web.njit.edu/~mc564/eventapi/message/send.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class sendMessage method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception(
          "Error in Database class sendMessage method: " + error.toString());
    });
  }

  static Future<bool> sendMessageToAdmins(
      String senderUCID, String title, String body, DateTime expirationDate) {
    Map<String, dynamic> map = {
      'senderUCID': senderUCID,
      'title': title,
      'body': body,
      'timeCreated': formatter.format(DateTime.now()),
      'expirationDate': formatter.format(expirationDate)
    };

    return http
        .post('https://web.njit.edu/~mc564/eventapi/message/sendToAdmins.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class sendMessageToAdmins method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class sendMessageToAdmins method: " +
          error.toString());
    });
  }

  static Future<List<Message>> fetchMessages(String ucid) {
    List<Message> rtn = List<Message>();
    return http
        .get("https://web.njit.edu/~mc564/eventapi/message/read.php?ucid=" +
            ucid)
        .then((http.Response response) {
      final Map jsonResponse = json.decode(response.body);
      if (!jsonResponse.containsKey('records')) return rtn;

      jsonResponse['records'].forEach((record) {
        rtn.add(Message(
          id: int.parse(record['messageId']),
          recipientUCID: record['recipientUCID'],
          senderUCID: record['senderUCID'],
          title: record['title'],
          body: record['body'],
          messageRead: record['messageRead'],
          timeCreated: DateTime.parse(record['timeCreated']),
        ));
      });
      return rtn;
    }).catchError((error) {
      throw Exception(
          "Error in Database class fetchMessages method: " + error.toString());
    });
  }

  static Future<bool> setMessageToRead(Message message) {
    Map<String, dynamic> map = {
      'ucid': message.recipientUCID,
      'messageId': message.id
    };

    return http
        .post(
            'https://web.njit.edu/~mc564/eventapi/message/setMessageToRead.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class setMessageToRead method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception("Error in Database class setMessageToRead method: " +
          error.toString());
    });
  }

  static Future<bool> removeMessage(Message message) {
    Map<String, dynamic> map = {
      'ucid': message.recipientUCID,
      'messageId': message.id
    };

    return http
        .post('https://web.njit.edu/~mc564/eventapi/message/remove.php',
            body: json.encode(map))
        .then((http.Response response) {
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 202) {
        throw Exception(
            "Error in Database class removeMessage method: Database response code is: " +
                response.statusCode.toString() +
                "\n response body: " +
                response.body);
      }
      return true;
    }).catchError((error) {
      throw Exception(
          "Error in Database class removeMessage method: " + error.toString());
    });
  }
}
