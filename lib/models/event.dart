import 'package:flutter/material.dart';
import './category.dart';
import './location.dart';
import '../data/events_api.dart';
import '../data/database.dart';
import '../data/cosine_similarity.dart';
import '../pages/filter.dart';

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
  });

  @override
  String toString() {
    return "Event[title: " + title + "]";
  }
}

class EventHelper {
  static EventAPI _api = EventAPI();
  static Database _db = Database();
  static List<Category> filterCategories = List<Category>();
  static List<Location> filterLocations = List<Location>();
  static List<String> filterOrganizations = List<String>();
  static Sort sort = Sort.Date;

  static void _sortEvents(List<Event> list) {
    if (sort == Sort.Date) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    } else if (sort == Sort.Relevance) {
      //TODO implement this sort once I have users and favoriting and stuff
    }
  }

  static List<Event> _filterEvents(List<Event> list) {
    print('filtering!');
    print('filter categories: ' + filterCategories.toString());
    print('filter locations: ' + filterLocations.toString());
    print('filter orgs: ' + filterOrganizations.toString());
    List<Event> filteredList = [];
    for (Event event in list) {
      if ((filterCategories.isEmpty ||
              filterCategories.contains(event.category)) &&
          (filterLocations.contains(event.locationCode) ||
              filterLocations.isEmpty) &&
          (filterOrganizations.contains(event.organization) ||
              filterOrganizations.isEmpty)) {
        filteredList.add(event);
      }
    }
    return filteredList;
  }

  static Future<List<Event>> getEventsOnDay(DateTime time,
      [bool filtered = true]) async {
    print("[MODEL] getting events on day");

    List<Event> events = [];
    try {
      final List<Event> apiEvents = await _api.eventsOnDay(time);
      final List<Event> dbEvents = await _db.eventsOnDay(time);
      events.addAll(apiEvents);
      events.addAll(dbEvents);
      if (!filtered) {
        _sortEvents(events);
        return events;
      }
      events = _filterEvents(events);
      _sortEvents(events);
      return events;
    } catch (error) {
      throw Exception(
          "Retrieving events from either NJIT events api or database failed: " +
              error.toString());
    }
  }

  static Future<List<Event>> getEventsBetween(DateTime start, DateTime end,
      [bool filtered = true]) async {
    print("[MODEL] getting events between");
    List<Event> events = [];
    try {
      final List<Event> apiEvents = await _api.eventsBetween(start, end);
      final List<Event> dbEvents = await _db.eventsBetween(start, end);
      events.addAll(apiEvents);
      events.addAll(dbEvents);
      if (!filtered) {
        _sortEvents(events);
        return events;
      }
      events = _filterEvents(events);
      _sortEvents(events);
      return events;
    } catch (error) {
      throw Exception(
          "Retrieving events from either NJIT events api or database failed: " +
              error.toString());
    }
  }

  static Future<List<Event>> getSimilarEvents(Event event) {
    print("[MODEL] getting similar events");

    DateTime earlierStart = event.startTime.subtract(Duration(days: 14));
    DateTime laterEnd = event.endTime.add(Duration(days: 14));

    try {
      return getEventsBetween(earlierStart, laterEnd, false)
          .then((List<Event> recentEvents) {
        List<Event> rtn = [];
        CosineSimilarity similarityCalc = CosineSimilarity();
        recentEvents.forEach((Event recentEvent) {
          if (similarityCalc.areSimilar(event.title, recentEvent.title))
            rtn.add(recentEvent);
        });
        //keep the list items with high cosine similarity (titles only) and add them to the list
        _sortEvents(rtn);
        return rtn;
      });
    } catch (error) {
      throw Exception(
          "Failed to get similar events in EventsModel: " + error.toString());
    }
  }

  static Future<bool> addEvent(Event event) {
    Database db = Database();
    print("[MODEL] adding event");
    return db.addEvent(event).then((bool success) {
      if (success) {
        return true;
      } else {
        throw Exception("Adding event failed.");
      }
    }).catchError((error) {
      throw Exception("Adding event failed: " + error.toString());
    });
  }

  static void setSort(Sort sortType) {
    sort = sortType;
  }

  //returns whether or not setting filters was successful
  static bool setFilterParameters(Map<FilterType, dynamic> filterParameters) {
    for (FilterType filter in filterParameters.keys) {
      try {
        if (filter == FilterType.Category) {
          filterCategories = filterParameters[filter];
        } else if (filter == FilterType.Location) {
          filterLocations = filterParameters[filter];
        } else if (filter == FilterType.Organization) {
          filterOrganizations = filterParameters[filter];
        }
      } catch (error) {
        return false;
      }
    }
    return true;
  }
}
