import 'package:flutter/material.dart';
import '../../common/daily_event_list.dart';
import 'package:intl/intl.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/favorite_bloc.dart';

class DailyEventListPage extends StatelessWidget {
  final DateTime _day;
  final FavoriteBloc _favoriteBloc;
  final EventBloc _eventBloc;
  final Function _canEdit;
  final DateFormat _dayFormatter;
  final Key _key;

  DailyEventListPage(
      {@required EventBloc eventBloc,
      @required FavoriteBloc favoriteBloc,
      @required Function canEdit,
      @required DateTime day,
      Key key})
      : _eventBloc = eventBloc,
        _favoriteBloc = favoriteBloc,
        _canEdit = canEdit,
        _day = day,
        _dayFormatter = DateFormat('EEE, MMM d, yyyy'),
        _key = key,
        super(key: key);

  String _getTitle() {
    String _title;
    if (_day == null)
      _title = 'Events for Day';
    else
      _title = 'Events for ' + _dayFormatter.format(_day);
    return _title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xffffb2ff),
          title: Text(_getTitle(), style: TextStyle(color: Color(0xff98ff98)))),
      body: DailyEventList(
        day: _day,
        eventBloc: _eventBloc,
        key: _key,
        favoriteBloc: _favoriteBloc,
        canEdit: _canEdit,
      ),
    );
  }
}
