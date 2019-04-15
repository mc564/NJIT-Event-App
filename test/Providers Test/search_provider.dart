import '../../lib/providers/search_provider.dart';
import '../../lib/models/event.dart';
import '../../lib/models/category.dart';
import '../../lib/models/location.dart';
import 'package:test_api/test_api.dart';

void main() {

  SearchProvider sp =SearchProvider();
  SearchProvider sp2 =SearchProvider();

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

  List<Event> events = [event1, event2, event3];
  List<Event> events2 = [event4, event5, event6];

  List<String> strings = ['pineapple', 'cherry', 'orange'];
  List<String> strings2 = ['', null, 'orange'];

  sp.setAllSearchableEvents(events);
  sp.setAllSearchableStrings(strings);

  sp2.setAllSearchableEvents(events2);
  sp2.setAllSearchableStrings(strings2);

  test('Test: string matches, successful', (){

    var result = sp.tokenStringMatches('orange');

    expect(result[0], 'orange');
  });

  test('Test: string matches, unsuccessful', (){

    var result = sp.tokenStringMatches('apple');

    expect(result[0], 'pineapple');//Returns most similar? Or array is unsorted?
  });

  test('Test: event matches, successful', (){

    var result = sp.tokenEventMatches('Hello');

    expect(result[0].toString(), 'Event[title: Hello]');//Unless the returned array starts with a different attribute?
  });

  test('Test: event matches, unsuccessful', (){

    var result = sp.tokenStringMatches('Bye');

    expect(result, []);
  });

  test('Test: error message', () {

    var result = sp.noResultsFoundMessage('token'); //just to see what it does

    expect(result, 'No results found for token.');
  });

  test('Test: event search, successful', () {
    var result = sp.tokenEventSearch('Hello');

    expect(result.toString(), '[[Event[title: Hello]], No results found for Hello.]'); //I am confused by what this returns?
  });

  test('Test: event search, unsuccessful', () {
    var result = sp.tokenEventSearch('Bye');

    expect(result.toString(), '[[], No results found for Bye.]'); 
  });

  test('Test: string search, successful', () {
    var result = sp.tokenEventSearch('orange');

    expect(result.toString(), '[[], No results found for orange.]');
  });

  test('Test: event search, unsuccessful', () {
    var result = sp.tokenEventSearch('Apple');

    expect(result.toString(), '[[], No results found for Apple.]');
  });

  //now to test the unlikey stuff

  test('Test: event search, empty', () {

    var result = sp2.tokenEventSearch(''); //testing not only if it will search for an empty string, but if it will search through one as well

    expect(result.toString(), '[[], No results found for "".]');
  });

  test('Test: event search, null', () {

    var result = sp2.tokenEventSearch(null);

    expect(result.toString(), '[[], No results found for "".]');
  });

  test('Test: string search, empty', () {

    var result = sp2.tokenStringSearch(''); 

    expect(result.toString(), '[[], No results found for "".]');
  });

  test('Test: string search, null', () {

    var result = sp2.tokenStringSearch(null);

    expect(result.toString(), '[[], No results found for "".]');
  });
}