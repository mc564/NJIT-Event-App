import 'dart:async';

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../providers/event_list_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/metrics_provider.dart';

import '../models/event.dart';
import '../models/organization.dart';

//bloc for fetching event lists, also keeps track of event view counts and possibly other metrics
class EventBloc {
  final StreamController<EventListState> _dailyController;
  final StreamController<EventListState> _weeklyController;
  final StreamController<EventListState> _recentEventsController;

  final EventListProvider _eventListProvider;
  final FavoriteProvider _favoriteProvider;
  final MetricsProvider _metricsProvider;

  EventBloc({@required FavoriteProvider favoriteProvider})
      : _favoriteProvider = favoriteProvider,
        _eventListProvider =
            EventListProvider(favoriteProvider: favoriteProvider),
        _metricsProvider = MetricsProvider(),
        _dailyController = StreamController.broadcast(),
        _weeklyController = StreamController.broadcast(),
        _recentEventsController = StreamController.broadcast();

  EventListLoading get dailyEventsInitialState => EventListLoading();
  EventListLoading get weeklyEventsInitialState => EventListLoading();
  EventListLoading get recentEventsInitialState => EventListLoading();

  Stream get dailyEvents => _dailyController.stream;
  Stream get weeklyEvents => _weeklyController.stream;
  Stream get recentEvents => _recentEventsController.stream;

  EventListProvider get eventListProvider => _eventListProvider;

  int get currentFilterCount =>
      _eventListProvider.selectedCategories.length +
      _eventListProvider.selectedLocations.length +
      _eventListProvider.selectedOrganizations.length;

  void _markFavoritedEvents(List<Event> events) {
    events = events.map((Event event) {
      if (_favoriteProvider.favorited(event)) {
        event.favorited = true;
      } else {
        event.favorited = false;
      }
    }).toList();
  }

  void fetchDailyEvents(DateTime day) async {
    try {
      _dailyController.sink.add(EventListLoading());
      List<Event> dailyEvents = await _eventListProvider.getEventsOnDay(day);
      _markFavoritedEvents(dailyEvents);
      _dailyController.sink.add(DailyEventListLoaded(events: dailyEvents));
    } catch (error) {
      _dailyController.sink.add(EventListError(
          error:
              "Error in fetchDailyEvents of eventBloc: " + error.toString()));
    }
  }

  //actually reloads instead of getting old records from cache
  void refetchDailyEvents(DateTime day) async {
    try {
      _dailyController.sink.add(EventListLoading());
      List<Event> dailyEvents =
          await _eventListProvider.refetchEventsOnDay(day);
      _markFavoritedEvents(dailyEvents);
      _dailyController.sink.add(DailyEventListLoaded(events: dailyEvents));
    } catch (error) {
      _dailyController.sink.add(EventListError(
          error:
              "Error in refetchDailyEvents of eventBloc: " + error.toString()));
    }
  }

  void fetchWeeklyEvents(DateTime weekStart, DateTime weekEnd) async {
    try {
      _weeklyController.sink.add(EventListLoading());
      List<Event> weeklyEvents =
          await _eventListProvider.getEventsBetween(weekStart, weekEnd);
      _markFavoritedEvents(weeklyEvents);
      Map<DateTime, List<Event>> mappedWeeklyEvents =
          _eventListProvider.splitEventsByDay(weeklyEvents);
      _weeklyController.sink
          .add(WeeklyEventListLoaded(events: mappedWeeklyEvents));
    } catch (error) {
      _weeklyController.sink.add(EventListError(
          error:
              "Error in fetchWeeklyEvents of eventBloc: " + error.toString()));
    }
  }

  void refetchWeeklyEvents(DateTime weekStart, DateTime weekEnd) async {
    try {
      _weeklyController.sink.add(EventListLoading());
      List<Event> weeklyEvents =
          await _eventListProvider.refetchEventsBetween(weekStart, weekEnd);
      _markFavoritedEvents(weeklyEvents);
      Map<DateTime, List<Event>> mappedWeeklyEvents =
          _eventListProvider.splitEventsByDay(weeklyEvents);
      _weeklyController.sink
          .add(WeeklyEventListLoaded(events: mappedWeeklyEvents));
    } catch (error) {
      _weeklyController.sink.add(EventListError(
          error:
              "Error in fetchWeeklyEvents of eventBloc: " + error.toString()));
    }
  }

  void addView(Event event) {
    _metricsProvider.incrementViewCount(event);
  }

  void refetchRecentEvents(Organization org) async {
    try {
      _recentEventsController.sink.add(EventListLoading());
      RecentEvents recentEvents = await _eventListProvider.refetchRecentEvents(org);
      _markFavoritedEvents(recentEvents.pastEvents);
      _markFavoritedEvents(recentEvents.upcomingEvents);
      _recentEventsController.sink
          .add(RecentEventsLoaded(recentEvents: recentEvents));
    } catch (error) {
      _recentEventsController.sink.add(EventListError(
          error:
              "Error in fetchRecentEvents of eventBloc: " + error.toString()));
    }
  }

  void fetchRecentEvents(Organization org) async {
    try {
      _recentEventsController.sink.add(EventListLoading());
      RecentEvents recentEvents = await _eventListProvider.getRecentEvents(org);
      _markFavoritedEvents(recentEvents.pastEvents);
      _markFavoritedEvents(recentEvents.upcomingEvents);
      _recentEventsController.sink
          .add(RecentEventsLoaded(recentEvents: recentEvents));
    } catch (error) {
      _recentEventsController.sink.add(EventListError(
          error:
              "Error in fetchRecentEvents of eventBloc: " + error.toString()));
    }
  }

  void dispose() {
    _dailyController.close();
    _weeklyController.close();
    _recentEventsController.close();
  }
}

abstract class EventListState extends Equatable {
  EventListState([List args = const []]) : super(args);
}

class EventListError extends EventListState {
  final String error;
  EventListError({@required this.error}) : super([error]);
}

class EventListLoading extends EventListState {}

class DailyEventListState extends EventListState {
  DailyEventListState([List args = const []]) : super(args);
}

class WeeklyEventListState extends EventListState {
  WeeklyEventListState([List args = const []]) : super(args);
}

class DailyEventListLoaded extends DailyEventListState {
  final List<Event> events;
  DailyEventListLoaded({@required this.events}) : super([events]);
}

class WeeklyEventListLoaded extends WeeklyEventListState {
  final Map<DateTime, List<Event>> events;
  WeeklyEventListLoaded({@required this.events}) : super([events]);
}

class RecentEventsLoaded extends EventListState {
  final RecentEvents recentEvents;
  RecentEventsLoaded({@required recentEvents})
      : recentEvents = recentEvents,
        super([recentEvents]);
}
