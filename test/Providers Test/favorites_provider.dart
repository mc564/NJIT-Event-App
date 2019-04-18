import '../../lib/models/event.dart';
import '../../lib/models/location.dart';
import '../../lib/models/category.dart';
import '../../lib/providers/favorite_provider.dart';
import 'package:test_api/test_api.dart';

void main() {

  Event event1 = Event(eventId: 'abc', location: 'Campus Center', locationCode: Location.CC, title: 'Hello',
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.Miscellaneous,
    description: 'Spay me for the dooret.', favorited: false);
  Event event2 = Event(eventId: 'abc', location: 'Campus Center', locationCode: Location.CC, title: 'Hello',
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.Miscellaneous,
    description: 'Spay me for the dooret.', favorited: false);
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

  FavoriteProvider fave = FavoriteProvider(ucid: 'lh252');
  List<String> list = new List();
  list[0] = 'ghi';
  list[1] = 'def';

  test('Test: Fetch Faves', () {

    //Did i miss this first time around? ah well.

    var result = fave.fetchFavorites();

    expect(result, true);
  });

  test('Test: No Faves', () {

    var result = fave.allFavorites;

    expect(result, null);
  });

  test('Test: Check if favorited, no faves', () {

    var result = fave.favorited(event1);

    expect(result, false);
  });

  test('Test: add favorite', () {

    var result = fave.addFavorite(event1);

    expect(result, true);
  });

  test('Test: check if added', () {

    var result = fave.favorited(event1);

    expect(result, true);
  });

  test('Test: See List', () {

    var result = fave.allFavorites;

    expect(result.toString(), '[Hello]');
  });

  test('Test: remove fave', () {

    var result = fave.removeFavorite(event1);

    expect(result, true);
  });

  test('Test: check if removed', () {

    var result = fave.favorited(event1);

    expect(result, false);
  });

  test('Test: Add a List of Faves', () {

    fave.addFavorite(event1);
    fave.addFavorite(event2);
    fave.addFavorite(event3);
    fave.addFavorite(event4);
    fave.addFavorite(event5);
    fave.addFavorite(event6);

    var result = fave.allFavorites;

    expect(result.toString(), '[Hello, Hello, Hi, , , Hi]');
  });

  test('Test: Remove Half of Faves', () {

    var result1 = fave.removeSelectedFavorites(list);
    var result2 = fave.allFavorites;

    expect(result1, true);
    expect(result2.toString(), '[Hello, Hello, ,]');
  });

  test('Test: Remove All Faves', () {

    var result1 = fave.removeAllFavorites();
    var result2 = fave.allFavorites;

    expect(result1, true);
    expect(result2, null);
  });

  //Decommissioned due to the method being removed. May you rest in peace, sweet prince.
  /*
  test('Test: Initialized', () {

    var result = fave.initialize();

    expect(result, true);
  });
  */
}