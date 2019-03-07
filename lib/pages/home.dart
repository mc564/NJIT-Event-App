import 'package:flutter/material.dart';
import '../widgets/dropdown_button.dart';
import 'package:intl/intl.dart';
import './calendar.dart';
import './filter.dart';
import '../models/event.dart';
import '../widgets/daily_event_list.dart';
import './search.dart';

enum View { daily, weekly, monthly }

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  DateTime _day;
  View _view;
  int _prevPage;
  PageController _pageController;
  DailyEventListCache _dailyEventListCache;

  Widget _buildDailyView() {
    return _dailyEventListCache.currentList;
  }

  Container _buildWeeklyView() {
    return Container(child: Text('weekly'));
  }

  CalendarPage _buildMonthlyView() {
    return CalendarPage();
  }

  PopupMenuButton _buildHamburgerButton() {
    return PopupMenuButton(
      offset: Offset(0, 40),
      icon: Icon(Icons.dehaze, color: Colors.black),
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry> entries = List<PopupMenuEntry>();
        entries.add(PopupMenuItem(value: 'add', child: Text('Add An Event')));
        entries.add(PopupMenuItem(value: 'search', child: Text('Search')));
        entries.add(PopupMenuItem(value: '3', child: Text('item3')));
        return entries;
      },
      onSelected: (value) {
        print(value);
        if (value == 'add') {
          Navigator.pushNamed(context, '/add');
        } else if (value == 'search') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) {
              List<Event> list = List<Event>();
              list.addAll(_dailyEventListCache.allEvents);
              return SearchPage(list);
            }),
          );
        }
      },
    );
  }

  String _getFilterCountText() {
    int count = EventHelper.filterCategories.length +
        EventHelper.filterLocations.length + EventHelper.filterOrganizations.length;
    if (count < 9)
      return count.toString();
    else
      return '9+';
  }

  Builder _buildFilterButton() {
    String _filterCountString = _getFilterCountText();
    return Builder(
      builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            IconButton(
              alignment: Alignment(-5, 0),
              icon: Icon(Icons.tune, color: Colors.black),
              onPressed: () {
                if (_view == null) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.lightBlue[50],
                    content: Text(
                      'Please choose a view to enable filtering!',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    action: SnackBarAction(
                      label: 'DISMISS',
                      onPressed: () {
                        Scaffold.of(context).hideCurrentSnackBar();
                      },
                    ),
                    duration: Duration(seconds: 5),
                  ));
                } else {
                  List<Event> recentEvents = _dailyEventListCache.allEvents;
                  List<String> orgs = List<String>();
                  recentEvents.forEach((Event event) {
                    if (!orgs.contains(event.organization))
                      orgs.add(event.organization);
                  });
                  orgs.sort((String o1, String o2) => o1.compareTo(o2));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return FilterPage(
                        onSubmit: () async {
                          bool successfulRefresh =
                              await _dailyEventListCache.refresh();
                          if (successfulRefresh) setState(() {});
                          return successfulRefresh;
                        },
                        organizations: orgs,
                      );
                    }),
                  );
                }
              },
            ),
            Positioned(
              top: 7,
              right: 16,
              child: Container(
                alignment: Alignment(0.2, 0),
                child: Text(_filterCountString, style: TextStyle(fontSize: 13)),
                //color: Colors.pink,
                width: 20,
                height: 20,
                decoration: new BoxDecoration(
                  color: _filterCountString == '0' ? Colors.grey : Colors.pink,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  ViewDropDown _buildViewDropDown() {
    return ViewDropDown(
      onChanged: (value) {
        if (value == 'dailyView' && _view != View.daily) {
          setState(() {
            _view = View.daily;
          });
        } else if (value == 'weeklyView' && _view != View.weekly) {
          setState(() {
            _view = View.weekly;
          });
        } else if (value == 'monthlyView' && _view != View.monthly) {
          setState(() {
            _view = View.monthly;
          });
        }
      },
      day: _day,
    );
  }

  PageView _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemBuilder: (BuildContext context, int page) {
        if (_view == null) {
          return Center(
            child:
                Text('welcome to njit event planner!\n choose a view to begin'),
          );
        } else if (_view == View.daily) {
          return _buildDailyView();
        } else if (_view == View.weekly) {
          return _buildWeeklyView();
        } else {
          return _buildMonthlyView();
        }
      },
    );
  }

  void addOneDay() {
    _day = _day.add(Duration(days: 1));
    _dailyEventListCache.addOneDay();
  }

  void subtractOneDay() {
    _day = _day.subtract(Duration(days: 1));
    _dailyEventListCache.subtractOneDay();
  }

  void addOneWeek() {
    _day = _day.add(Duration(days: 7));
  }

  void subtractOneWeek() {
    _day = _day.subtract(Duration(days: 7));
  }

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
    _dailyEventListCache = DailyEventListCache(
      startDay: _day,
      getEventsBetween: EventHelper.getEventsBetween,
      getEventsOnDay: EventHelper.getEventsOnDay,
    );
    int initialPage = 20000;
    _pageController = PageController(
      initialPage: initialPage,
    );
    _prevPage = initialPage;
    _pageController.addListener(() {
      if (_pageController.page >= _prevPage + 1) {
        if (_view == View.daily) {
          setState(() {
            _prevPage += 1;
            addOneDay();
          });
        }
      } else if (_pageController.page <= _prevPage - 1) {
        if (_view == View.daily) {
          setState(() {
            _prevPage -= 1;
            subtractOneDay();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        leading: _buildHamburgerButton(),
        title: _buildViewDropDown(),
        actions: <Widget>[
          _buildFilterButton(),
        ],
      ),
      body: _buildPageView(),
    );
  }
}

//circular cache of size 15 (due to database limits for getting numbers of records at a time)
//overwrites old events when they are not needed anymore
//keeps one week of events before _day and one week after
class DailyEventListCache {
  int _cacheSize;
  int _halfCacheSize;
  List<DailyEventList> _cache;
  DateTime _day;
  int _idxDay; //index of the current day in the cache
  int _idxCacheStart; //index of the day cacheSize/2 days before current in cache
  int _idxCacheEnd; //index of the day cacheSize/2 days after current in the cache
  Function _getEventsOnDay;
  Function _getEventsBetween;

  DailyEventListCache(
      {int cacheSize = 15, //cacheSize must be odd for this to work
      @required DateTime startDay,
      @required Function getEventsOnDay,
      @required Function getEventsBetween}) {
    _getEventsBetween = getEventsBetween;
    _getEventsOnDay = getEventsOnDay;
    _cacheSize = cacheSize;
    _halfCacheSize = (_cacheSize / 2).floor();
    _cache = List<DailyEventList>(_cacheSize);
    _idxDay = _halfCacheSize;
    _idxCacheStart = 0;
    _idxCacheEnd = _cacheSize - 1;
    _day = startDay;

    //initialize daily list
    refresh();
  }

  Widget get currentList {
    if (_cache[_idxDay] == null)
      return Center(child: CircularProgressIndicator());
    return _cache[_idxDay];
  }

  List<Event> get allEvents {
    List<Event> rtn = List<Event>();
    for (int i = 0; i < _cacheSize; i++) {
      if (_cache[i] == null) continue;
      rtn.addAll(_cache[i].list);
    }
    return rtn;
  }

  void addOneDay() {
    _day = _day.add(Duration(days: 1));
    _idxDay = (_idxDay + 1) % _cacheSize;
    _idxCacheStart = (_idxCacheStart + 1) % _cacheSize;
    _idxCacheEnd = (_idxCacheEnd + 1) % _cacheSize;
    int idxToReplace = _idxCacheEnd;
    DateTime dateToAdd = _day.add(Duration(days: _halfCacheSize));
    _getEventsOnDay(dateToAdd).then((List<Event> results) {
      _cache[idxToReplace] = DailyEventList(
          key: PageStorageKey<String>(DateTime.now().toString()),
          events: results,
          day: dateToAdd);
    });
  }

  void subtractOneDay() {
    _day = _day.subtract(Duration(days: 1));
    _idxDay = (_idxDay == 0) ? _cacheSize - 1 : _idxDay - 1;
    _idxCacheStart =
        (_idxCacheStart == 0) ? _cacheSize - 1 : _idxCacheStart - 1;
    _idxCacheEnd = (_idxCacheEnd == 0) ? _cacheSize - 1 : _idxCacheEnd - 1;
    int idxToReplace = _idxCacheStart;
    DateTime dateToAdd = _day.subtract(Duration(days: _halfCacheSize));
    _getEventsOnDay(dateToAdd).then((List<Event> results) {
      _cache[idxToReplace] = DailyEventList(
          key: PageStorageKey<String>(DateTime.now().toString()),
          events: results,
          day: dateToAdd);
    });
  }

  Future<bool> refresh() async {
    List<Event> resultEvents = await _getEventsBetween(
        _day.subtract(Duration(days: _halfCacheSize)),
        _day.add(Duration(days: _halfCacheSize)));

    if (resultEvents == null) return true;
    List<Event> events = resultEvents;

    List<List<Event>> dateGroupedEvents = List<List<Event>>(_cacheSize);
    for (Event event in events) {
      DateTime eventStart = DateTime(
          event.startTime.year, event.startTime.month, event.startTime.day);
      int offset = _day.difference(eventStart).inDays;
      int groupedEventsIdx = 0;

      if (offset >= 0) {
        if ((_idxDay - offset) >= 0) {
          groupedEventsIdx = (_idxDay - offset);
        } else {
          groupedEventsIdx = _cacheSize + (_idxDay - offset);
        }
      } else {
        if ((_idxDay - offset) >= _cacheSize) {
          groupedEventsIdx = (_idxDay - offset) % _cacheSize;
        } else {
          groupedEventsIdx = (_idxDay - offset);
        }
      }
      if (dateGroupedEvents[groupedEventsIdx] == null) {
        dateGroupedEvents[groupedEventsIdx] = [];
      }
      dateGroupedEvents[groupedEventsIdx].add(event);
    }

    DateTime firstDay = _day.subtract(Duration(days: _halfCacheSize));
    for (int i = 0; i < dateGroupedEvents.length; i++) {
      _cache[i] = DailyEventList(
          key: PageStorageKey<String>(DateTime.now().toString()),
          day: firstDay.add(Duration(days: i)),
          events: dateGroupedEvents[i] == null ? [] : dateGroupedEvents[i]);
    }
    return true;
  }
}

class ViewDropDown extends StatelessWidget {
  final DateFormat dayFormatter = DateFormat('EEE, MMM d, y');
  final DateFormat weekDayFormatter = DateFormat('EEE, MMM d');
  final DateFormat monthFormatter = DateFormat('MMMM');
  final Function _onChanged;
  final DateTime _day;

  DateTime _getWeekStart() {
    int weekday = (_day.weekday % 7);
    return _day.subtract(Duration(days: weekday));
  }

  DateTime _getWeekEnd() {
    int weekday = (_day.weekday % 7);
    return _day.add(Duration(days: 6 - weekday));
  }

  ViewDropDown({Function onChanged, DateTime day})
      : _onChanged = onChanged,
        _day = day;

  Container _buildColoredTag(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 16)),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropDownButton(
        'Click me to change the view!',
        [
          DropdownMenuItem(
            value: 'dailyView',
            child: Row(
              children: <Widget>[
                _buildColoredTag('Day', Color(0xffFFB2FF)),
                Text(
                  dayFormatter.format(_day),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'weeklyView',
            child: Row(
              children: <Widget>[
                _buildColoredTag('Week', Colors.yellow),
                Text(
                  weekDayFormatter.format(_getWeekStart()) +
                      " - " +
                      weekDayFormatter.format(_getWeekEnd()),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'monthlyView',
            child: Row(
              children: <Widget>[
                _buildColoredTag('Month', Colors.cyan),
                Text(
                  monthFormatter.format(_day),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
        (String value) {
          _onChanged(value);
        },
      ),
    );
  }
}
