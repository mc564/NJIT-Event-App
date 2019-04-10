import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/favorite_bloc.dart';
import '../../blocs/edit_bloc.dart';
import '../../models/event.dart';
import '../detail/event_detail.dart';
import '../../common/error_dialog.dart';

class ViewDropDown extends StatelessWidget {
  final DateFormat dayFormatter = DateFormat('EEE, MMM d, y');
  final DateFormat weekDayFormatter = DateFormat('EEE, MMM d');
  final DateFormat monthFormatter = DateFormat('MMMM y');
  final Function _onChanged;
  final DateTime _day;
  final DateTime _weekStart;
  final DateTime _weekEnd;

  ViewDropDown(
      {Function onChanged, DateTime day, DateTime weekStart, DateTime weekEnd})
      : _onChanged = onChanged,
        _day = day,
        _weekStart = weekStart,
        _weekEnd = weekEnd;

  Container _buildColoredTag(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 14)),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropDownButton(
        'Click me to change the view!',
        [
          DropdownMenuItem(
            value: 'dailyView',
            child: Row(
              children: <Widget>[
                _buildColoredTag('Day', Color(0xffFFB2FF)),
                Text(
                  dayFormatter.format(_day),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'weeklyView',
            child: Row(
              children: <Widget>[
                _buildColoredTag('Week', Colors.yellow),
                Text(
                  weekDayFormatter.format(_weekStart) +
                      " - " +
                      weekDayFormatter.format(_weekEnd),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'monthlyView',
            child: Row(
              children: <Widget>[
                _buildColoredTag('Month', Colors.cyan),
                Text(
                  monthFormatter.format(_day),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
        (String value) {
          _onChanged(value);
        },
      ),
    );
  }
}

class DropDownButton extends StatefulWidget {
  final String _hint;
  final List<DropdownMenuItem> _items;
  final Function _callback;

  DropDownButton(this._hint, this._items, this._callback);

  @override
  State<StatefulWidget> createState() {
    return _DropDownButtonState();
  }
}

class _DropDownButtonState extends State<DropDownButton> {
  String _value;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      isExpanded: true,
      hint: Text(widget._hint, style: TextStyle(fontSize: 14)),
      items: widget._items,
      onChanged: (value) {
        setState(() {
          print(value);
          _value = value;
          widget._callback(_value);
        });
      },
      value: _value,
    );
  }
}

class WeeklyEventListTile extends StatefulWidget {
  final Event _event;
  final EventBloc _eventBloc;
  final FavoriteBloc _favoriteBloc;
  final EditEventBloc _editBloc;
  final Function _canEdit;
  final Color _color;

  WeeklyEventListTile(
      {@required Event event,
      @required EventBloc eventBloc,
      @required FavoriteBloc favoriteBloc,
      @required EditEventBloc editBloc,
      @required Function canEdit,
      @required Color color})
      : _color = color,
        _event = event,
        _eventBloc = eventBloc,
        _favoriteBloc = favoriteBloc,
        _editBloc = editBloc,
        _canEdit = canEdit;

  @override
  State<StatefulWidget> createState() {
    return _WeeklyEventListTileState();
  }
}

class _WeeklyEventListTileState extends State<WeeklyEventListTile> {
  String _cutShort(String s, int length) {
    if (s.length <= length)
      return s;
    else
      return s.substring(0, length + 1) + "...";
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String title = widget._event == null
        ? 'No more events!'
        : _cutShort(widget._event.title, 35);
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
                  widget._favoriteBloc.sink.add(
                    RemoveFavorite(eventToUnfavorite: widget._event),
                  );
                } else {
                  widget._favoriteBloc.sink
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
                    ),
              ),
            );
          },
        ),
      ]);
    } else {
      rowWidgets.add(Text(title));
    }
    return Card(
      child: Container(
        color: widget._color,
        height: 55,
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: rowWidgets,
        ),
      ),
    );
  }
}

class WeeklyEventList extends StatefulWidget {
  final DateTime _dayStart;
  final DateTime _dayEnd;
  final EventBloc _eventBloc;
  final FavoriteBloc _favoriteBloc;
  final EditEventBloc _editBloc;
  final Function _canEdit;

  WeeklyEventList(
      {@required EventBloc eventBloc,
      @required FavoriteBloc favoriteBloc,
      @required EditEventBloc editBloc,
      @required Function canEdit,
      @required DateTime dayStart,
      @required DateTime dayEnd,
      Key key})
      : _dayStart = dayStart,
        _dayEnd = dayEnd,
        _eventBloc = eventBloc,
        _favoriteBloc = favoriteBloc,
        _editBloc = editBloc,
        _canEdit = canEdit,
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WeeklyEventListState();
  }
}

class _WeeklyEventListState extends State<WeeklyEventList> {
  StreamSubscription _favoriteErrorSubscription;
  DateFormat dayFormatter = DateFormat.MMMd("en_US");
  int colorIdx;
  List<int> colors;

  @override
  void initState() {
    super.initState();
    _favoriteErrorSubscription =
        widget._favoriteBloc.favoriteSettingErrors.listen((dynamic state) {
      //recieve any favorite setting errors? rollback favorite status by setting state

      setState(() {});
    });
    widget._eventBloc.sink.add(
        FetchWeeklyEvents(dayStart: widget._dayStart, dayEnd: widget._dayEnd));
    colorIdx = 0;
    colors = [
      0xffffdde2,
      0xffFFFFCC,
      0xffdcf9ec,
      0xffFFFFFF,
      0xffF0F0F0,
    ];
  }

  Widget _buildEventListTile(Event event) {
    colorIdx++;
    Color color = Color(colors[colorIdx % colors.length]);
    return WeeklyEventListTile(
        favoriteBloc: widget._favoriteBloc,
        eventBloc: widget._eventBloc,
        editBloc: widget._editBloc,
        canEdit: widget._canEdit,
        event: event,
        color: color);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EventListState>(
      initialData: widget._eventBloc.weeklyEventsInitialState,
      stream: widget._eventBloc.weeklyEvents,
      builder: (BuildContext context, AsyncSnapshot<EventListState> snapshot) {
        EventListState state = snapshot.data;
        Map<DateTime, List<Event>> weeklyEvents = Map<DateTime, List<Event>>();
        List<Widget> children = List<Widget>();
        if (state is EventListLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is WeeklyEventListLoaded) {
          weeklyEvents = state.events;
        } else if (state is EventListError) {
          return Center(child: Text('There\'s been an error! OH NO! ): Please try again!'));
        }
        //use an array to map DateTime to the day of the week?
        Map<String, DateTime> day = Map<String, DateTime>();
        List<String> weekDays = [
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday'
        ];
        for (DateTime key in weeklyEvents.keys) {
          String weekDay = weekDays[key.weekday % 7];
          day[weekDay] = key;
        }
        for (String weekDay in weekDays) {
          if (!day.containsKey(weekDay)) {
            //not sure how I would proceed here...?
            //this would mean something is wrong in the date bloc..
            continue;
          }
          DateTime dateForWeekDay = day[weekDay];
          children.add(
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                weekDay + ', ' + dayFormatter.format(dateForWeekDay),
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.left,
              ),
            ),
          );
          if (weeklyEvents.containsKey(dateForWeekDay)) {
            List<Event> eventsOnDay = weeklyEvents[dateForWeekDay];
            Event one = eventsOnDay.length >= 1 ? eventsOnDay[0] : null;
            Event two = eventsOnDay.length >= 2 ? eventsOnDay[1] : null;
            Event three = eventsOnDay.length >= 3 ? eventsOnDay[2] : null;
            children.add(_buildEventListTile(one));
            children.add(_buildEventListTile(two));
            children.add(_buildEventListTile(three));
          } else {
            children.add(
              Text('No events on ' + weekDay + '.', textAlign: TextAlign.left),
            );
          }
        }
        return SingleChildScrollView(
          child: Container(
            height: 1700,
            margin: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _favoriteErrorSubscription.cancel();
  }
}
