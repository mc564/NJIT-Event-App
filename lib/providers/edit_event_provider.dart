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
  int _standardFieldMaxLength;
  int _descriptionMaxLength;

  EditEventProvider() {
    _standardFieldMaxLength = 256;
    _descriptionMaxLength = 1000;
    _eventToEdit = Event(
      eventId: null,
      location: null,
      organization: null,
      locationCode: null,
      favorited: false,
      description: null,
      title: null,
      category: Category.Miscellaneous,
      startTime: null,
      endTime: null,
    );
    _id = _eventToEdit.eventId;
    _location = _eventToEdit.location;
    _title = _eventToEdit.title;
    _startDateTime = _eventToEdit.startTime;
    _endDateTime = _eventToEdit.endTime;
    _organization = _eventToEdit.organization;
    _description = _eventToEdit.description;
    _category = CategoryHelper.getString(_eventToEdit.category);
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

  bool _noChangesMade() {
    if (_eventToEdit.title == _title &&
        _eventToEdit.description == _description &&
        CategoryHelper.getString(_eventToEdit.category) == _category &&
        _eventToEdit.location == _location &&
        _eventToEdit.endTime == _endDateTime &&
        _eventToEdit.startTime == _startDateTime) {
      return true;
    }
    return false;
  }

  bool setEventToEdit(Event eventToEdit) {
    try {
      _id = eventToEdit.eventId;
      _location = eventToEdit.location;
      _title = eventToEdit.title;
      _startDateTime = eventToEdit.startTime;
      _endDateTime = eventToEdit.endTime;
      _organization = eventToEdit.organization;
      _description = eventToEdit.description;
      _category = CategoryHelper.getString(eventToEdit.category);
      _eventToEdit = eventToEdit;
      return true;
    } catch (error) {
      throw Exception('Error in EditEventProvider setEventToEdit method: ' +
          error.toString());
    }
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
    else if (title.length > _standardFieldMaxLength)
      return 'Title must be shorter than ' +
          _standardFieldMaxLength.toString() +
          ' characters.';
    else
      return null;
  }

  //description can be null initially
  //in some of the njit events, so no empty validation error
  //for this one
  String descriptionValidator(String desc) {
    if (desc.length > _descriptionMaxLength)
      return 'Description must be shorter than ' +
          _descriptionMaxLength.toString() +
          ' characters.';
    else
      return null;
  }

  //organization is fixed for editing, so I don't need to do much validation
  String orgValidator(String org) {
    if (org == null || org.isEmpty)
      return 'Organization is required.';
    else
      return null;
  }

  String locationValidator(String loc) {
    if (loc == null || loc.isEmpty)
      return 'Location is required.';
    else if (loc.length > _standardFieldMaxLength)
      return 'Location must be shorter than ' +
          _standardFieldMaxLength.toString() +
          ' characters.';
    else
      return null;
  }

  //category length should be restrained in UI due to limited options (dropdown)
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
    if (_noChangesMade()) {
      throw Exception(
          'No changes made from original. Cannot submit edit changes. YOU HAVE TO EDIT SOMETHING TO EDIT SOMETHING!!');
    }
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
