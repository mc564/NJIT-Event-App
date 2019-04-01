import '../../lib/providers/date_provider.dart';
import 'package:test_api/test_api.dart';

void main() {

  DateProvider date = DateProvider(initialDay: DateTime(2019));

  //Testing the getters.

  test('Test: Getter Functions', () {
    
    var result1 = date.currentDay;
    var result2 = date.currentWeekEnd;
    var result3 = date.currentWeekStart;

    expect(result1.toString(), '2019-01-01 00:00:00.000');
    expect(result2.toString(), '2019-01-05 00:00:00.000');
    expect(result3.toString(), '2018-12-30 00:00:00.000');
  });

  //Let's move the date around.

  test('Test: Add One Day', () {

    date.addOneDay();

    expect(date.currentDay.toString(), '2019-01-02 00:00:00.000');
  });

  test('Test: Remove 1 Day', () {
    //Subtracting twice to account for previous test.
    date.subtractOneDay();
    date.subtractOneDay();

    expect(date.currentDay.toString(), '2018-12-29 00:00:00.000');
    date.addOneDay();
  });

  test('Test: Add 1 Week', () {

    date.addOneWeek();

    expect(date.currentDay.toString(), '2019-01-06 00:00:00.000');
    expect(date.currentWeekEnd.toString(), '2019-01-12 00:00:00.000');
    expect(date.currentWeekStart.toString(), '2019-01-06 00:00:00.000');
  });

  test('Test: Remove 1 Week', () {
    //Remove 2 to account for last test
    date.subtractOneWeek();
    date.subtractOneWeek();

    expect(date.currentDay.toString(), '2018-12-23 00:00:00.000');
    expect(date.currentWeekEnd.toString(), '2018-12-29 00:00:00.000');
    expect(date.currentWeekStart.toString(), '2018-12-23 00:00:00.000');

    date.addOneWeek();
  });

  test('Test: Remove 1 Month', () {

    date.subtractOneMonth();

    expect(date.currentDay.toString(), '2018-11-01 00:00:00.000');
    expect(date.currentWeekEnd.toString(), '2018-11-03 00:00:00.000');
    expect(date.currentWeekStart.toString(), '2018-10-28 00:00:00.000');
  });

  test('Test: Add 1 Month', () {

    //Adding 2 to undo the effects of last test
    date.addOneMonth();
    date.addOneMonth();

    expect(date.currentDay.toString(), '2019-01-01 00:00:00.000');
    expect(date.currentWeekEnd.toString(), '2019-01-05 00:00:00.000');
    expect(date.currentWeekStart.toString(), '2018-12-30 00:00:00.000');

    date.subtractOneMonth();
  });

  //What if we advance by a year?

  test('Test: Add 1 Year', () {
    
    //I'm a goof, I undid my loop because I thought it wasn't working the way I intended :P
    date.addOneMonth();
    date.addOneMonth();
    date.addOneMonth();
    date.addOneMonth();
    date.addOneMonth();
    date.addOneMonth();
    date.addOneMonth();
    date.addOneMonth();
    date.addOneMonth();
    date.addOneMonth();
    date.addOneMonth();
    date.addOneMonth();

    expect(date.currentDay.toString(), '2019-12-01 00:00:00.000');
  });

  //Or go back by a year?

  test('Test: Remove 1 Year', () {

    date.subtractOneMonth();
    date.subtractOneMonth();
    date.subtractOneMonth();
    date.subtractOneMonth();
    date.subtractOneMonth();
    date.subtractOneMonth();
    date.subtractOneMonth();
    date.subtractOneMonth();
    date.subtractOneMonth();
    date.subtractOneMonth();
    date.subtractOneMonth();
    date.subtractOneMonth();

    expect(date.currentDay.toString(), '2018-12-01 00:00:00.000');
  });
}