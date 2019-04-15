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
  List<int> colors;
  int colorIdx;

  Widget _buildListTile(Event event) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.remove_circle),
          onPressed: () {
            widget._favoriteAndRSVPBloc.rsvpBloc.sink
                .add(RemoveRSVP(eventToUnRSVP: event));
          },
        ),
        Expanded(
          child: EventListTileCardStyle(
            event: event,
            color: Color(colors[colorIdx++ % colors.length]),
            favoriteAndRSVPBloc: widget._favoriteAndRSVPBloc,
            eventBloc: widget._eventBloc,
            editBloc: widget._editBloc,
            canEdit: widget._canEdit,
            titleMaxLength: 30,
          ),
        ),
      ],
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
    return StreamBuilder<RSVPState>(
      initialData: widget._favoriteAndRSVPBloc.rsvpBloc.userRSVPInitialState,
      stream: widget._favoriteAndRSVPBloc.rsvpBloc.userRSVPRequests,
      builder: (BuildContext context, AsyncSnapshot<RSVPState> snapshot) {
        List<Widget> children = List<Widget>();
        RSVPState state = snapshot.data;
        if (state is UserRSVPsUpdated) {
          List<Event> rsvps = state.rsvps;

          if (rsvps != null) {
            if (rsvps.length > 0) {
              children
                  .add(_accentTile('These are all your RSVP\'d events! 🙂'));
            }

            for (Event event in rsvps) {
              children.add(_buildListTile(event));
            }
          }
        }
        if (children.length == 0) {
          children.add(_accentTile('No RSVPs For Now! 🙂'));
        }

        return ListView(
          children: children,
        );
      },
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RSVP'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }
}
