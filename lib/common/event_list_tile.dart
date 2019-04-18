import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../models/category.dart';

import '../pages/detail/event_detail.dart';

import '../blocs/event_bloc.dart';
import '../blocs/edit_bloc.dart';
import '../blocs/favorite_bloc.dart';
import '../blocs/favorite_rsvp_bloc.dart';

import '../presentation/my_flutter_app_icons.dart';

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
  IconData getIcon(String category) {
    switch (category) {
      case "Arts & Entertainment":
        return MyFlutterApp.pencil_case;
      case "Health & Wellness":
        return MyFlutterApp.heart;
      case "Sports":
        return MyFlutterApp.runer_silhouette_running_fast;
      case "Meet & Learn":
        return MyFlutterApp.meeting;
      case "Alumni & University":
        return MyFlutterApp.students_cap;
      case "Celebrations":
        return MyFlutterApp.confetti;
      case "Miscellaneous":
        return MyFlutterApp.push_pin;
      case "Community":
        return MyFlutterApp.exchange;
      case "Conferences":
        return MyFlutterApp.computer;
      case "Market Place & Tabling":
        return MyFlutterApp.exchange;
      default:
        return MyFlutterApp.push_pin;
    }
  }

  Color getColor(String category) {
    switch (category) {
      case "Arts & Entertainment":
        return Color(0xffffa500);
      case "Health & Wellness":
        return Color(0xff0200ff);
      case "Sports":
        return Color(0xffff0700);
      case "Meet & Learn":
        return Color(0xff02d100);
      case "Alumni & University":
        return Color(0xffffa500);
      case "Celebrations":
        return Color(0xffffa500);
      case "Miscellaneous":
        return Color(0xff0200ff);
      case "Community":
        return Color(0xffff0700);
      case "Conferences":
        return Color(0xff02d100);
      case "Market Place & Tabling":
        return Color(0xffffa500);
      default:
        return Color(0xffffa500);
    }
  }

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
                padding: EdgeInsets.only(top: 19),
                child: Container(
                  margin: EdgeInsets.all(3),
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Icon(
                    getIcon(CategoryHelper.getString(widget._event.category)),
                    color: getColor(
                        CategoryHelper.getString(widget._event.category)),
                    size: 40,
                  ),
                ),
              ),
            ),
            !widget._event.rsvpd
                ? Container(width: 0, height: 0)
                : Positioned(
                    top: -4,
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

//will show a lower opacity tile if the event has passed
class EventListTileBasicAbbrevStyle extends StatefulWidget {
  final EditEventBloc _editBloc;
  final FavoriteAndRSVPBloc _favoriteAndRSVPBloc;
  final EventBloc _eventBloc;
  final Function _canEditEvent;
  final Event _event;
  final int _color;
  final int _titleMaxLength;
  final Function(Event) _onFavorited;
  final Function(Event) _onUnfavorited;

  EventListTileBasicAbbrevStyle({
    @required EditEventBloc editBloc,
    @required FavoriteAndRSVPBloc favoriteAndRSVPBloc,
    @required EventBloc eventBloc,
    @required Function canEditEvent,
    @required Event event,
    @required int color,
    int titleMaxLength = 35,
    @required Function(Event) onFavorited,
    @required Function(Event) onUnfavorited,
  })  : _editBloc = editBloc,
        _favoriteAndRSVPBloc = favoriteAndRSVPBloc,
        _eventBloc = eventBloc,
        _canEditEvent = canEditEvent,
        _event = event,
        _color = color,
        _titleMaxLength = titleMaxLength,
        _onFavorited = onFavorited,
        _onUnfavorited = onUnfavorited;

  @override
  State<StatefulWidget> createState() {
    return _EventListTileBasicAbbrevStyleState();
  }
}

class _EventListTileBasicAbbrevStyleState
    extends State<EventListTileBasicAbbrevStyle> {
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
                      widget._favoriteAndRSVPBloc.favoriteBloc.sink
                          .add(RemoveFavorite(eventToUnfavorite: toRemove));
                      widget._onUnfavorited(toRemove);
                      setState(() {});
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
    DateTime start = widget._event.startTime;
    if (start.year == start.year &&
        start.month == now.month &&
        start.day == now.day)
      return true;
    else
      return false;
  }

  Widget _buildLeadingImage() {
    return Container(
      margin: EdgeInsets.only(left: 15),
      child: Image.network(
        'https://vignette.wikia.nocookie.net/line/images/b/bb/2015-brown.png/revision/latest?cb=20150808131630',
        width: 50,
      ),
    );
  }

  Widget _buildTileMainContent() {
    return Column(
      children: <Widget>[
        Text(_cutShort(widget._event.title, widget._titleMaxLength),
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
        Text(
          _formatEventDuration(widget._event.startTime, widget._event.endTime),
          style: TextStyle(fontSize: 15.0),
        ),
      ],
    );
  }

  Widget _buildFaveAndInfoButton(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
            icon: Icon(
              widget._event.favorited ? Icons.favorite : Icons.favorite_border,
              color: Colors.pink,
            ),
            onPressed: () {
              if (widget._event.favorited)
                _showAreYouSureDialog(context, widget._event);
              else {
                widget._favoriteAndRSVPBloc.favoriteBloc.sink
                    .add(AddFavorite(eventToFavorite: widget._event));
                widget._onFavorited(widget._event);
                setState(() {});
              }
            }),
        IconButton(
          icon: Icon(
            Icons.info,
            color: Colors.lightBlue[200],
          ),
          onPressed: () {
            widget._eventBloc.sink.add(AddViewToEvent(event: widget._event));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => EventDetailPage(
                      event: widget._event,
                      canEdit: widget._canEditEvent,
                      editBloc: widget._editBloc,
                      rsvpBloc: widget._favoriteAndRSVPBloc.rsvpBloc,
                    ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRSVPTag() {
    return Container(
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
    );
  }

  Widget _buildHappeningTodayTag() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.all(
          Radius.circular(13),
        ),
      ),
      child: Text(
        'TODAY!!  🎉',
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLowerOpacityPastEventTile() {
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Opacity(
          opacity: 0.5,
          child: _buildBasicTile(),
        ),
        Positioned(
          left: 30,
          bottom: 30,
          child: Transform(
            transform: new Matrix4.rotationZ(0.174533),
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.red,
              child: Text(
                'EVENT PASSED',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicTile() {
    return Container(
      color: Color(widget._color),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Positioned(
            top: 7,
            child: Row(
              children: <Widget>[
                _happeningToday() ? _buildHappeningTodayTag() : Container(),
                widget._event.rsvpd ? _buildRSVPTag() : Container(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildLeadingImage(),
              _buildTileMainContent(),
              _buildFaveAndInfoButton(context),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget._event.endTime.isBefore(DateTime.now())
        ? _buildLowerOpacityPastEventTile()
        : _buildBasicTile();
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
