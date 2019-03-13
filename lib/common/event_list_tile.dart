import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/category.dart';
import 'package:intl/intl.dart';
import '../pages/detail/event_detail.dart';
import '../blocs/favorite_bloc.dart';

class EventListTile extends StatelessWidget {
  final Event _event;
  final int _color;
  final FavoriteBloc _favoriteBloc;

  EventListTile(this._event, this._color, this._favoriteBloc);

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
      return s.substring(0, length+1) + "...";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125,
      decoration: BoxDecoration(color: Color(_color)),
      child: ListTile(
        contentPadding: EdgeInsets.only(left:14, right:8, bottom:5),
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
            Text(cutShort(_event.title, 45), style: TextStyle(fontSize: 18)),
            Text(cutShort(_event.location, 35), style: TextStyle(fontSize: 15)),
            Text(formatEventDuration(_event.startTime, _event.endTime),
                style: TextStyle(fontSize: 14)),
            Text(CategoryHelper.getString(_event.category),
                style: TextStyle(fontSize: 14)),
          ],
        ),
        trailing: Container(
          width: 50,
          child: Column(
            children: <Widget>[
              StreamBuilder<FavoriteState>(
                  stream: _favoriteBloc.favorites,
                  initialData: _favoriteBloc.initialState,
                  builder: (BuildContext context,
                      AsyncSnapshot<FavoriteState> snapshot) {
                    FavoriteState state = snapshot.data;
                    if (state is FavoriteError) {
                      return Text('error error');
                    } else if (state is FavoriteUpdated) {
                      bool favorited = state.favorited;
                      return IconButton(
                        padding: EdgeInsets.only(left:8, right:8, bottom:8),
                        icon: Icon(
                          favorited ? Icons.favorite : Icons.favorite_border,
                          color: Colors.pink,
                        ),
                        onPressed: () {
                          _favoriteBloc.addFavorite('eventid', '');
                        },
                      );
                    } else if (state is FavoriteInitial) {
                      return IconButton(
                        padding: EdgeInsets.only(left:8, right:8, bottom:8),
                        icon: Icon(
                          Icons.favorite_border,
                          color: Colors.pink,
                        ),
                        onPressed: () {
                          _favoriteBloc.addFavorite('eventid', '');
                        },
                      );
                    } else {
                      return Text('how did this happen? its impossible');
                    }
                  }),
              IconButton(
                icon: Icon(
                  Icons.info,
                  color: Colors.lightBlue[200],
                ),
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          maintainState: false,
                          builder: (BuildContext context) =>
                              EventDetailPage(_event)),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
