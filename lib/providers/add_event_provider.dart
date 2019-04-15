import 'package:uuid/uuid.dart';
import '../api/database_event_api.dart';
import '../models/event.dart';
import '../models/location.dart';
import '../models/category.dart';

class AddEventProvider {
  //form variables
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

  AddEventProvider() {
    print('in add event provider constructor!');
    clear();
    _standardFieldMaxLength = 256;
    _descriptionMaxLength = 1000;
  }

  String get id => _id;
  String get location => _location;
  String get title => _title;
  DateTime get startTime => _startDateTime;
  DateTime get endTime => _endDateTime;
  String get organization => _organization;
  String get description => _description;
  String get category => _category;
  //all selectable categories in the add event page
  List<String> get allSelectableCategories {
    List<String> categories = List<String>();
    CategoryHelper.categoryFrom.forEach((String string, Category category) {
      categories.add(string);
    });
    return categories;
  }
  //all selectable locations

  void clear() {
    _id = null;
    _location = null;
    _title = null;
    DateTime now = DateTime.now();
    _startDateTime = now;
    _endDateTime = now;
    _organization = null;
    _description = null;
    _category = null;
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
    print('in add event provider, set start date to : ' + startTime.toString());
    _startDateTime = startTime;
  }

  void setEndTime(DateTime endTime) {
    print('in add event provider, set end date to : ' + endTime.toString());

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

  //organization length should be validated because of constrained options (dropdown)
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

  String descriptionValidator(String desc) {
    if (desc == null || desc.isEmpty)
      return 'Description is required.';
    else if (desc.length > _descriptionMaxLength)
      return 'Description must be shorter than ' +
          _descriptionMaxLength.toString() +
          ' characters.';
    else
      return null;
  }

  //category length should be validated because of constrained options (dropdown)
  String categoryValidator(String category) {
    if (category == null || category.isEmpty)
      return 'Category is required.';
    else
      return null;
  }

  Event getEventFromFormData() {
    print('getting event from data to add to db');
    print('start: ' + startTime.toString() + " end: " + endTime.toString());
    Uuid idGen = Uuid();
    Event event = Event(
        eventId: idGen.v4(),
        location: _location,
        title: _title,
        startTime: _startDateTime,
        endTime: _endDateTime,
        organization: _organization,
        description: _description,
        category: CategoryHelper.getCategory(_category),
        locationCode: LocationHelper.getLocationCode(_location),
        favorited: false);
    return event;
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
}
