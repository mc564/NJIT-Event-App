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

  EditEventProvider edit = EditEventProvider();
  edit.setEventToEdit(event1);

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
    var result5 = edit.descriptionValidator(edit.description);

    expect(result1, null);
    expect(result2, null);
    expect(result3, null);
    expect(result4, null);
    expect(result5, null);
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

  test('Test: Validator, LFD', () {

    //Fuck me, 1000 characters?? If you say so, kiddos.

    edit.setDescription('0j9e1w8I5SGTPhjL0ZOKv7XVzDsdpQiaUJENUHhOZPZHqz3HyDe5mtefcn5tEShQXxRT4JB40APk4E1gDrdeqTbaw0jccaAb5iDwtcgoNjBtxANWYcn073I0xRycYlDOMOCOecl8Jzi4aYXzCb0461RcPlDqe55ltdedUQN0Yd3Bvet70uSXt8iT3JHM5kpWJB2M5usRg2C9ttLjLUewH3cYohwNkel8JW2oteRTvtLGl8f6njDKeqXIYHurdZDs6ffGEaNfWy6rs2PJVXYRFp7sknjK37S9nn7tKy0HJcotWmIrJThA66yi5aW2IMfFE0KhgpVY0ZZArtM3DXojMQ1rmTqGqGfcxhI54yQ63tDVoAbhsfsBEm8PJMbhnuFoNUJ30uXF0LaC31HD99LxqYVVC1nfh832SMSiMKIkRTTlPieNwUjbFtsVwBTkRHeYzxNVnglSgsWnpOfojYqqxsp74CEt2SZmMz2CbqQkqBdFzpnw6RRyyvQ9AHRLNEXXXlPqGgBhcoC766VekhWUv4n5Qimc0eT0C8jJ1rw0JL7bvcQp53llrbbjWfj13G9rtd3fuugVJ0eEXfx3rwlcYsuZqzcdNiT1cgVmtDm7Jkuj9G0LSqtXfgw0PYgqr8vbt4PepkLJnNkZ2OlVSV2TFV6eomXVJWGh464bjLH5sJmgEtxAB02Smkhj6Yv1b5g3BJrIoh4YJbwZLg6tn7xypvodDlxKZyHJyHnuMobbjFAuZZ16Jmc6gx14KLVzrLwIoP6ot2ra2eXJoITuhuZLtrjvpPy9xt5Waq3BZa1b9QfITpRJPgZzQrTJcXFAfmvQuNYseIwDnpYSGokF7wqLp9Fh8o6oUIJnAPAFhVOi6qovnxa5I57B59z0W4sMISeSd3BwoF4PeVcWExxCdPOUuL4Nv7D2gCmqpYXqgJ9DQNGAoAfOi4fU8EOnt1UYGiHDY8hpHTu6aGB1keCwJDu1W2xvw3mFexCfLjQsL6E6a');

    var result = edit.descriptionValidator(edit.description);

    expect(result, 'Description must be shorter than 1000 characters.');
  });

  test('Test: Validator, LFT', () {

    edit.setTitle('vzsYA1wwPWRYWM6OaJMCJXCbnqIqwnjULxvD6riAUE49XAyy1DvbdxrdOMfcxisDgyzly8hIo0p98oxwqvpoIIM6zFaUzAjnPbO9WccrkDmoijq9N6jREbv2xkdB3jDiC8q9egWEqqfytItA3xxdREbp2tuGjWwPsdPV6Q9zbkj1rUh0neHrtPYZzBy7YCXtGmJzQERlnBAoOfOjwhl0Vz2zSeXnGBbFdDKeeFLQYOpmg7jYvg88n8KeOjdhbLJXH');

    var result = edit.titleValidator(edit.title);

    expect(result, 'Title must be shorter than 256 characters');
  });

  test('Test: Get All Selectable Categories', () {

    var result = edit.allSelectableCategories;

    expect(result, '');
  });

  test('Test: Get Form Variables', () {

    var result = edit.getEventFromFormData();

    expect(result.eventId, 'abc');
  });

  test('Test: Set Event to Edit', () {

    var result = edit.editEvent(event2);

    expect(result, true);
  });

  test('Test: Is Different', () {

    var result = edit.noChangesMade();

    expect(result, true);
  });
}