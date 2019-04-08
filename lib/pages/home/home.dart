import 'package:flutter/material.dart';

import '../../blocs/date_bloc.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/search_bloc.dart';
import '../../blocs/favorite_bloc.dart';
import '../../blocs/user_bloc.dart';
import '../../blocs/message_bloc.dart';
import '../../blocs/organization_bloc.dart';
import '../../blocs/edit_bloc.dart';

import './home_widgets.dart';

import '../../common/daily_event_list.dart';

import '../add/add.dart';
import '../calendar/calendar.dart';
import '../filter/filter.dart';
import '../search/search.dart';
import '../favorites/favorites.dart';
import '../organization/organization.dart';
import '../admin/admin.dart';
import '../message/message.dart';

import '../../models/user.dart';
import '../../models/event.dart';

enum View { daily, weekly, monthly }

class HomePage extends StatefulWidget {
  final UserBloc _userBloc;
//problems can arise when redirect to home page
  HomePage({@required UserBloc userBloc}) : _userBloc = userBloc;

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  EventBloc _eventBloc;
  EditEventBloc _editBloc;
  DateBloc _dateBloc;
  SearchBloc _searchBloc;
  FavoriteBloc _favoriteBloc;
  MessageBloc _messageBloc;
  OrganizationBloc _organizationBloc;
  PageController _pageController;
  int _prevPage;
  View _view;

  PopupMenuButton _buildHamburgerButton() {
    return PopupMenuButton(
      offset: Offset(0, 40),
      icon: Icon(Icons.dehaze, color: Colors.black),
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry> entries = List<PopupMenuEntry>();
        if (widget._userBloc.userTypes.contains(UserTypes.Admin)) {
          entries.add(
              PopupMenuItem(value: 'admin', child: Text('Administration')));
        }
        if (widget._userBloc.userTypes.contains(UserTypes.Admin) ||
            widget._userBloc.userTypes.contains(UserTypes.E_Board)) {
          entries.add(PopupMenuItem(value: 'add', child: Text('Add An Event')));
        }
        entries.add(PopupMenuItem(
            value: 'organizations', child: Text('Organizations')));
        entries.add(PopupMenuItem(value: 'search', child: Text('Search')));
        entries
            .add(PopupMenuItem(value: 'favorites', child: Text('Favorites')));
        entries.add(PopupMenuItem(value: 'messages', child: Text('Messages')));
        entries.add(PopupMenuItem(value: 'log out', child: Text('Log Out')));
        return entries;
      },
      onSelected: (value) {
        if (value == 'add') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AddPage(
                    editBloc: _editBloc,
                    eventListProvider: _eventBloc.eventListProvider,
                    orgProvider: _organizationBloc.organizationProvider,
                    isAdmin:
                        widget._userBloc.userTypes.contains(UserTypes.Admin),
                    ucid: widget._userBloc.ucid,
                  ),
            ),
          );
        } else if (value == 'search') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => SearchPage(
                    editBloc: _editBloc,
                    searchBloc: _searchBloc,
                    favoriteBloc: _favoriteBloc,
                    eventBloc: _eventBloc,
                    canEdit: _organizationBloc.canEdit,
                  ),
            ),
          );
        } else if (value == 'log out') {
          widget._userBloc.sink.add(Logout());
          Navigator.pushReplacementNamed(context, '/login');
        } else if (value == 'favorites') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => FavoritesPage(
                    editBloc: _editBloc,
                    favoriteBloc: _favoriteBloc,
                    eventBloc: _eventBloc,
                    canEditEvent: _organizationBloc.canEdit,
                  ),
            ),
          );
        } else if (value == 'organizations') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => OrganizationPage(
                    eventBloc: _eventBloc,
                    organizationBloc: _organizationBloc,
                    ucid: widget._userBloc.ucid,
                  ),
            ),
          );
        } else if (value == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AdminPage(
                    editBloc: _editBloc,
                    organizationBloc: _organizationBloc,
                    userBloc: widget._userBloc,
                    eventListProvider: _eventBloc.eventListProvider,
                  ),
            ),
          );
        } else if (value == 'messages') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  MessagePage(messageBloc: _messageBloc),
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
                          eventBloc: _eventBloc,
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
        editBloc: _editBloc,
        eventBloc: _eventBloc,
        favoriteBloc: _favoriteBloc,
        day: dateState.day,
        canEdit: _organizationBloc.canEdit,
        key: PageStorageKey<String>(DateTime.now().toString()));
  }

  Container _buildWeeklyView(DateLoaded state) {
    return Container(child: Text('weekly'));
  }

  CalendarPage _buildMonthlyView(DateLoaded state) {
    return CalendarPage(
      editBloc: _editBloc,
      eventBloc: _eventBloc,
      favoriteBloc: _favoriteBloc,
      dateBloc: _dateBloc,
      selectedDay: state.day,
      canEdit: _organizationBloc.canEdit,
    );
  }

  Container _buildStartupView() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Text(
            'Welcome to the NJIT Event Planner!\nChoose a view to begin.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Image.asset('images/welcome.png'),
        ],
      ),
    );
  }

  void _setDate(int page) {
    if (_view == View.daily) {
      if (page > _prevPage) {
        _dateBloc.sink.add(ToNextDay());
      } else if (page < _prevPage) {
        _dateBloc.sink.add(ToPrevDay());
      }
    } else if (_view == View.weekly) {
      if (page > _prevPage) {
        _dateBloc.sink.add(ToNextWeek());
      } else if (page < _prevPage) {
        _dateBloc.sink.add(ToPrevWeek());
      }
    } else if (_view == View.monthly) {
      if (page > _prevPage) {
        _dateBloc.sink.add(ToNextMonth());
      } else if (page < _prevPage) {
        _dateBloc.sink.add(ToPrevMonth());
      }
    }
    _prevPage = page;
  }

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    print('in init state of home!');
    _favoriteBloc = FavoriteBloc(ucid: widget._userBloc.ucid);
    _eventBloc = EventBloc(favoriteProvider: _favoriteBloc.favoriteProvider);
    _dateBloc = DateBloc(
      initialDay: DateTime(now.year, now.month, now.day),
    );
    _searchBloc = SearchBloc(eventListProvider: _eventBloc.eventListProvider);
    _messageBloc = MessageBloc(ucid: widget._userBloc.ucid);
    _organizationBloc = OrganizationBloc(
        messageProvider: _messageBloc.messageProvider,
        userProvider: widget._userBloc.userProvider);
    _editBloc = EditEventBloc(
        searchSink: _searchBloc.sink, favoriteSink: _favoriteBloc.sink);
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
    _favoriteBloc.dispose();
    _messageBloc.dispose();
    _organizationBloc.dispose();
    _editBloc.dispose();
    super.dispose();
  }
}
