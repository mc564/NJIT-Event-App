import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../models/event.dart';
import '../providers/rsvp_provider.dart';
import '../providers/favorite_rsvp_provider.dart';
import './search_bloc.dart';

class RSVPBloc {
  StreamController<RSVPEvent> _requestsController;
  StreamController<RSVPState> _userRSVPController;
  StreamController<RSVPState> _eventRSVPController;
  RSVPProvider _rsvpProvider;
  RSVPState _prevUserState;
  RSVPState _prevEventState;
  String _ucid;

  FavoriteAndRSVPProvider _favoriteAndRSVPProvider;
  StreamSink<SearchEvent> _searchSink;

  RSVPBloc({
    @required String ucid,
    @required FavoriteAndRSVPProvider favoriteAndRSVPProvider,
    @required StreamSink<SearchEvent> searchSink,
  }) {
    _ucid = ucid;
    _searchSink = searchSink;
    _favoriteAndRSVPProvider = favoriteAndRSVPProvider;
    _rsvpProvider = RSVPProvider(ucid: _ucid);
    favoriteAndRSVPProvider.setRSVPProvider(_rsvpProvider);
    _userRSVPController = StreamController<RSVPState>.broadcast();
    _eventRSVPController = StreamController<RSVPState>.broadcast();
    _requestsController = StreamController<RSVPEvent>.broadcast();
    _prevUserState = UserRSVPsUpdating();
    _prevEventState = EventRSVPsUpdating();
    _userRSVPController.stream.listen((RSVPState state) {
      _prevUserState = state;
    });
    _eventRSVPController.stream.listen((RSVPState state) {
      _prevEventState = state;
    });
    fetchUserRSVPs();
    _requestsController.stream.forEach((RSVPEvent event) {
      event.execute(this);
    });
  }

  Stream get userRSVPRequests => _userRSVPController.stream;
  Stream get eventRSVPRequests => _eventRSVPController.stream;

  StreamSink<RSVPEvent> get sink => _requestsController.sink;

  RSVPState get userRSVPInitialState => _prevUserState;
  RSVPState get eventRSVPInitialState => _prevEventState;

  RSVPProvider get rsvpProvider => _rsvpProvider;

  void _alertUserRSVPError(String errorMsg) {
    RSVPError errorState = RSVPError(errorMsg: errorMsg);
    _userRSVPController.sink.add(errorState);
  }

  void _alertEventRSVPError(String errorMsg) {
    RSVPError errorState = RSVPError(errorMsg: errorMsg);
    _eventRSVPController.sink.add(errorState);
  }

  void _alertUserRSVPsSuccessfullyUpdated() {
    List<Event> events = _rsvpProvider.allRSVPdEvents;
    _favoriteAndRSVPProvider.markFavoritedAndRSVPdEvents(events);
    _userRSVPController.sink.add(UserRSVPsUpdated(rsvps: events));
  }

  void fetchUserRSVPs() async {
    try {
      bool fetched = await _rsvpProvider.fetchUserRSVPs();
      if (fetched) {
        _alertUserRSVPsSuccessfullyUpdated();
      } else {
        _alertUserRSVPError('Error in fetchRSVPs method of RSVP BLOC.');
      }
    } catch (error) {
      _alertUserRSVPError(
          'Error in fetchRSVPs method of RSVP BLOC: ' + error.toString());
    }
  }

  void fetchEventRSVPs(Event event) async {
    try {
      _eventRSVPController.sink.add(EventRSVPsUpdating());
      List<String> rsvpUCIDs = await _rsvpProvider.fetchEventRSVPs(event);
      _eventRSVPController.sink.add(EventRSVPsUpdated(ucids: rsvpUCIDs));
    } catch (error) {
      _alertEventRSVPError(
          'Error in fetchEventRSVPs method of RSVP BLOC: ' + error.toString());
    }
  }

  void addRSVP(Event event) async {
    try {
      bool successfullyAdded = await _rsvpProvider.addRSVP(event);
      if (successfullyAdded) {
        _alertUserRSVPsSuccessfullyUpdated();
        fetchEventRSVPs(event);
        _searchSink.add(ChangeEventRSVPStatus(changedEvent: event));
      } else {
        _alertUserRSVPError('Failed to addRSVP in rsvpBloc');
      }
    } catch (error) {
      _alertUserRSVPError(
          'Failed to addRSVP in rsvpBloc error: ' + error.toString());
    }
  }

  void removeRSVP(Event event) async {
    try {
      bool successfullyRemoved = await _rsvpProvider.removeRSVP(event);
      if (successfullyRemoved) {
        _alertUserRSVPsSuccessfullyUpdated();
        fetchEventRSVPs(event);
        _searchSink.add(ChangeEventRSVPStatus(changedEvent: event));
      } else {
        _alertUserRSVPError('Failed to removeRSVP in rsvpBloc');
      }
    } catch (error) {
      _alertUserRSVPError(
          'Failed to removeRSVP in rsvpBloc error: ' + error.toString());
    }
  }

  void removeAllRSVPs() async {
    try {
      bool successfullyRemovedAllRSVPs = await _rsvpProvider.removeAllRSVPs();
      if (successfullyRemovedAllRSVPs) {
        fetchUserRSVPs();
      } else {
        _alertUserRSVPError('Failed to removeAllRSVPs in rsvpBloc');
        return;
      }
    } catch (error) {
      _alertUserRSVPError(
          'Failed to removeAllRSVPs in rsvpBloc Error: ' + error.toString());
    }
  }

  //TODO (if needed) modify search sink as well..
  void removePastRSVPs() async {
    try {
      bool successfullyRemoved = await _rsvpProvider.removePastRSVPs();
      if (successfullyRemoved) {
        fetchUserRSVPs();
      } else {
        _alertUserRSVPError('Failed to removePastRSVPs in rsvpBloc');
      }
    } catch (error) {
      _alertUserRSVPError(
          'Failed to removePastRSVPs in rsvpBloc error: ' + error.toString());
    }
  }

  void dispose() {
    _userRSVPController.close();
    _eventRSVPController.close();
    _requestsController.close();
  }
}

/*FAVORITE BLOC input EVENTS */
abstract class RSVPEvent extends Equatable {
  RSVPEvent([List args = const []]) : super(args);
  void execute(RSVPBloc rsvpBloc);
}

class FetchUserRSVPs extends RSVPEvent {
  void execute(RSVPBloc rsvpBloc) {
    rsvpBloc.fetchUserRSVPs();
  }
}

class FetchEventRSVPs extends RSVPEvent {
  final Event event;
  FetchEventRSVPs({@required Event event})
      : event = event,
        super([event]);
  void execute(RSVPBloc rsvpBloc) {
    rsvpBloc.fetchEventRSVPs(event);
  }
}

class AddRSVP extends RSVPEvent {
  final Event eventToRSVP;
  AddRSVP({@required Event eventToRSVP})
      : eventToRSVP = eventToRSVP,
        super([eventToRSVP]);
  void execute(RSVPBloc rsvpBloc) {
    rsvpBloc.addRSVP(eventToRSVP);
  }
}

class RemoveRSVP extends RSVPEvent {
  final Event eventToUnRSVP;
  RemoveRSVP({@required Event eventToUnRSVP})
      : eventToUnRSVP = eventToUnRSVP,
        super([eventToUnRSVP]);
  void execute(RSVPBloc rsvpBloc) {
    rsvpBloc.removeRSVP(eventToUnRSVP);
  }
}

class RemoveAllRSVPs extends RSVPEvent {
  void execute(RSVPBloc rsvpBloc) {
    rsvpBloc.removeAllRSVPs();
  }
}

class RemovePastRSVPs extends RSVPEvent {
  void execute(RSVPBloc rsvpBloc) {
    rsvpBloc.removePastRSVPs();
  }
}

abstract class RSVPState extends Equatable {
  RSVPState([List args = const []]) : super(args);
}

class RSVPError extends RSVPState {
  String errorMsg;
  RSVPError({@required String errorMsg})
      : errorMsg = errorMsg,
        super([errorMsg]);
}

class UserRSVPsUpdating extends RSVPState {}

class UserRSVPsUpdated extends RSVPState {
  final List<Event> rsvps;
  UserRSVPsUpdated({@required List<Event> rsvps})
      : rsvps = rsvps,
        super([rsvps]);
}

class EventRSVPsUpdating extends RSVPState {}

class EventRSVPsUpdated extends RSVPState {
  final List<String> ucids;
  EventRSVPsUpdated({@required List<String> ucids})
      : ucids = ucids,
        super([ucids]);
}
