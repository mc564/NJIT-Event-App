import '../../lib/models/event.dart';
import '../../lib/models/location.dart';
import '../../lib/models/category.dart';
import '../../lib/providers/favorite_provider.dart';
import 'package:test_api/test_api.dart';

void main() {

  Event event1 = Event(eventId: 'abc', location: 'Campus Center', locationCode: Location.CC, title: 'Hello',
    startTime: DateTime.now(), endTime: DateTime.now(), organization: 'NJIT', category: Category.Miscellaneous,
    description: 'Spay me for the dooret.', favorited: false);
  
  FavoriteProvider fave = FavoriteProvider(ucid: 'lh252');

  test('Test: Initialized', () {

    var result = fave.initialize();

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
}