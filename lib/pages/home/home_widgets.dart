import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/favorite_rsvp_bloc.dart';
import '../../blocs/edit_bloc.dart';
import '../../models/event.dart';
import '../../common/daily_event_list_page.dart';
import '../../common/event_list_tile.dart';

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

class WeeklyEventList extends StatefulWidget {
  final DateTime _dayStart;
  final DateTime _dayEnd;
  final EventBloc _eventBloc;
  final FavoriteAndRSVPBloc _favoriteAndRSVPBloc;
  final EditEventBloc _editBloc;
  final Function _canEdit;

  WeeklyEventList(
      {@required EventBloc eventBloc,
      @required FavoriteAndRSVPBloc favoriteAndRSVPBloc,
      @required EditEventBloc editBloc,
      @required Function canEdit,
      @required DateTime dayStart,
      @required DateTime dayEnd,
      Key key})
      : _dayStart = dayStart,
        _dayEnd = dayEnd,
        _eventBloc = eventBloc,
        _favoriteAndRSVPBloc = favoriteAndRSVPBloc,
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
  int tileColorIdx;
  List<Color> tileColors;
  int accentColorIdx;
  List<Color> accentColors;

  @override
  void initState() {
    super.initState();
    _favoriteErrorSubscription =
        widget._favoriteAndRSVPBloc.favoriteBloc.favoriteSettingErrors.listen((dynamic state) {
      //recieve any favorite setting errors? rollback favorite status by setting state

      setState(() {});
    });
    widget._eventBloc.sink.add(
        FetchWeeklyEvents(dayStart: widget._dayStart, dayEnd: widget._dayEnd));
    tileColorIdx = 0;
    tileColors = [
      Color(0xffffdde2),
      Color(0xffFFFFCC),
      Color(0xffdcf9ec),
      Color(0xffFFFFFF),
      Color(0xffF0F0F0),
    ];
    accentColorIdx = 0;
    accentColors = [
      Colors.cyan,
      Color(0xffff5349),
      Color(0xff02d100),
      Color(0xffffa500),
    ];
  }

  Widget _buildEventListTile(Event event) {
    tileColorIdx++;
    Color color = tileColors[tileColorIdx % tileColors.length];
    return EventListTileCardStyle(
        favoriteAndRSVPBloc: widget._favoriteAndRSVPBloc,
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
          return Center(
              child:
                  Text('There\'s been an error! OH NO! ): Please try again!'));
        }
        //use an array to map DateTime to the day of the week
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
        for (int weekDay = 0; weekDay < 7; weekDay++) {
          int hoursToAdd = (weekDay * 24) + 2;
          DateTime dayData = widget._dayStart.add(Duration(hours: hoursToAdd));
          dayData = DateTime(dayData.year, dayData.month, dayData.day);
          day[weekDays[weekDay]] = dayData;
        }

        for (String weekDay in weekDays) {
          DateTime dateForWeekDay = day[weekDay];
          int eventCount = weeklyEvents.containsKey(dateForWeekDay)
              ? weeklyEvents[dateForWeekDay].length
              : 0;
          children.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        weekDay + ', ' + dayFormatter.format(dateForWeekDay),
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: 30,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(right: 10),
                      child: Text(eventCount.toString()),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                    ),
                    Text(eventCount == 1 ? 'Event' : 'Events'),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: accentColors[accentColorIdx % accentColors.length],
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => DailyEventListPage(
                              editBloc: widget._editBloc,
                              favoriteAndRSVPBloc: widget._favoriteAndRSVPBloc,
                              eventBloc: widget._eventBloc,
                              day: dateForWeekDay,
                              canEdit: widget._canEdit,
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
          List<Event> eventsOnDay = List<Event>();
          Event one;
          Event two;
          Event three;
          if (weeklyEvents.containsKey(dateForWeekDay)) {
            eventsOnDay = weeklyEvents[dateForWeekDay];
            one = eventsOnDay.length >= 1 ? eventsOnDay[0] : null;
            two = eventsOnDay.length >= 2 ? eventsOnDay[1] : null;
            three = eventsOnDay.length >= 3 ? eventsOnDay[2] : null;
          }
          children.add(_buildEventListTile(one));
          children.add(_buildEventListTile(two));
          children.add(_buildEventListTile(three));
          accentColorIdx++;
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
