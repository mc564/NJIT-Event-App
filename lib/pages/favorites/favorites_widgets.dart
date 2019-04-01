import 'package:flutter/material.dart';
import '../../blocs/favorite_bloc.dart';
import '../../models/event.dart';
import '../detail/event_detail.dart';
import 'package:intl/intl.dart';

class FavoriteGridTile extends StatelessWidget {
  final FavoriteBloc _favoriteBloc;
  final Function _addViewToEvent;
  final Function _canEditEvent;
  final Event _event;
  final int _color;

  FavoriteGridTile(
      {@required FavoriteBloc favoriteBloc,
      @required Function addViewToEvent,
      @required Function canEditEvent,
      @required Event event,
      @required int color})
      : _favoriteBloc = favoriteBloc,
        _addViewToEvent = addViewToEvent,
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
                      _favoriteBloc.removeFavorite(toRemove);
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
      child: Stack(children: <Widget>[
        _happeningToday()
            ? Positioned(
                left: 0,
                child: IconButton(
                  icon: Icon(Icons.check_circle, color: Colors.white),
                  onPressed: () {},
                ),
              )
            : Container(),
        Positioned(
          right: 0,
          child: IconButton(
            icon: Icon(Icons.favorite, color: Color(0xffFFC0CB)),
            onPressed: () => _showAreYouSureDialog(context, _event),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            color: Colors.white,
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 3),
                  width: 110,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _cutShort(_event.title, 15),
                        maxLines: 1,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatEventDuration(_event.startTime, _event.endTime),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                IconButton(
                    padding: EdgeInsets.all(0),
                    alignment: Alignment.centerLeft,
                    icon: Icon(Icons.info),
                    onPressed: () {
                      _addViewToEvent(_event);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => EventDetailPage(
                                event: _event,
                                canEdit: _canEditEvent,
                              ),
                        ),
                      );
                    }),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
