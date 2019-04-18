import 'package:flutter/material.dart';

import '../../blocs/rsvp_bloc.dart';
import '../../blocs/edit_bloc.dart';
import '../../blocs/favorite_rsvp_bloc.dart';
import '../../blocs/event_bloc.dart';

import '../../models/event.dart';
import '../../common/event_list_tile.dart';

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

  Widget _buildListTile(Event event) {
    return Dismissible(
      key: Key(DateTime.now().toString()),
      onDismissed: (DismissDirection direction) {
        widget._favoriteAndRSVPBloc.rsvpBloc.sink
            .add(RemoveRSVP(eventToUnRSVP: event));
        setState(() {
          _rsvps.removeWhere((Event e) => e.eventId == event.eventId);
        });
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

  Widget _buildBody() {
    List<Widget> children = List<Widget>();

    if (_rsvps != null) {
      if (_rsvps.length > 0) {
        children.add(_accentTile('These are all your RSVP\'d events! 🙂'));
      }

      for (Event event in _rsvps) {
        children.add(_buildListTile(event));
      }
    }

    if (children.length == 0) {
      children.add(_accentTile('No RSVPs For Now! 🙂'));
    }

    return ListView(
      children: children,
    );
  }

  @override
  void initState() {
    super.initState();
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
    _rsvps.removeWhere((Event e) => e.rsvpd == false);
  }

  @override
  Widget build(BuildContext context) {
    _deleteAllUnRSVPdEvents();
    return Scaffold(
      appBar: AppBar(
        title: Text('RSVP'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }
}
