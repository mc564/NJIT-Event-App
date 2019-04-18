import '../models/category.dart';
import 'package:flutter/material.dart';
import '../models/sort.dart';
import '../models/location.dart';
import '../models/event.dart';
import '../models/event_details.dart';
import './favorite_provider.dart';
import './metrics_provider.dart';
import './event_list_provider.dart';

//holds app state information about filters
class FilterAndSortProvider {
  //use _day to generate searchable organizations
  DateTime _day;
  List<Category> _formSelectedCategories;
  List<String> _formSelectedOrganizations;
  List<Location> _formSelectedLocations;
  Sort _formSelectedSort;

  List<Category> _filterCategories;
  List<String> _filterOrganizations;
  List<Location> _filterLocations;
  Sort _filterSort;

  MetricsProvider _metricsProvider;
  FavoriteProvider _favoriteProvider;
  EventListProvider _eventListProvider;

  FilterAndSortProvider() {
    _filterCategories = List<Category>();
    _filterOrganizations = List<String>();
    _filterLocations = List<Location>();
    _filterSort = Sort.Date;
    resetFormFilters(DateTime.now());
  }

  void initialize(
      {@required MetricsProvider metricsProvider,
      @required FavoriteProvider favoriteProvider,
      @required EventListProvider eventListProvider}) {
    _metricsProvider = metricsProvider;
    _favoriteProvider = favoriteProvider;
    _eventListProvider = eventListProvider;
  }

  //TODO check these are correct...?
  Sort get filterSort => _filterSort;

  List<Category> get filterCategories => List<Category>.from(_filterCategories);
  List<Location> get filterLocations => List<Location>.from(_filterLocations);
  List<String> get filterOrganizations =>
      List<String>.from(_filterOrganizations);

  Sort get formSelectedSort => _formSelectedSort;
  List<Category> get formSelectedCategories =>
      List<Category>.from(_formSelectedCategories);
  List<String> get formSelectedOrganizations =>
      List<String>.from(_formSelectedOrganizations);
  List<Location> get formSelectedLocations =>
      List<Location>.from(_formSelectedLocations);

  Future<List<String>> get searchableOrganizations async {
    List<String> orgs = List<String>();
    if (_eventListProvider == null) return orgs;
    List<Event> recentEvents = await _eventListProvider.getEventsBetween(
        _day.subtract(Duration(days: 7)), _day.add(Duration(days: 14)), false);
    for (Event event in recentEvents) {
      orgs.add(event.organization);
    }
    return orgs.toSet().toList();
  }

  //called every time the ui goes to a page that uses the filter variables
  void resetFormFilters(DateTime day) {
    _day = day;
    _formSelectedCategories = filterCategories;
    _formSelectedOrganizations = filterOrganizations;
    _formSelectedLocations = filterLocations;
    _formSelectedSort = filterSort;
  }

  /* CATEGORY OPERATIONS */

//add and remove category aren't used..
  void addCategory(Category category) {
    _formSelectedCategories.add(category);
  }

  void removeCategory(Category category) {
    _formSelectedCategories.removeWhere((Category c) => c == category);
  }

  void setCategories(List<Category> categories) {
    _formSelectedCategories = List<Category>.from(categories);
  }

  /* LOCATION OPERATIONS */

  //add and remove location aren't used either
  void addLocation(Location location) {
    _formSelectedLocations.add(location);
  }

  void removeLocation(Location location) {
    _formSelectedLocations.removeWhere((Location l) => l == location);
  }

  void setLocations(List<Location> locations) {
    _formSelectedLocations = List<Location>.from(locations);
  }

  /* ORGANIZATION OPERATIONS */

  void addOrganization(String org) {
    _formSelectedOrganizations.add(org);
  }

  void removeOrganization(String org) {
    _formSelectedOrganizations.removeWhere((String o) => o == org);
  }

  void setOrganizations(List<String> organizations) {
    _formSelectedOrganizations = List<String>.from(organizations);
  }

  void setSort(Sort sortType) {
    _formSelectedSort = sortType;
  }

  void clearFilters() {
    _formSelectedCategories = List<Category>();
    _formSelectedLocations = List<Location>();
    _formSelectedOrganizations = List<String>();
  }

  /*METHOD TO CHANGE FILTER parameters and sort - above methods only change form variables*/
  //returns whether or not setting filters was successful
  bool setFilterAndSort() {
    try {
      _filterCategories = formSelectedCategories;
      _filterLocations = formSelectedLocations;
      _filterOrganizations = formSelectedOrganizations;
      _filterSort = formSelectedSort;
      return true;
    } catch (error) {
      throw Exception('Error in FilterProvider setFilterAndSort method: ' +
          error.toString());
    }
  }

  /*Methods to do filtering and sorting on event lists*/
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
    if (_filterSort == Sort.Date) {
      sortByDate(list);
      return true;
    } else if (_filterSort == Sort.Relevance) {
      List<Event> faves = _favoriteProvider.allFavorites;
      if (_metricsProvider == null || _favoriteProvider == null) return true;
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

  void sortByDate(List<Event> events) {
    if (events == null || events.length <= 1) return;
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<Event> filter(List<Event> events) {
    return _filterEvents(events);
  }

  Future<List<Event>> filterAndSort(
      {List<Event> events, bool filtered = true, bool sorted = true}) async {
    if (filtered && sorted) {
      List<Event> filteredEvents = _filterEvents(events);
      await _sortEvents(filteredEvents);
      return filteredEvents;
    } else if (filtered && !sorted) {
      return _filterEvents(events);
    } else if (!filtered && sorted) {
      await _sortEvents(events);
      return events;
    } else {
      return events;
    }
  }
}
