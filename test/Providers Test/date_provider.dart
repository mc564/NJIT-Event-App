import '../../lib/providers/date_provider.dart';
import 'package:test_api/test_api.dart';

void main() {

  DateProvider date = DateProvider(initialDay: DateTime(2019));

  //Testing the getters.

  test('Test: Getter Functions', () {
    
    var result1 = date.currentDay;
    var result2 = date.currentWeekEnd;
    var result3 = date.currentWeekStart;

    expect(result1.toString(), '01-01-2019');
    expect(result2.toString(), '12-30-2018');
    expect(result3.toString(), '01-05-2019');
  });

  //Let's move the date around.

  test('Test: Add One Day', () {

    date.addOneDay();

    expect(date.currentDay.toString(), '01-02-2019');
  });

  test('Test: Remove 1 Day', () {
    //Subtracting twice to account for previous test.
    date.subtractOneDay();
    date.subtractOneDay();

    expect(date.currentDay.toString(), '12-31-2018');
    date.addOneDay();
  });

  test('Test: Add 1 Week', () {

    date.addOneWeek();

    expect(date.currentDay.toString(), '01-08-2019');
    expect(date.currentWeekEnd.toString(), '01-15-2019');
    expect(date.currentWeekStart.toString(), '01-01-2019');
  });

  test('Test: Remove 1 Week', () {
    //Remove 2 to account for last test
    date.subtractOneWeek();
    date.subtractOneWeek();

    expect(date.currentDay.toString(), '12-28-2018');
    expect(date.currentWeekEnd.toString(), '12-07-2018');
    expect(date.currentWeekStart.toString(), '12-21-2018');

    date.addOneWeek();
  });

  test('Test: Remove 1 Month', () {

    date.subtractOneMonth();

    expect(date.currentDay.toString(), '12-01-2018');
    expect(date.currentWeekEnd.toString(), '12-07-2018');
    expect(date.currentWeekStart.toString(), '11-28-2018');
  });

  test('Test: Add 1 Month', () {

    //Adding 2 to undo the effects of last test
    date.addOneMonth();
    date.addOneMonth();

    expect(date.currentDay.toString(), '02-01-2019');
    expect(date.currentWeekEnd.toString(), '02-08-2019');
    expect(date.currentWeekStart.toString(), '01-28-2019');

    date.subtractOneMonth();
  });

  //What if we advance by a year?

  test('Test: Add 1 Year', () {
    
    for (var i = 0; i < 12; i++) {
      date.addOneMonth();
    }

    expect(date.currentDay.toString(), '01-01-2020');
  });

  //Or go back by a year?

  test('Test: Remove 1 Year', () {

    for (var i = 0; i < 12; i++) {
      date.subtractOneMonth();
    }

    expect(date.currentDay.toString(), '01-01-2018');
  });
}