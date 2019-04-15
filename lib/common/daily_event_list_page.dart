import 'package:flutter/material.dart';
import '../blocs/edit_bloc.dart';
import '../blocs/event_bloc.dart';
import '../blocs/favorite_rsvp_bloc.dart';
import 'package:intl/intl.dart';
import './daily_event_list.dart';

class DailyEventListPage extends StatelessWidget {
  final DateTime _day;
  final EditEventBloc _editBloc;
  final EventBloc _eventBloc;
  final FavoriteAndRSVPBloc _favoriteAndRSVPBloc;
  final Function _canEdit;
  final DateFormat _dayFormatter;
  final Key _key;

  DailyEventListPage(
      {@required EventBloc eventBloc,
      @required EditEventBloc editBloc,
      @required FavoriteAndRSVPBloc favoriteAndRSVPBloc,
      @required Function canEdit,
      @required DateTime day,
      Key key})
      : _eventBloc = eventBloc,
        _favoriteAndRSVPBloc = favoriteAndRSVPBloc,
        _editBloc = editBloc,
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
          backgroundColor: Colors.black,
          title: Text(_getTitle(), style: TextStyle(color: Color(0xfffff1f3)))),
      body: DailyEventList(
        day: _day,
        eventBloc: _eventBloc,
        editBloc: _editBloc,
        key: _key,
        favoriteAndRSVPBloc: _favoriteAndRSVPBloc,
        canEdit: _canEdit,
      ),
    );
  }
}
