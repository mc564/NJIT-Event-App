import '../api/database_event_api.dart';
import '../api/njit_event_api.dart';
import '../models/event.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/sort.dart';
import '../models/filter.dart';
import './cosine_similarity_provider.dart';
import 'package:quiver/collection.dart';
import 'package:intl/intl.dart';

//utility methods to deal with event lists, including sorting, filtering and adding events
//TODO change everything to block fetching...
class EventListProvider {
  _EventCache _cache;
  NJITEventAPI _njitAPI;
  DatabaseEventAPI _dbAPI;
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

  EventListProvider() {
    _cache = _EventCache();
    _njitAPI = NJITEventAPI();
    _dbAPI = DatabaseEventAPI();
    _filterCategories = List<Category>();
    _filterLocations = List<Location>();
    _filterOrganizations = List<String>();
    _sort = Sort.Date;
  }

  void _sortEvents(List<Event> list) {
    if (_sort == Sort.Date) {
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
    } else if (_sort == Sort.Relevance) {
      //TODO implement this sort once I have users and favoriting and stuff
    }
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

//TODO try to make getEvents methods cleaner looking
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
        if (!filtered) {
          _sortEvents(cacheResults);
          return cacheResults;
        }
        List<Event> filteredEvents = _filterEvents(cacheResults);
        _sortEvents(filteredEvents);
        return filteredEvents;
      }
      final List<Event> apiEvents = await _njitAPI.eventsOnDay(time);
      final List<Event> dbEvents = await _dbAPI.eventsOnDay(time);
      events.addAll(apiEvents);
      events.addAll(dbEvents);
      _cache.addList(events);
      if (!filtered) {
        _sortEvents(events);
        return events;
      }
      List<Event> filteredEvents = _filterEvents(events);
      _sortEvents(filteredEvents);
      return filteredEvents;
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

  //modify to edit cache...?..donno
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
        if (!filtered) {
          _sortEvents(events);
          return events;
        }
        events = _filterEvents(events);
        _sortEvents(events);
        return events;
      } else {
        events = [];
      }

      final List<Event> apiEvents = await _njitAPI.eventsBetween(start, end);
      final List<Event> dbEvents = await _dbAPI.eventsBetween(start, end);
      events.addAll(apiEvents);
      events.addAll(dbEvents);
      Map<DateTime, List<Event>> toAddToCache = splitEventsByDay(events);
      for (List<Event> eventsOnOneDay in toAddToCache.values) {
        _cache.addList(eventsOnOneDay);
      }

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

  Future<List<Event>> getSimilarEvents(Event event) {
    print("[MODEL] getting similar events");

    DateTime earlierStart = event.startTime.subtract(Duration(days: 14));
    DateTime laterEnd = event.endTime.add(Duration(days: 14));

    try {
      return getEventsBetween(earlierStart, laterEnd, false)
          .then((List<Event> recentEvents) {
        List<Event> rtn = [];
        CosineSimilarityProvider similarityCalc = CosineSimilarityProvider();
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

  Future<bool> addEvent(Event event) {
    print("[MODEL] adding event");
    return _dbAPI.addEvent(event).then((bool success) {
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

  //remove a list if one is found with the same key and add in a new list
  void addList(List<Event> events) {
    if (events == null || events.length == 0) return;
    String key = _startDayKeyFormatter.format(events[0].startTime);
    _cache.remove(key);
    List<Event> val = _cache.putIfAbsent(key, () => <Event>[]);
    val.addAll(events);
    print('cache length: ' + _cache.length.toString());
  }

  List<Event> getListFor(DateTime day) {
    String key = _startDayKeyFormatter.format(day);
    if (_cache.containsKey(key))
      return _cache[key];
    else
      return null;
  }
}
