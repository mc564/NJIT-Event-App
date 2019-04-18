import 'dart:async';

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../providers/filter_provider.dart';
import '../providers/event_list_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/metrics_provider.dart';

import '../models/category.dart';
import '../models/location.dart';
import '../models/sort.dart';

import '../blocs/event_bloc.dart';

//manages filter variables
class FilterBloc {
  final StreamController<FilterEvent> _requestsController;
  final StreamController<FilterState> _filterController;

  final FilterAndSortProvider _filterProvider;

  StreamSink<EventListEvent> _eventBlocSink;

  FilterBloc()
      : _filterController = StreamController.broadcast(),
        _requestsController = StreamController.broadcast(),
        _filterProvider = FilterAndSortProvider() {
          if(_filterController!=null) print('filter controller isnt NULL!');
    _requestsController.stream.forEach((FilterEvent event) {
      event.execute(this);
    });
  }

  //circular dependencies, so have separate initialize method
  void initialize(
      {@required EventListProvider eventListProvider,
      @required FavoriteProvider favoriteProvider,
      @required MetricsProvider metricsProvider,
      @required StreamSink<EventListEvent> eventBlocSink}) {
    _eventBlocSink = eventBlocSink;
    print('in initialize method of filter bloc!');
    _filterProvider.initialize(
        metricsProvider: metricsProvider,
        eventListProvider: eventListProvider,
        favoriteProvider: favoriteProvider);
  }

  FiltersSelected get initialState => FiltersSelected(
        selectedCategories: _filterProvider.formSelectedCategories,
        selectedLocations: _filterProvider.formSelectedLocations,
        selectedOrganizations: _filterProvider.formSelectedOrganizations,
        sort: _filterProvider.formSelectedSort,
      );

  Stream get filterProgress => _filterController.stream;
  StreamSink<FilterEvent> get sink => _requestsController.sink;
  FilterAndSortProvider get filterProvider => _filterProvider;

  //only searches organizations that have hosted events recently
  Future<List<String>> get searchableOrganizations async {
    return await _filterProvider.searchableOrganizations;
  }

  int get currentFilterCount =>
      _filterProvider.filterCategories.length +
      _filterProvider.filterLocations.length +
      _filterProvider.filterOrganizations.length;

  void alertNewFiltersSelected() {
    _filterController.sink.add(FiltersSelected(
      selectedCategories: _filterProvider.formSelectedCategories,
      selectedLocations: _filterProvider.formSelectedLocations,
      selectedOrganizations: _filterProvider.formSelectedOrganizations,
      sort: _filterProvider.formSelectedSort,
    ));
  }

  //called whenever go to filter page to set filters
  void resetFormFilters(DateTime day) {
    _filterProvider.resetFormFilters(day);
    alertNewFiltersSelected();
  }

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

  void setSort(Sort sortType) {
    _filterProvider.setSort(sortType);
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
      _filterProvider.setFilterAndSort();
      _filterController.sink.add(FilterComplete());
      print('in filter method and calling sink add!');
      _eventBlocSink.add(FetchCachedEvents());
    } catch (error) {
      _filterController.sink.add(FilterError());
    }
  }

  void dispose() {
    _filterController.close();
    _requestsController.close();
  }
}

/*FILTER BLOC input EVENTS */
abstract class FilterEvent extends Equatable {
  FilterEvent([List args = const []]) : super(args);
  void execute(FilterBloc filterBloc);
}

class ResetFormFilters extends FilterEvent {
  final DateTime day;
  ResetFormFilters(this.day) : super([day]);
  void execute(FilterBloc filterBloc) {
    filterBloc.resetFormFilters(day);
  }
}

class AddCategory extends FilterEvent {
  final Category category;
  AddCategory(this.category) : super([category]);
  void execute(FilterBloc filterBloc) {
    filterBloc.addCategory(category);
  }
}

class RemoveCategory extends FilterEvent {
  final Category category;
  RemoveCategory(this.category) : super([category]);
  void execute(FilterBloc filterBloc) {
    filterBloc.removeCategory(category);
  }
}

class AddLocation extends FilterEvent {
  final Location location;
  AddLocation(this.location) : super([location]);
  void execute(FilterBloc filterBloc) {
    filterBloc.addLocation(location);
  }
}

class RemoveLocation extends FilterEvent {
  final Location location;
  RemoveLocation(this.location) : super([location]);
  void execute(FilterBloc filterBloc) {
    filterBloc.removeLocation(location);
  }
}

class AddOrganization extends FilterEvent {
  final String organization;
  AddOrganization(this.organization) : super([organization]);
  void execute(FilterBloc filterBloc) {
    filterBloc.addOrganization(organization);
  }
}

class RemoveOrganization extends FilterEvent {
  final String organization;
  RemoveOrganization(this.organization) : super([organization]);
  void execute(FilterBloc filterBloc) {
    filterBloc.removeOrganization(organization);
  }
}

class SetCategories extends FilterEvent {
  final List<Category> categories;
  SetCategories(this.categories) : super([categories]);
  void execute(FilterBloc filterBloc) {
    filterBloc.setCategories(categories);
  }
}

class SetLocations extends FilterEvent {
  final List<Location> locations;
  SetLocations(this.locations) : super([locations]);
  void execute(FilterBloc filterBloc) {
    filterBloc.setLocations(locations);
  }
}

class SetOrganizations extends FilterEvent {
  final List<String> organizations;
  SetOrganizations(this.organizations) : super([organizations]);
  void execute(FilterBloc filterBloc) {
    filterBloc.setOrganizations(organizations);
  }
}

class SetSort extends FilterEvent {
  final Sort sort;
  SetSort(this.sort) : super([sort]);
  void execute(FilterBloc filterBloc) {
    filterBloc.setSort(sort);
  }
}

class ClearFilters extends FilterEvent {
  void execute(FilterBloc filterBloc) {
    filterBloc.clearFilters();
  }
}

class Filter extends FilterEvent {
  void execute(FilterBloc filterBloc) {
    filterBloc.filter();
  }
}

/*FILTER BLOC output STATES */
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
