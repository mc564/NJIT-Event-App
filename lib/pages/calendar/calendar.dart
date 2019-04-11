import 'package:flutter/material.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart' as Calendar;
import 'package:flutter_calendar_carousel/classes/event_list.dart';

import './calendar_widgets.dart';

import '../../common/daily_event_list_page.dart';

import '../../blocs/event_bloc.dart';
import '../../blocs/favorite_bloc.dart';
import '../../blocs/date_bloc.dart';
import '../../blocs/edit_bloc.dart';

import '../../models/event.dart';

class CalendarPage extends StatefulWidget {
  final DateBloc _dateBloc;
  final EventBloc _eventBloc;
  final FavoriteBloc _favoriteBloc;
  final EditEventBloc _editBloc;
  final Function _canEdit;
  final DateTime _selectedDay;

  CalendarPage(
      {@required EventBloc eventBloc,
      @required FavoriteBloc favoriteBloc,
      @required EditEventBloc editBloc,
      @required DateBloc dateBloc,
      @required DateTime selectedDay,
      @required Function canEdit})
      : _eventBloc = eventBloc,
        _editBloc = editBloc,
        _favoriteBloc = favoriteBloc,
        _dateBloc = dateBloc,
        _selectedDay = selectedDay,
        _canEdit = canEdit;

  @override
  State<StatefulWidget> createState() {
    return _CalendarPageState();
  }
}

class _CalendarPageState extends State<CalendarPage> {
  EventList<Calendar.Event> allMarkedDates;
  DateTime _prevSeenTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget._eventBloc.sink.add(FetchCachedEvents()));
    allMarkedDates = EventList<Calendar.Event>();
  }

  Widget _buildCalendar() {
    return StreamBuilder<EventListState>(
      initialData: widget._eventBloc.cachedEventsInitialState,
      stream: widget._eventBloc.cachedEvents,
      builder: (BuildContext context, AsyncSnapshot<EventListState> snapshot) {
        EventListState state = snapshot.data;
        if (state is CachedEventsLoaded) {
          Map<DateTime, List<Event>> dateMappedEvents = state.cachedEvents;
          allMarkedDates.clear();
          for (DateTime day in dateMappedEvents.keys) {
            List<Event> eventsOnDay = dateMappedEvents[day];
            for (Event event in eventsOnDay) {
              allMarkedDates.add(
                day,
                Calendar.Event(
                  date: day,
                  title: event.title,
                  icon: eventMarkIcon,
                ),
              );
            }
          }
        } else if (state is EventListError) {
          return Center(child: Text('Whoops, there\'s been an error!!'));
        }
        return CalendarCarousel<Calendar.Event>(
          selectedDateTime: widget._selectedDay,
          markedDateIconMaxShown: 2,
          markedDateIconBuilder: (event) {
            return event.icon;
          },
          markedDateShowIcon: true,
          markedDatesMap: allMarkedDates,
          markedDateMoreShowTotal: false,
          onCalendarChanged: (DateTime currTime) {
            print('calendar changed: ' + currTime.toString());
            if (_prevSeenTime != null && _prevSeenTime != currTime) {
              if (_prevSeenTime.isAfter(currTime)) {
                widget._dateBloc.sink.add(ToPrevMonth());
              } else {
                widget._dateBloc.sink.add(ToNextMonth());
              }
            }
            _prevSeenTime = currTime;
          },
          onDayPressed: (DateTime dayPressed, List<dynamic> list) {
            //TODO change so that event counts on the calendar have the day instead of the calendar icon
            print('day pressed');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return DailyEventListPage(
                      day: dayPressed,
                      eventBloc: widget._eventBloc,
                      favoriteBloc: widget._favoriteBloc,
                      editBloc: widget._editBloc,
                      canEdit: widget._canEdit,
                      key: PageStorageKey<String>(DateTime.now().toString()));
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildCalendar(),
    );
  }
}
