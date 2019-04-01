import '../api/database_event_api.dart';
import '../models/event.dart';
import '../models/location.dart';
import '../models/category.dart';

import 'package:flutter/material.dart';

class EditEventProvider {
  //form variables
  Event _eventToEdit;
  String _id;
  String _location;
  String _title;
  DateTime _startDateTime;
  DateTime _endDateTime;
  String _organization;
  String _description;
  String _category;

  EditEventProvider({@required Event eventToEdit}) {
    _eventToEdit = eventToEdit;
    setFormVariables();
  }

  String get id => _id;
  String get location => _location;
  String get title => _title;
  DateTime get startTime => _startDateTime;
  DateTime get endTime => _endDateTime;
  String get organization => _organization;
  String get description => _description;
  String get category => _category;

  List<String> get allSelectableCategories {
    List<String> categories = List<String>();
    CategoryHelper.categoryFrom.forEach((String string, Category category) {
      categories.add(string);
    });
    return categories;
  }

  void setFormVariables() {
    _id = _eventToEdit.eventId;
    _location = _eventToEdit.location;
    _title = _eventToEdit.title;
    _startDateTime = _eventToEdit.startTime;
    _endDateTime = _eventToEdit.endTime;
    _organization = _eventToEdit.organization;
    _description = _eventToEdit.description;
    _category = CategoryHelper.getString(_eventToEdit.category);
  }

  void setID(String id) {
    _id = id;
  }

  void setLocation(String location) {
    _location = location;
  }

  void setTitle(String title) {
    _title = title;
  }

  void setStartTime(DateTime startTime) {
    _startDateTime = startTime;
  }

  void setEndTime(DateTime endTime) {
    _endDateTime = endTime;
  }

  void setOrganization(String org) {
    _organization = org;
  }

  void setDescription(String description) {
    _description = description;
  }

  void setCategory(String category) {
    _category = category;
  }

  String titleValidator(String title) {
    if (title == null || title.isEmpty)
      return 'Title is required.';
    else
      return null;
  }

  String orgValidator(String org) {
    if (org == null || org.isEmpty)
      return 'Organization is required.';
    else
      return null;
  }

  String locationValidator(String loc) {
    if (loc == null || loc.isEmpty)
      return 'Location is required.';
    else
      return null;
  }

  String categoryValidator(String category) {
    if (category == null || category.isEmpty)
      return 'Category is required.';
    else
      return null;
  }

  Event getEventFromFormData() {
    Event event = Event(
        eventId: _id,
        location: _location,
        title: _title,
        startTime: _startDateTime,
        endTime: _endDateTime,
        organization: _organization,
        description: _description,
        category: CategoryHelper.getCategory(_category),
        locationCode: LocationHelper.getLocationCode(_location),
        favorited: _eventToEdit.favorited);
    return event;
  }

  Future<bool> editEvent(Event event) {
    print("[MODEL] editing an event");
    return DatabaseEventAPI.editEvent(event).then((bool success) {
      if (success) {
        return true;
      } else {
        throw Exception("Editing an event failed.");
      }
    }).catchError((error) {
      throw Exception("Editing an event failed: " + error.toString());
    });
  }
}
