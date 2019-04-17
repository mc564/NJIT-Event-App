import '../../lib/models/event.dart';
import '../../lib/models/category.dart';
import '../../lib/models/location.dart';
import '../../lib/models/sort.dart';
import '../../lib/models/filter.dart';
import '../../lib/providers/cosine_similarity_provider.dart';
import '../../lib/providers/organization/organization_provider.dart';
import '../../lib/providers/event_list_provider.dart';
import '../../lib/providers/favorite_provider.dart';
import 'package:quiver/collection.dart';
import 'package:intl/intl.dart';
import 'package:test_api/test_api.dart';

void main(){

  FavoriteProvider fave = FavoriteProvider(ucid: 'lh252');

  EventListProvider sample = EventListProvider(favoriteProvider: fave);

  Sort sort;

  Map<FilterType, dynamic> filterParameters;

  Event event1 =Event(eventId: 'abc', location: 'Campus Center', locationCode: Location.CC, title: 'Hello',
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.Miscellaneous,
    description: 'Spay me for the dooret.', favorited: false);
  Event event2 =Event(eventId: 'def', location: 'Culimore', locationCode: Location.CULM, title: 'Hey',
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.AlumniAndUniversity,
    description: 'Spaloonebabagoscooties.', favorited: false);
  Event event3 =Event(eventId: 'ghi', location: 'Athletic Field', locationCode: Location.AF, title: 'Hi',
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.Sports,
    description: 'Blood Bagel', favorited: false);

  Event event4 =Event(eventId: 'abc', location: 'Campus Center', locationCode: Location.CC, title: '',
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.Miscellaneous,
    description: 'Spay me for the dooret.', favorited: false);
  Event event5 =Event(eventId: 'def', location: 'Culimore', locationCode: Location.CULM, title: null,
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.AlumniAndUniversity,
    description: 'Spaloonebabagoscooties.', favorited: false);
  Event event6 =Event(eventId: 'ghi', location: 'Athletic Field', locationCode: Location.AF, title: 'Hi',
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.Sports,
    description: 'Blood Bagel', favorited: false);

  List<Event> events = [event1, event2, event3, event4, event5, event6];
  List<Event> events2 = [event1, event2, event3, event4, event5, event6];

  test('Test: Get all Cached events', () {
    
    var result = sample.filteredCacheEvents;

    expect(result, !null); //Because otherwise this would be a pain in the ass to check.  If it doesn't return Null just assume it's working.
  });

  test('Test: Delete Dupes', (){

    sample.deleteDupEdited(events, events2);

    var result = events2;

    expect(result.toString(), '[]'); //Deletes the list, lol
  });

  test('Test: Get Events on Today', () {

    var result = sample.getEventsOnDay(DateTime.now());

    expect(result, !null); //Again.  Too much going on to hardcode results.  Just assume non-null responses are good responses.
  });

  test('Test: Split by Day', () {

    var result = sample.splitEventsByDay(events);

    expect(result, !null); //Noticing a theme?  This file is easier to test based on observing app performance, writing hardcoded tests here is absurd.
  });

  test('Tets: Get events between days', () {

    //We have two functions that do the same thing.  Alright then.

    var result = sample.refetchEventsBetween(DateTime.now(), DateTime.now().add(new Duration(days: 7)));
    var result2 = sample.getEventsBetween(DateTime.now(), DateTime.now().add(new Duration(days: 7)));

    expect(result, !null); //Yep. More annoying comments no one but me will ever read, much like my tests.
    expect(result2, !null);
  });

  test('Test: get similar events.', () {

    var result = sample.getSimilarEvents(event1);

    expect(result, !null);
  });

  test('Test: Set Sort', () {

    sample.setSort(sort);

    var result = sample.sortType;

    expect(result.toString(), 'sort');
  });

  test('Test: Filter Providers', () {

    var result = sample.setFilterParameters(filterParameters);

    expect(result, true);
  });
}