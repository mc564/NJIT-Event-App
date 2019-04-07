import '../../lib/models/event.dart';
import '../../lib/models/location.dart';
import '../../lib/models/category.dart';
import '../../lib/providers/edit_event_provider.dart';
import 'package:test_api/test_api.dart';

void main(){

  Event event1 = Event(eventId: 'abc', location: 'Campus Center', locationCode: Location.CC, title: 'Hello',
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.Miscellaneous,
    description: 'Spay me for the dooret.', favorited: false);
  Event event2 = Event(eventId: 'abc', location: 'Campus Center', locationCode: Location.CC, title: 'Hello',
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.Miscellaneous,
    description: 'Spay me for the dooret.', favorited: false);

  EditEventProvider edit = EditEventProvider(eventToEdit: event1);

  test('Test: Getters', () {

    var result1 = edit.id;
    var result2 = edit.location;
    var result3 = edit.title;
    var result4 = edit.startTime;
    var result5 = edit.endTime;
    var result6 = edit.organization;
    var result7 = edit.category;
    var result8 = edit.description;

    expect(result1, 'abc');
    expect(result2, 'Campus Center');
    expect(result3, 'Hello');
    expect(result4, DateTime.now());
    expect(result5, DateTime.now());
    expect(result6, 'NJIT');
    expect(result7, Category.Miscellaneous);
    expect(result8, 'Spay me for the dooret.');
  });

  test('Test: Validators, All Valid', () {

    var result1 = edit.locationValidator(edit.location);
    var result2 = edit.titleValidator(edit.title);
    var result3 = edit.orgValidator(edit.organization);
    var result4 = edit.categoryValidator(edit.category);

    expect(result1, null);
    expect(result2, null);
    expect(result3, null);
    expect(result4, null);
  });

  test('Test: Set all to Null', () {

    edit.setCategory(null);
    edit.setOrganization(null);
    edit.setLocation(null);
    edit.setTitle(null);
    edit.setDescription(null);

    var result1 = edit.category;
    var result2 = edit.description;
    var result3 = edit.location;
    var result4 = edit.title;
    var result5 = edit.organization;

    expect(result1, null);
    expect(result2, null);
    expect(result3, null);
    expect(result4, null);
    expect(result5, null);
  });

  test('Test: Validators, All Null', () {

    var result1 = edit.categoryValidator(edit.category);
    var result2 = edit.titleValidator(edit.title);
    var result3 = edit.orgValidator(edit.organization);
    var result4 = edit.locationValidator(edit.location);

    expect(result1, 'Category is required.');
    expect(result2, 'Title is required.');
    expect(result3, 'Organization is required.');
    expect(result4, 'Location is required.');
  });

  test('Test: Get All Selectable Categories', () {

    var result = edit.allSelectableCategories;

    expect(result, '');
  });

  test('Test: Set Form Variables', () {

    edit.setFormVariables();
    var result = edit.getEventFromFormData();

    expect(result.eventId, 'abc');
  });

  test('Test: Set Event to Edit', () {

    var result = edit.editEvent(event2);

    expect(result, true);
  });
}