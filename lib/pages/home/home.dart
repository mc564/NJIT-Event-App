import 'package:flutter/material.dart';
import '../../blocs/date_bloc.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/search_bloc.dart';
import './home_widgets.dart';
import '../../providers/event_list_provider.dart';
import '../add/add.dart';
import '../../common/daily_event_list.dart';
import '../calendar/calendar.dart';
import '../filter/filter.dart';
import '../search/search.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum View { daily, weekly, monthly }

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  EventListProvider _eventListProvider;
  EventBloc _eventBloc;
  DateBloc _dateBloc;
  SearchBloc _searchBloc;
  PageController _pageController;
  int _prevPage;
  View _view;

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
        if (value == 'add') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  AddPage(eventListProvider: _eventListProvider),
            ),
          );
        } else if (value == 'search') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  SearchPage(searchBloc: _searchBloc),
            ),
          );
        }
      },
    );
  }

  ViewDropDown _buildViewDropDown(DateLoaded state) {
    return ViewDropDown(
      onChanged: (String value) {
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
      day: state.day,
      weekStart: state.weekStart,
      weekEnd: state.weekEnd,
    );
  }

  String _getFilterCountText() {
    int count = _eventBloc.currentFilterCount;
    if (count < 9)
      return count.toString();
    else
      return '9+';
  }

  Builder _buildFilterButton(DateLoaded dateState) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) {
                      return FilterPage(
                          searchBloc: _searchBloc,
                          eventListProvider: _eventListProvider,
                          viewDay: dateState.day);
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

  DailyEventList _buildDailyView(DateLoaded dateState) {
    return DailyEventList(
        eventBloc: _eventBloc,
        day: dateState.day,
        key: PageStorageKey<String>(DateTime.now().toString()));
  }

  Container _buildWeeklyView(DateLoaded state) {
    return Container(child: Text('weekly'));
  }

  CalendarPage _buildMonthlyView(DateLoaded state) {
    return CalendarPage(
      eventBloc: _eventBloc,
      selectedDay: state.day,
    );
  }

  Center _buildStartupView() {
    return Center(
        child: Text('welcome to njit event planner!\n choose a view to begin'));
  }

  void _setDate(int page) {
    if (_view == View.daily) {
      if (page > _prevPage) {
        _dateBloc.toNextDay();
      } else if (page < _prevPage) {
        _dateBloc.toPrevDay();
      }
    } else if (_view == View.weekly) {
      if (page > _prevPage) {
        _dateBloc.toNextWeek();
      } else if (page < _prevPage) {
        _dateBloc.toPrevWeek();
      }
    } else if (_view == View.monthly) {
      if (page > _prevPage) {
        _dateBloc.toNextMonth();
      } else if (page < _prevPage) {
        _dateBloc.toPrevMonth();
      }
    }
    _prevPage = page;
  }

  @override
  void initState() {
    super.initState();
    
    DateTime now = DateTime.now();
    _eventListProvider = EventListProvider();
    _eventBloc = EventBloc(eventListProvider: _eventListProvider);
    _dateBloc = DateBloc(
      initialDay: DateTime(now.year, now.month, now.day),
    );
    _searchBloc =
        SearchBloc(searchEvents: true, eventListProvider: _eventListProvider);
    _view = null;
    //make it some ridiculously large number to allow scrolling both directions
    int initialPage = 20000;
    _prevPage = initialPage;
    _pageController = PageController(
      initialPage: initialPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('REBUILDING in HOME');

    return StreamBuilder<DateLoaded>(
      stream: _dateBloc.getDate,
      initialData: _dateBloc.initialState,
      builder: (BuildContext context, AsyncSnapshot<DateLoaded> snapshot) {
        DateLoaded state = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.lightBlue[50],
            leading: _buildHamburgerButton(),
            title: _buildViewDropDown(state),
            actions: <Widget>[_buildFilterButton(state)],
          ),
          body: PageView.builder(
            controller: _pageController,
            onPageChanged: _setDate,
            itemBuilder: (BuildContext context, int page) {
              if (_view == null) {
                return _buildStartupView();
              } else if (_view == View.daily) {
                return _buildDailyView(state);
              } else if (_view == View.weekly) {
                return _buildWeeklyView(state);
              } else {
                return _buildMonthlyView(state);
              }
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _dateBloc.dispose();
    _eventBloc.dispose();
    _searchBloc.dispose();
    super.dispose();
  }
}
