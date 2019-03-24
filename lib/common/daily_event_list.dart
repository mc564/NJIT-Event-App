import 'package:flutter/material.dart';
import './event_list_tile.dart';
import '../models/event.dart';
import '../blocs/event_bloc.dart';
import '../blocs/favorite_bloc.dart';
import 'dart:async';

class DailyEventList extends StatefulWidget {
  final FavoriteBloc _favoriteBloc;
  final EventBloc _eventBloc;
  final DateTime _day;

  DateTime get day => _day;

  DailyEventList(
      {@required DateTime day,
      @required EventBloc eventBloc,
      @required FavoriteBloc favoriteBloc,
      Key key})
      : assert(day != null && eventBloc != null),
        _day = day,
        _eventBloc = eventBloc,
        _favoriteBloc = favoriteBloc,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DailyEventListState();
  }
}

class _DailyEventListState extends State<DailyEventList> {
  StreamSubscription _favoriteErrorSubscription;

  Widget _buildPage(List<Event> events) {
    List<int> colors = [
      0xffffdde2,
      0xffFFFFCC,
      0xffdcf9ec,
      0xffFFFFFF,
      0xffF0F0F0,
    ];

    if (events.length == 0)
      return Center(
          child: Text('No events matching the criteria on this day!'));

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        return EventListTile(
            events[index], colors[index % colors.length], widget._favoriteBloc, widget._eventBloc);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    widget._eventBloc.fetchDailyEvents(widget._day);
    _favoriteErrorSubscription =
        widget._favoriteBloc.favoriteSettingErrors.listen((dynamic state) {
      //recieve any favorite setting errors? rollback favorite status by setting state
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EventListState>(
      stream: widget._eventBloc.dailyEvents,
      initialData: widget._eventBloc.dailyEventsInitialState,
      builder: (BuildContext context, AsyncSnapshot<EventListState> snapshot) {
        EventListState state = snapshot.data;
        print("eventbloc state is: " + state.runtimeType.toString());
        if (state is EventListError) {
          return Center(
            child: Text('There was an error! 😱, please try again!'),
          );
        } else if (state is EventListLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is DailyEventListLoaded) {
          DailyEventListLoaded eventListObject = state;
          //TODO test whether creating these pages in advance would be faster....?
          return _buildPage(eventListObject.events);
        } else {
          return Center(
              child: Text(
                  'There was an error with the streams, most probably! Please refresh...💩'));
        }
      },
    );
  }

  dispose(){
    _favoriteErrorSubscription.cancel();
    super.dispose();
  }
}
