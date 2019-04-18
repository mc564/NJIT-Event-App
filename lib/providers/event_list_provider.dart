import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';
import 'package:intl/intl.dart';

import '../api/database_event_api.dart';
import '../api/njit_event_api.dart';

import '../models/event.dart';
import '../models/organization.dart';

import './cosine_similarity_provider.dart';
import './filter_provider.dart';

//This file is very confusing to read.  But what do I know? -Logan

//utility methods to deal with event lists, including sorting and filtering
class EventListProvider {
  _EventCache _cache;
  FilterAndSortProvider _filterProvider;

  Map<DateTime, List<Event>> get filteredCacheEvents {
    List<Event> cachedEvents = _cache.allEvents;
    cachedEvents = _filterProvider.filter(cachedEvents);
    Map<DateTime, List<Event>> dateMappedEvents =
        splitEventsByDay(cachedEvents);
    return dateMappedEvents;
  }

  EventListProvider({@required FilterAndSortProvider filterProvider}) {
    _cache = _EventCache();
    _filterProvider = filterProvider;
  }

  void deleteDupEdited(List<Event> dbEvents, List<Event> apiEvents) {
    for (Event event in dbEvents) {
      if (event.eventId.length < 20) {
        apiEvents
            .removeWhere((Event event2) => event2.eventId == event.eventId);
      }
    }
  }

  Future<List<Event>> refetchEventsOnDay(DateTime time,
      [bool filtered = true]) async {
    try {
      List<Event> events = [];
      final List<Event> apiEvents = await NJITEventAPI.eventsOnDay(time);
      final List<Event> dbEvents = await DatabaseEventAPI.eventsOnDay(time);
      deleteDupEdited(dbEvents, apiEvents);

      events.addAll(apiEvents);
      events.addAll(dbEvents);
      _cache.addList(events);
      return await _filterProvider.filterAndSort(
          events: events, filtered: filtered, sorted: true);
    } catch (error) {
      throw Exception("refreshEventsOnDay failed in EventListProvider: " +
          error.toString());
    }
  }

  Future<List<Event>> getEventsOnDay(DateTime time,
      [bool filtered = true]) async {
    print("[MODEL] getting events on day");

    List<Event> events = [];
    try {
      List<Event> cacheResults = _cache.getListFor(time);
      if (cacheResults == null)
        print('no cache match');
      else
        print('cache results are: ' + cacheResults.length.toString());
      if (cacheResults != null) {
        return await _filterProvider.filterAndSort(
            events: cacheResults, filtered: filtered, sorted: true);
      }
      final List<Event> apiEvents = await NJITEventAPI.eventsOnDay(time);
      final List<Event> dbEvents = await DatabaseEventAPI.eventsOnDay(time);
      deleteDupEdited(dbEvents, apiEvents);
      events.addAll(apiEvents);
      events.addAll(dbEvents);
      _cache.addList(events);
      return await _filterProvider.filterAndSort(
          events: events, filtered: filtered, sorted: true);
    } catch (error) {
      throw Exception(
          "Retreiving events for day failed in EventListProvider: " +
              error.toString());
    }
  }

  Map<DateTime, List<Event>> splitEventsByDay(List<Event> events) {
    try {
      Map<DateTime, List<Event>> rtn = Map<DateTime, List<Event>>();
      for (Event event in events) {
        DateTime cleanStart = DateTime(
            event.startTime.year, event.startTime.month, event.startTime.day);
        rtn.putIfAbsent(cleanStart, () => List<Event>());
        rtn[cleanStart].add(event);
      }
      return rtn;
    } catch (error) {
      print('error in spliteventsbyday! the error is: ' + error.toString());
      throw Exception(
          'error in splitEventsByDay of EventListProvider! error: ' +
              error.toString());
    }
  }

  Future<List<Event>> refetchEventsBetween(DateTime start, DateTime end,
      [bool filtered = true]) async {
    print("[MODEL] getting events between");
    List<Event> events = [];
    try {
      final List<Event> apiEvents =
          await NJITEventAPI.eventsBetween(start, end);
      final List<Event> dbEvents =
          await DatabaseEventAPI.eventsBetween(start, end);
      deleteDupEdited(dbEvents, apiEvents);
      events.addAll(apiEvents);
      events.addAll(dbEvents);
      Map<DateTime, List<Event>> toAddToCache = splitEventsByDay(events);
      for (List<Event> eventsOnOneDay in toAddToCache.values) {
        _cache.addList(eventsOnOneDay);
      }

      return await _filterProvider.filterAndSort(
          events: events, filtered: filtered, sorted: true);
    } catch (error) {
      throw Exception(
          "Retrieving events from either NJIT events api or database failed: " +
              error.toString());
    }
  }

  Future<List<Event>> getEventsBetween(DateTime start, DateTime end,
      [bool filtered = true]) async {
    print("[MODEL] getting events between");
    List<Event> events = [];
    try {
      bool cacheHasAllDays = false;
      DateTime newStart = DateTime(start.year, start.month, start.day);
      for (int i = 1;; i++) {
        List<Event> fetchedEvents = _cache.getListFor(newStart);
        if (fetchedEvents == null)
          break;
        else
          events.addAll(fetchedEvents);
        if (newStart.year == end.year &&
            newStart.month == end.month &&
            newStart.day == end.day) {
          cacheHasAllDays = true;
          break;
        }
        //add additional hours to account for daylight savings time
        newStart = newStart.add(Duration(hours: 26));
        newStart = DateTime(newStart.year, newStart.month, newStart.day);
      }
      if (cacheHasAllDays) {
        return await _filterProvider.filterAndSort(
            events: events, filtered: filtered, sorted: true);
      } else {
        events = [];
      }

      final List<Event> apiEvents =
          await NJITEventAPI.eventsBetween(start, end);
      final List<Event> dbEvents =
          await DatabaseEventAPI.eventsBetween(start, end);
      deleteDupEdited(dbEvents, apiEvents);
      events.addAll(apiEvents);
      events.addAll(dbEvents);
      Map<DateTime, List<Event>> toAddToCache = splitEventsByDay(events);
      for (List<Event> eventsOnOneDay in toAddToCache.values) {
        _cache.addList(eventsOnOneDay);
      }

      return await _filterProvider.filterAndSort(
          events: events, filtered: filtered, sorted: true);
    } catch (error) {
      throw Exception(
          "Retrieving events from either NJIT events api or database failed: " +
              error.toString());
    }
  }

  void _filterForOrganization(List<Event> toFilter, Organization org) {
    toFilter.removeWhere((Event event) => event.organization != org.name);
  }

  //basically gets events 1 weeks before today and also events 2 weeks after today
  //and then filters for events by organization org
  Future<RecentEvents> getRecentEvents(Organization org) async {
    DateTime now = DateTime.now();
    DateTime earlierStart = now.subtract(Duration(days: 7));
    DateTime laterEnd = now.add(Duration(days: 14));
    List<Event> allEvents =
        await getEventsBetween(earlierStart, laterEnd, false);
    List<Event> pastEvents = List<Event>();
    List<Event> upcomingEvents = List<Event>();
    for (Event event in allEvents) {
      if (event.startTime.isBefore(now))
        pastEvents.add(event);
      else
        upcomingEvents.add(event);
    }
    _filterForOrganization(pastEvents, org);
    _filterForOrganization(upcomingEvents, org);
    _filterProvider.sortByDate(pastEvents);
    _filterProvider.sortByDate(upcomingEvents);
    return RecentEvents(pastEvents: pastEvents, upcomingEvents: upcomingEvents);
  }

  Future<RecentEvents> refetchRecentEvents(Organization org) async {
    DateTime now = DateTime.now();
    DateTime earlierStart = now.subtract(Duration(days: 7));
    DateTime laterEnd = now.add(Duration(days: 14));
    List<Event> allEvents =
        await refetchEventsBetween(earlierStart, laterEnd, false);
    List<Event> pastEvents = List<Event>();
    List<Event> upcomingEvents = List<Event>();
    for (Event event in allEvents) {
      if (event.startTime.isBefore(now))
        pastEvents.add(event);
      else
        upcomingEvents.add(event);
    }
    _filterForOrganization(pastEvents, org);
    _filterForOrganization(upcomingEvents, org);
    _filterProvider.sortByDate(pastEvents);
    _filterProvider.sortByDate(upcomingEvents);
    return RecentEvents(pastEvents: pastEvents, upcomingEvents: upcomingEvents);
  }

  Future<List<Event>> getSimilarEvents(Event event) async {
    print("[MODEL] getting similar events");

    DateTime earlierStart = event.startTime.subtract(Duration(days: 7));
    DateTime laterEnd = event.endTime.add(Duration(days: 14));

    try {
      List<Event> recentEvents =
          await getEventsBetween(earlierStart, laterEnd, false);
      List<Event> rtn = [];
      CosineSimilarityProvider similarityCalc = CosineSimilarityProvider();
      recentEvents.forEach((Event recentEvent) {
        if (similarityCalc.areSimilar(event.title, recentEvent.title))
          rtn.add(recentEvent);
      });
      //keep the list items with high cosine similarity (titles only) and add them to the list
      return rtn;
    } catch (error) {
      throw Exception(
          "Failed to get similar events in EventsModel: " + error.toString());
    }
  }
}

//keeps 50 or x number (depending on set size) daily event lists
class _EventCache {
  DateFormat _startDayKeyFormatter;
  //keys are start days formatted as a string, values are lists of events correlating to that day
  LruMap<String, List<Event>> _cache;

  _EventCache({int cacheSize = 50}) {
    _cache = LruMap<String, List<Event>>(maximumSize: cacheSize);
    _startDayKeyFormatter = DateFormat('MMM d y');
  }

  List<Event> get allEvents {
    List<Event> allEvents = List<Event>();
    for (List<Event> eventList in _cache.values) {
      allEvents.addAll(eventList);
    }
    return allEvents;
  }

  //remove a list if one is found with the same key and add in a new list
  void addList(List<Event> events) {
    if (events == null || events.length == 0) return;
    String key = _startDayKeyFormatter.format(events[0].startTime);
    _cache.remove(key);
    List<Event> val = _cache.putIfAbsent(key, () => <Event>[]);
    val.addAll(events);
  }

  List<Event> getListFor(DateTime day) {
    String key = _startDayKeyFormatter.format(day);
    if (_cache.containsKey(key))
      return _cache[key];
    else
      return null;
  }
}
