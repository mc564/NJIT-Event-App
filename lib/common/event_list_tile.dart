import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../models/category.dart';

import '../pages/detail/event_detail.dart';

import '../blocs/event_bloc.dart';
import '../blocs/edit_bloc.dart';
import '../blocs/favorite_bloc.dart';
import '../blocs/favorite_rsvp_bloc.dart';

class EventListTileBasicStyle extends StatefulWidget {
  final Event _event;
  final int _color;
  final EditEventBloc _editBloc;
  final EventBloc _eventBloc;
  final FavoriteAndRSVPBloc _favoriteAndRSVPBloc;
  final Function _canEdit;

  EventListTileBasicStyle(
      {@required Event event,
      @required int color,
      @required EditEventBloc editBloc,
      @required EventBloc eventBloc,
      @required FavoriteAndRSVPBloc favoriteAndRSVPBloc,
      @required Function canEdit})
      : _event = event,
        _color = color,
        _editBloc = editBloc,
        _eventBloc = eventBloc,
        _favoriteAndRSVPBloc = favoriteAndRSVPBloc,
        _canEdit = canEdit;

  @override
  State<StatefulWidget> createState() {
    return _EventListTileBasicStyleState();
  }
}

class _EventListTileBasicStyleState extends State<EventListTileBasicStyle> {
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
        leading: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              child: Padding(
                padding: EdgeInsets.only(top: 17),
                child: Image.network(
                  'https://vignette.wikia.nocookie.net/line/images/b/bb/2015-brown.png/revision/latest?cb=20150808131630',
                  width: 50,
                ),
              ),
            ),
            !widget._event.rsvpd
                ? Container(width: 0, height: 0)
                : Positioned(
                    top: -2,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      color: Colors.red,
                      child: Text(
                        'RSVP\'d',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
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
                    widget._favoriteAndRSVPBloc.favoriteBloc.sink
                        .add(RemoveFavorite(eventToUnfavorite: widget._event));
                  else
                    widget._favoriteAndRSVPBloc.favoriteBloc.sink
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
                              rsvpBloc: widget._favoriteAndRSVPBloc.rsvpBloc,
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

class EventListTileCardStyle extends StatefulWidget {
  final Event _event;
  final EventBloc _eventBloc;
  final FavoriteAndRSVPBloc _favoriteAndRSVPBloc;
  final EditEventBloc _editBloc;
  final Function _canEdit;
  final Color _color;
  final int _titleMaxLength;

  EventListTileCardStyle(
      {@required Event event,
      @required EventBloc eventBloc,
      @required EditEventBloc editBloc,
      @required FavoriteAndRSVPBloc favoriteAndRSVPBloc,
      @required Function canEdit,
      @required Color color,
      int titleMaxLength = 35})
      : _color = color,
        _event = event,
        _eventBloc = eventBloc,
        _editBloc = editBloc,
        _favoriteAndRSVPBloc = favoriteAndRSVPBloc,
        _canEdit = canEdit,
        _titleMaxLength = titleMaxLength;

  @override
  State<StatefulWidget> createState() {
    return _EventListTileCardStyleState();
  }
}

class _EventListTileCardStyleState extends State<EventListTileCardStyle> {
  String _cutShort(String s, int length) {
    if (s.length <= length)
      return s;
    else
      return s.substring(0, length + 1) + "...";
  }

  @override
  Widget build(BuildContext context) {
    String title = widget._event == null
        ? 'No more events!'
        : _cutShort(widget._event.title, widget._titleMaxLength);
    List<Widget> rowWidgets = List<Widget>();
    if (widget._event != null) {
      rowWidgets.addAll([
        Stack(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.favorite,
                  color: widget._event.favorited ? Colors.red : Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: () {
                if (widget._event.favorited) {
                  widget._favoriteAndRSVPBloc.favoriteBloc.sink.add(
                    RemoveFavorite(eventToUnfavorite: widget._event),
                  );
                } else {
                  widget._favoriteAndRSVPBloc.favoriteBloc.sink
                      .add(AddFavorite(eventToFavorite: widget._event));
                }
                setState(() {});
              },
            ),
          ],
        ),
        Text(title),
        IconButton(
          icon: Icon(Icons.info),
          onPressed: () {
            widget._eventBloc.sink.add(AddViewToEvent(event: widget._event));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => EventDetailPage(
                      event: widget._event,
                      canEdit: widget._canEdit,
                      editBloc: widget._editBloc,
                      rsvpBloc: widget._favoriteAndRSVPBloc.rsvpBloc,
                    ),
              ),
            );
          },
        ),
      ]);
    } else {
      rowWidgets.add(Text(title));
    }
    return Stack(
      children: <Widget>[
        Card(
          child: Container(
            color: widget._color,
            height: 55,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rowWidgets,
            ),
          ),
        ),
        widget._event == null || !widget._event.rsvpd
            ? Container()
            : Container(
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(
                    Radius.circular(13),
                  ),
                ),
                child: Text(
                  'RSVP\'d',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
      ],
    );
  }
}
