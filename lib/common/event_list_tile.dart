import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/category.dart';
import 'package:intl/intl.dart';
import '../pages/detail/event_detail.dart';
import '../blocs/favorite_bloc.dart';
import '../blocs/event_bloc.dart';
import '../blocs/edit_bloc.dart';

class EventListTile extends StatefulWidget {
  final Event _event;
  final int _color;
  final FavoriteBloc _favoriteBloc;
  final EditEventBloc _editBloc;
  final EventBloc _eventBloc;
  final Function _canEdit;

  EventListTile(
      {@required Event event,
      @required int color,
      @required FavoriteBloc favoriteBloc,
      @required EditEventBloc editBloc,
      @required EventBloc eventBloc,
      @required Function canEdit})
      : _event = event,
        _color = color,
        _favoriteBloc = favoriteBloc,
        _editBloc = editBloc,
        _eventBloc = eventBloc,
        _canEdit = canEdit;

  @override
  State<StatefulWidget> createState() {
    return _EventListTileState();
  }
}

class _EventListTileState extends State<EventListTile> {
  //formats start and end times in a nice format for reading
  String formatEventDuration(DateTime start, DateTime end) {
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

  //returns a string up to length chars + ... if meets char limit
  String cutShort(String s, int length) {
    if (s.length <= length)
      return s;
    else
      return s.substring(0, length + 1) + "...";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      decoration: BoxDecoration(color: Color(widget._color)),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 14, right: 8, bottom: 5),
        leading: Padding(
          padding: EdgeInsets.only(top: 17),
          child: Image.network(
            'https://vignette.wikia.nocookie.net/line/images/b/bb/2015-brown.png/revision/latest?cb=20150808131630',
            width: 50,
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(cutShort(widget._event.title, 40),
                style: TextStyle(fontSize: 18)),
            Text(cutShort(widget._event.location, 35),
                style: TextStyle(fontSize: 15)),
            Text(
                formatEventDuration(
                    widget._event.startTime, widget._event.endTime),
                style: TextStyle(fontSize: 14)),
            Text(CategoryHelper.getString(widget._event.category),
                style: TextStyle(fontSize: 14)),
          ],
        ),
        trailing: Container(
          width: 50,
          child: Column(
            children: <Widget>[
              IconButton(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                icon: Icon(
                  widget._event.favorited
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.pink,
                ),
                onPressed: () {
                  if (widget._event.favorited)
                    widget._favoriteBloc.sink
                        .add(RemoveFavorite(eventToUnfavorite: widget._event));
                  else
                    widget._favoriteBloc.sink
                        .add(AddFavorite(eventToFavorite: widget._event));
                  setState(() {});
                },
              ),
              IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Colors.lightBlue[200],
                  ),
                  onPressed: () {
                    widget._eventBloc.sink
                        .add(AddViewToEvent(event: widget._event));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        maintainState: false,
                        builder: (BuildContext context) => EventDetailPage(
                              event: widget._event,
                              canEdit: widget._canEdit,
                              editBloc: widget._editBloc,
                            ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
