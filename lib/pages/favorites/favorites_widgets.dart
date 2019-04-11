import 'package:flutter/material.dart';
import '../../blocs/favorite_bloc.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/edit_bloc.dart';
import '../../models/event.dart';
import '../detail/event_detail.dart';
import 'package:intl/intl.dart';

class FavoriteGridTile extends StatelessWidget {
  final EditEventBloc _editBloc;
  final FavoriteBloc _favoriteBloc;
  final EventBloc _eventBloc;
  final Function _canEditEvent;
  final Event _event;
  final int _color;

  FavoriteGridTile(
      {@required EditEventBloc editBloc,
      @required FavoriteBloc favoriteBloc,
      @required EventBloc eventBloc,
      @required Function canEditEvent,
      @required Event event,
      @required int color})
      : _editBloc = editBloc,
        _favoriteBloc = favoriteBloc,
        _eventBloc = eventBloc,
        _canEditEvent = canEditEvent,
        _event = event,
        _color = color;

  void _showAreYouSureDialog(BuildContext context, Event toRemove) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Would you like to remove the event [' +
                  toRemove.title +
                  '] from your favorites?\n This action cannot be undone.'),
              actions: <Widget>[
                FlatButton(
                    child: Text('Return'),
                    onPressed: () => Navigator.of(context).pop()),
                FlatButton(
                    child: Text('Yes, continue'),
                    onPressed: () {
                      _favoriteBloc.sink
                          .add(RemoveFavorite(eventToUnfavorite: toRemove));
                      Navigator.of(context).pop();
                    }),
              ]),
    );
  }

  String _cutShort(String s, int length) {
    if (s.length <= length)
      return s;
    else
      return s.substring(0, length + 1) + "...";
  }

  String _formatEventDuration(DateTime start, DateTime end) {
    DateFormat monthFormatter = DateFormat("MMMM");
    DateFormat timeFormatter = DateFormat.jm();
    if (start.day == end.day) {
      return monthFormatter.format(start) +
          " " +
          start.day.toString() +
          "  " +
          timeFormatter.format(start);
    }
    return monthFormatter.format(start) +
        " " +
        start.day.toString() +
        " - " +
        end.day.toString() +
        "  " +
        timeFormatter.format(start);
  }

  bool _happeningToday() {
    DateTime now = DateTime.now();
    DateTime start = _event.startTime;
    if (start.year == start.year &&
        start.month == now.month &&
        start.day == now.day)
      return true;
    else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(_color),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Image.network(
              'https://vignette.wikia.nocookie.net/line/images/b/bb/2015-brown.png/revision/latest?cb=20150808131630',
              width: 50,
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Text(_cutShort(_event.title, 35),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold)),
                      Text(
                        _formatEventDuration(_event.startTime, _event.endTime),
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: Colors.pink,
                  ),
                  onPressed: () => _showAreYouSureDialog(context, _event),
                ),
                IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Colors.lightBlue[200],
                  ),
                  onPressed: () {
                    _eventBloc.sink.add(AddViewToEvent(event: _event));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => EventDetailPage(
                              event: _event,
                              canEdit: _canEditEvent,
                              editBloc: _editBloc,
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
