import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';
import 'package:intl/intl.dart';

import '../api/database_event_api.dart';
import '../api/njit_event_api.dart';

import '../models/event.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/sort.dart';
import '../models/filter.dart';
import '../models/event_details.dart';
import '../models/organization.dart';

import './cosine_similarity_provider.dart';
import './metrics_provider.dart';
import './favorite_provider.dart';

//utility methods to deal with event lists, including sorting, filtering and adding events
class EventListProvider {
  _EventCache _cache;
  MetricsProvider _metricsProvider;
  FavoriteProvider _favoriteProvider;
  List<Category> _filterCategories;
  List<Location> _filterLocations;
  List<String> _filterOrganizations;
  Sort _sort;

  List<Category> get selectedCategories =>
      List<Category>.from(_filterCategories);

  List<String> get selectedOrganizations =>
      List<String>.from(_filterOrganizations);

  List<Location> get selectedLocations => List<Location>.from(_filterLocations);

  Sort get sortType => _sort;

  Map<DateTime, List<Event>> get filteredCacheEvents {
    List<Event> cachedEvents = _cache.allEvents;
    cachedEvents = _filterEvents(cachedEvents);
    Map<DateTime, List<Event>> dateMappedEvents =
        splitEventsByDay(cachedEvents);
    return dateMappedEvents;
  }

  EventListProvider({@required FavoriteProvider favoriteProvider}) {
    _cache = _EventCache();
    _metricsProvider = MetricsProvider();
    _favoriteProvider = favoriteProvider;
    _filterCategories = List<Category>();
    _filterLocations = List<Location>();
    _filterOrganizations = List<String>();
    _sort = Sort.Date;
  }

  double _relevanceScore(Event event, List<Event> faves,
      Map<String, EventDetails> eventIdToMetrics) {
    int thisWeekViewCount = 0;
    int lastWeekViewCount = 0;
    if (eventIdToMetrics.containsKey(event.eventId)) {
      EventDetails metrics = eventIdToMetrics[event.eventId];
      thisWeekViewCount = metrics.thisWeekViewCount;
      lastWeekViewCount = metrics.lastWeekViewCount;
    }

    double viewScore =
        0.75 * (thisWeekViewCount / 100.0) + 0.25 * (lastWeekViewCount / 100);
    int totalFaves = faves.length == 0 ? 1 : faves.length;
    //^avoid the divide by 0 error
    int categoryMatchCount =
        faves.where((Event fave) => fave.category == event.category).length;
    int orgMatchCount = faves
        .where((Event fave) => fave.organization == event.organization)
        .length;
    double categoryScore = categoryMatchCount / totalFaves;
    double orgScore = orgMatchCount / totalFaves;
    double score = viewScore * 0.5 + categoryScore * 0.25 + orgScore * 0.25;
    return score;
  }

  Future<bool> _sortEvents(List<Event> list) async {
    if (_sort == Sort.Date) {
      _sortByDate(list);
      return true;
    } else if (_sort == Sort.Relevance) {
      List<Event> faves = _favoriteProvider.allFavorites;
      //get metrics for all events in list
      List<EventDetails> detailObjects =
          await _metricsProvider.bulkReadMetrics(list);

      Map<String, EventDetails> eventIdToMetrics = Map<String, EventDetails>();

      for (int i = 0; i < detailObjects.length; i++) {
        EventDetails metrics = detailObjects[i];
        eventIdToMetrics[metrics.eventId] = metrics;
      }
      //precalculate all relevancescores for all list events and pass them to the function
      Map<String, double> relScore = Map<String, double>();
      for (int i = 0; i < list.length; i++) {
        Event event = list[i];
        relScore[event.eventId] =
            _relevanceScore(event, faves, eventIdToMetrics);
      }

      list.sort((Event a, Event b) =>
          relScore[b.eventId].compareTo(relScore[a.eventId]));
      return true;
    } else {
      return false;
    }
  }

  void _sortByDate(List<Event> events) {
    if (events == null || events.length <= 1) return;
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Event> _filterEvents(List<Event> list) {
    print('filtering!');
    print('filter categories: ' + _filterCategories.toString());
    print('filter locations: ' + _filterLocations.toString());
    List<Event> filteredList = [];
    for (Event event in list) {
      if ((_filterCategories.isEmpty ||
              _filterCategories.contains(event.category)) &&
          (_filterLocations.contains(event.locationCode) ||
              _filterLocations.isEmpty) &&
          (_filterOrganizations.contains(event.organization) ||
              _filterOrganizations.isEmpty)) {
        filteredList.add(event);
      }
    }
    return filteredList;
  }

  Future<List<Event>> _filterAndSort(List<Event> events, bool filtered) async {
    if (filtered) {
      List<Event> filteredEvents = _filterEvents(events);
      await _sortEvents(filteredEvents);
      return filteredEvents;
    } else {
      await _sortEvents(events);
      return events;
    }
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
      return await _filterAndSort(events, filtered);
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
        return await _filterAndSort(cacheResults, filtered);
      }
      final List<Event> apiEvents = await NJITEventAPI.eventsOnDay(time);
      final List<Event> dbEvents = await DatabaseEventAPI.eventsOnDay(time);
      deleteDupEdited(dbEvents, apiEvents);
      events.addAll(apiEvents);
      events.addAll(dbEvents);
      _cache.addList(events);
      return await _filterAndSort(events, filtered);
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

      return await _filterAndSort(events, filtered);
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
        return await _filterAndSort(events, filtered);
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

      return await _filterAndSort(events, filtered);
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
    _sortByDate(pastEvents);
    _sortByDate(upcomingEvents);
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
    _sortByDate(pastEvents);
    _sortByDate(upcomingEvents);
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

  Future<bool> addEvent(Event event) {
    print("[MODEL] adding event");
    return DatabaseEventAPI.addEvent(event).then((bool success) {
      if (success) {
        return true;
      } else {
        throw Exception("Adding event failed.");
      }
    }).catchError((error) {
      throw Exception("Adding event failed: " + error.toString());
    });
  }

  void setSort(Sort sortType) {
    _sort = sortType;
  }

  //returns whether or not setting filters was successful
  bool setFilterParameters(Map<FilterType, dynamic> filterParameters) {
    for (FilterType filter in filterParameters.keys) {
      try {
        if (filter == FilterType.Category) {
          _filterCategories = filterParameters[filter];
        } else if (filter == FilterType.Location) {
          _filterLocations = filterParameters[filter];
        } else if (filter == FilterType.Organization) {
          _filterOrganizations = filterParameters[filter];
        }
      } catch (error) {
        return false;
      }
    }
    return true;
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
    for(List<Event> eventList in _cache.values){
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
