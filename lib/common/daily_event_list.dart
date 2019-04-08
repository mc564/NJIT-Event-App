import 'package:flutter/material.dart';
import './event_list_tile.dart';
import '../models/event.dart';
import '../blocs/event_bloc.dart';
import '../blocs/favorite_bloc.dart';
import '../blocs/edit_bloc.dart';
import 'dart:async';

class DailyEventList extends StatefulWidget {
  final EditEventBloc _editBloc;
  final FavoriteBloc _favoriteBloc;
  final EventBloc _eventBloc;
  final Function _canEdit;
  final DateTime _day;

  DateTime get day => _day;

  DailyEventList(
      {@required DateTime day,
      @required EventBloc eventBloc,
      @required EditEventBloc editBloc,
      @required FavoriteBloc favoriteBloc,
      @required Function canEdit,
      Key key})
      : assert(day != null && eventBloc != null),
        _day = day,
        _eventBloc = eventBloc,
        _editBloc = editBloc,
        _favoriteBloc = favoriteBloc,
        _canEdit = canEdit,
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
            event: events[index],
            color: colors[index % colors.length],
            favoriteBloc: widget._favoriteBloc,
            editBloc: widget._editBloc,
            eventBloc: widget._eventBloc,
            canEdit: widget._canEdit);
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

  Future<void> _refresh() async {
    widget._eventBloc.refetchDailyEvents(widget._day);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EventListState>(
      stream: widget._eventBloc.dailyEvents,
      initialData: widget._eventBloc.dailyEventsInitialState,
      builder: (BuildContext context, AsyncSnapshot<EventListState> snapshot) {
        EventListState state = snapshot.data;
        Widget child;

        print("eventbloc state is: " + state.runtimeType.toString());
        if (state is EventListError) {
          child = Text('There was an error! 😱, please try again!');
        } else if (state is EventListLoading) {
          child = CircularProgressIndicator();
        } else if (state is DailyEventListLoaded) {
          DailyEventListLoaded eventListObject = state;
          child = _buildPage(eventListObject.events);
        } else {
          child = Text(
              'There was an error with the streams, most probably! Please refresh...💩');
        }

        return Center(
          child: RefreshIndicator(
            child: child,
            onRefresh: () => _refresh(),
          ),
        );
      },
    );
  }

  dispose() {
    _favoriteErrorSubscription.cancel();
    super.dispose();
  }
}
