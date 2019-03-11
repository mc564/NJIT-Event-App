import 'dart:async';
import '../providers/filter_provider.dart';
import '../providers/event_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/sort.dart';
import '../models/event.dart';

//manages filter variables
class FilterBloc {
  final StreamController<FilterState> _filterController;
  final FilterProvider _filterProvider;
  final EventListProvider _eventListProvider;
  final DateTime _day;
  final FiltersSelected _initialState;

  //need view's current day to know how to clear cache later
  FilterBloc(
      {@required EventListProvider eventListProvider, @required DateTime day})
      : _filterProvider = FilterProvider(
          selectedCategories: eventListProvider.selectedCategories,
          selectedLocations: eventListProvider.selectedLocations,
          selectedOrganizations: eventListProvider.selectedOrganizations,
          sort: eventListProvider.sortType,
        ),
        _eventListProvider = eventListProvider,
        _filterController = StreamController(),
        _day = day,
        _initialState = FiltersSelected(
          selectedCategories: eventListProvider.selectedCategories,
          selectedLocations: eventListProvider.selectedLocations,
          selectedOrganizations: eventListProvider.selectedOrganizations,
          sort: eventListProvider.sortType,
        );

  FiltersSelected get initialState => _initialState;

  Stream get filterProgress => _filterController.stream;

  //only searches organizations that have hosted events recently
  Future<List<String>> get searchableOrganizations async {
    List<String> orgs = List<String>();
    List<Event> recentEvents = await _eventListProvider.getEventsBetween(
        _day.subtract(Duration(days: 7)), _day.add(Duration(days: 14)), false);
    for (Event event in recentEvents) {
      orgs.add(event.organization);
    }
    return orgs.toSet().toList();
  }

  void alertNewFiltersSelected() {
    _filterController.sink.add(FiltersSelected(
      selectedCategories: _filterProvider.selectedCategories,
      selectedLocations: _filterProvider.selectedLocations,
      selectedOrganizations: _filterProvider.selectedOrganizations,
      sort: _filterProvider.sortType,
    ));
  }

//TODO see if I actually end up using any of these...
  void addCategory(Category category) {
    _filterProvider.addCategory(category);
    alertNewFiltersSelected();
  }

  void removeCategory(Category category) {
    _filterProvider.removeCategory(category);
    alertNewFiltersSelected();
  }

  void addLocation(Location loc) {
    _filterProvider.addLocation(loc);
    alertNewFiltersSelected();
  }

  void removeLocation(Location loc) {
    _filterProvider.removeLocation(loc);
    alertNewFiltersSelected();
  }

  void addOrganization(String org) {
    _filterProvider.addOrganization(org);
    alertNewFiltersSelected();
  }

  void removeOrganization(String org) {
    _filterProvider.removeOrganization(org);
    alertNewFiltersSelected();
  }

  //amended ones
  void setCategories(List<Category> selectedCategories) {
    _filterProvider.setCategories(selectedCategories);
    alertNewFiltersSelected();
  }

  void setLocations(List<Location> selectedLocations) {
    _filterProvider.setLocations(selectedLocations);
    alertNewFiltersSelected();
  }

  void setOrganizations(List<String> selectedOrganizations) {
    _filterProvider.setOrganizations(selectedOrganizations);
    alertNewFiltersSelected();
  }

  void clearFilters() {
    try {
      _filterProvider.clearFilters();
      alertNewFiltersSelected();
    } catch (error) {
      _filterController.sink.add(FilterError());
    }
  }

  void filter() {
    try {
      _eventListProvider.setFilterParameters(_filterProvider.filterParameters);
      _eventListProvider.setSort(_filterProvider.sortType);
      _filterController.sink.add(FilterComplete());
    } catch (error) {
      _filterController.sink.add(FilterError());
    }
  }

  void setSort(Sort sortType) {
    _filterProvider.setSort(sortType);
  }

  void dispose() {
    _filterController.close();
  }
}

abstract class FilterState extends Equatable {
  FilterState([List args = const []]) : super(args);
}

class FiltersSelected extends FilterState {
  List<Category> selectedCategories;
  List<String> selectedOrganizations;
  List<Location> selectedLocations;
  Sort sort;
  FiltersSelected(
      {@required List<Category> selectedCategories,
      @required List<String> selectedOrganizations,
      @required List<Location> selectedLocations,
      @required Sort sort})
      : selectedCategories = selectedCategories,
        selectedOrganizations = selectedOrganizations,
        selectedLocations = selectedLocations,
        sort = sort;
}

class FilterComplete extends FilterState {}

class FilterError extends FilterState {}
