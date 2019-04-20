import 'dart:async';
import 'package:flutter/material.dart';

import '../../blocs/rsvp_bloc.dart';
import '../../blocs/edit_bloc.dart';
import '../../blocs/favorite_rsvp_bloc.dart';
import '../../blocs/event_bloc.dart';

import '../../models/event.dart';
import '../../common/event_list_tile.dart';
import '../../common/loading_squirrel.dart';

class RSVPPage extends StatefulWidget {
  final EditEventBloc _editBloc;
  final FavoriteAndRSVPBloc _favoriteAndRSVPBloc;
  final EventBloc _eventBloc;
  final Function _canEdit;

  RSVPPage({
    @required FavoriteAndRSVPBloc favoriteAndRSVPBloc,
    @required EditEventBloc editBloc,
    @required EventBloc eventBloc,
    @required Function canEdit,
  })  : _favoriteAndRSVPBloc = favoriteAndRSVPBloc,
        _editBloc = editBloc,
        _eventBloc = eventBloc,
        _canEdit = canEdit;

  @override
  State<StatefulWidget> createState() {
    return _RSVPPageState();
  }
}

class _RSVPPageState extends State<RSVPPage> {
  List<Event> _rsvps;
  List<int> colors;
  int colorIdx;
  bool _isLoading;

  void _setupTempListenerForResetRSVPs() {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    StreamSubscription<RSVPState> tempListener;
    tempListener = widget._favoriteAndRSVPBloc.rsvpBloc.userRSVPRequests
        .listen((dynamic state) {
      if (state is UserRSVPsUpdated) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _rsvps = state.rsvps;
          });
        }
        tempListener.cancel();
      } else if (state is RSVPError) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        tempListener.cancel();
      }
    });
  }

  Widget _buildListTile(Event event) {
    return Dismissible(
      key: Key(DateTime.now().toString()),
      onDismissed: (DismissDirection direction) {
        widget._favoriteAndRSVPBloc.rsvpBloc.sink
            .add(RemoveRSVP(eventToUnRSVP: event));
        if (mounted) {
          setState(() {
            if (_rsvps != null)
              _rsvps.removeWhere((Event e) => e.eventId == event.eventId);
          });
        }
      },
      background: Container(
          color: Colors.red,
          padding: EdgeInsets.only(right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'Remove RSVP ',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.delete, color: Colors.white),
            ],
          )),
      child: EventListTileBasicAbbrevStyle(
        event: event,
        color: colors[colorIdx++ % colors.length],
        favoriteAndRSVPBloc: widget._favoriteAndRSVPBloc,
        eventBloc: widget._eventBloc,
        editBloc: widget._editBloc,
        canEditEvent: widget._canEdit,
        onFavorited: (_) {},
        onUnfavorited: (_) {},
      ),
    );
  }

  Container _accentTile(String text) {
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  Container _noRSVPsTile() {
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Text(
        'No RSVP\'d Events For Now! 🙂',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  void _showAreYouSureDialog(String message, Function onConfirm) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('RETURN'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text('CONTINUE'),
                onPressed: () {
                  onConfirm();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  List<Widget> _buildActionTiles() {
    List<Widget> list = List<Widget>();
    list.add(
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              child: Text('Remove All RSVPs'),
              color: Color(0xffffdde2),
              onPressed: () => _showAreYouSureDialog(
                    'Are you sure you want to remove ALL your RSVP\'d events?',
                    () {
                      widget._favoriteAndRSVPBloc.rsvpBloc.sink
                          .add(RemoveAllRSVPs());
                      _setupTempListenerForResetRSVPs();
                    },
                  ),
            ),
            FlatButton(
              child: Text('Remove Past RSVPs'),
              color: Color(0xffFFFFCC),
              onPressed: () => _showAreYouSureDialog(
                      'Are you sure you want to delete ALL RSVPs for PAST events?',
                      () {
                    widget._favoriteAndRSVPBloc.rsvpBloc.sink
                        .add(RemovePastRSVPs());
                    _setupTempListenerForResetRSVPs();
                  }),
            ),
          ],
        ),
      ),
    );
    return list;
  }

  Widget _buildBody() {
    if (_isLoading) return LoadingSquirrel();
    List<Widget> children = List<Widget>();
    children.addAll(_buildActionTiles());
    if (_rsvps != null) {
      for (Event event in _rsvps) {
        children.add(_buildListTile(event));
      }
    }

    if (children.length == 1) {
      children.add(_noRSVPsTile());
    }

    return ListView(
      children: children,
    );
  }

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    colors = [
      0xffffdde2,
      0xffFFFFCC,
      0xffdcf9ec,
      0xffFFFFFF,
      0xffF0F0F0,
    ];
    colorIdx = 0;
    RSVPState initialState =
        widget._favoriteAndRSVPBloc.rsvpBloc.userRSVPInitialState;
    if (initialState is UserRSVPsUpdated) {
      _rsvps = initialState.rsvps;
    }
  }

  void _deleteAllUnRSVPdEvents() {
    if (_rsvps != null) _rsvps.removeWhere((Event e) => e.rsvpd == false);
  }

  @override
  Widget build(BuildContext context) {
    _deleteAllUnRSVPdEvents();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.lightBlue[50],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'RSVP',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                widget._favoriteAndRSVPBloc.rsvpBloc.sink.add(FetchUserRSVPs());
                _setupTempListenerForResetRSVPs();
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }
}
