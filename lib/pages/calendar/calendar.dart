import 'package:flutter/material.dart';

import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart' as Calendar;
import 'package:flutter_calendar_carousel/classes/event_list.dart';

import './calendar_widgets.dart';

import '../../common/daily_event_list_page.dart';

import '../../blocs/event_bloc.dart';
import '../../blocs/date_bloc.dart';
import '../../blocs/edit_bloc.dart';
import '../../blocs/favorite_rsvp_bloc.dart';

import '../../models/event.dart';

class CalendarPage extends StatefulWidget {
  final DateBloc _dateBloc;
  final EventBloc _eventBloc;
  final EditEventBloc _editBloc; 
  final FavoriteAndRSVPBloc _favoriteAndRSVPBloc;
  final Function _canEdit;
  final DateTime _selectedDay;

  CalendarPage(
      {@required EventBloc eventBloc,
      @required FavoriteAndRSVPBloc favoriteAndRSVPBloc,
      @required EditEventBloc editBloc,
      @required DateBloc dateBloc,
      @required DateTime selectedDay,
      @required Function canEdit})
      : _eventBloc = eventBloc,
        _editBloc = editBloc,
        _dateBloc = dateBloc,
        _favoriteAndRSVPBloc = favoriteAndRSVPBloc,
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
                      editBloc: widget._editBloc,
                      favoriteAndRSVPBloc: widget._favoriteAndRSVPBloc,
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
      body: Container(
        child: Column( 
          children: <Widget>[
            Container(
              height: 400,
              child: _buildCalendar(),
            ),
            Container(
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(text: '\n Legend: ', style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    TextSpan(text: '\n\n The date highlighted in'),
                    TextSpan(text: ' green', style: TextStyle(color: Colors.green)),
                    TextSpan(text: ' is today\'s date. \n\n'),
                    TextSpan(text: ' The date highlighted in'),
                    TextSpan(text: ' red', style: TextStyle(color: Colors.red)),
                    TextSpan(text: ' is the current daily view. \n\n'),
                    TextSpan(text: ' The highlighted numbers are the events per day.'),
                  ],
                ),
              ),
              alignment: AlignmentDirectional(-0.9, -0.9),
              margin: new EdgeInsets.only(
                left: 10.00,
                right: 10.00,
                bottom: 10.00,
              ),
              constraints: new BoxConstraints(
                maxHeight: 150,
              ),
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(
                  Radius.circular(10),
                  ),
                color: Colors.lightBlue.shade100,
              ),
            ),
          ],
        ),
      )
    );
  }
}
