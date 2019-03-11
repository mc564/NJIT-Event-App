import '../models/category.dart';
import '../models/sort.dart';
import '../models/location.dart';
import '../models/filter.dart';
import 'package:flutter/material.dart';

//holds app state information about filters
class FilterProvider {
  List<Category> _selectedCategories;
  List<String> _selectedOrganizations;
  List<Location> _selectedLocations;
  Sort _sort;

  FilterProvider({
    @required List<Category> selectedCategories,
    @required List<String> selectedOrganizations,
    @required List<Location> selectedLocations,
    @required Sort sort,
  }) {
    _selectedCategories = selectedCategories;
    _selectedOrganizations = selectedOrganizations;
    _selectedLocations = selectedLocations;
    _sort = sort;
  }

  Map<FilterType, List<dynamic>> get filterParameters {
    Map<FilterType, List<dynamic>> filterParams = {
      FilterType.Category: _selectedCategories,
      FilterType.Location: _selectedLocations,
      FilterType.Organization: _selectedOrganizations,
    };
    return filterParams;
  }

  Sort get sortType => _sort;

  List<Category> get selectedCategories =>
      List<Category>.from(_selectedCategories);
  List<Location> get selectedLocations =>
      List<Location>.from(_selectedLocations);
  List<String> get selectedOrganizations =>
      List<String>.from(_selectedOrganizations);

  /* CATEGORY OPERATIONS */

  void addCategory(Category category) {
    _selectedCategories.add(category);
  }

  void removeCategory(Category category) {
    _selectedCategories.removeWhere((Category c) => c == category);
  }

  void setCategories(List<Category> categories) {
    _selectedCategories = List<Category>.from(categories);
  }

  /* LOCATION OPERATIONS */

  void addLocation(Location location) {
    _selectedLocations.add(location);
  }

  void removeLocation(Location location) {
    _selectedLocations.removeWhere((Location l) => l == location);
  }

  void setLocations(List<Location> locations) {
    _selectedLocations = List<Location>.from(locations);
  }

  /* ORGANIZATION OPERATIONS */

  void addOrganization(String org) {
    _selectedOrganizations.add(org);
  }

  void removeOrganization(String org) {
    _selectedOrganizations.removeWhere((String o) => o == org);
  }

  void setOrganizations(List<String> organizations) {
    _selectedOrganizations = List<String>.from(organizations);
  }

  void setSort(Sort sort) {
    _sort = sort;
  }

  void clearFilters() {
    _selectedCategories = List<Category>();
    _selectedLocations = List<Location>();
    _selectedOrganizations = List<String>();
  }
}
