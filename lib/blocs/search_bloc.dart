import 'dart:async';
import '../providers/search_provider.dart';
import '../providers/event_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../models/event.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/foundation.dart';

//manages all search functions in app
class SearchBloc {
  StreamController<SearchEvent> _requestsController;
  StreamController<SearchState> _searchController;
  SearchProvider _searchProvider;
  EventListProvider _eventListProvider;
  SearchState _initialEventSearchState;
  SearchState _initialStringSearchState;

  SearchBloc() {
    _requestsController = StreamController<SearchEvent>.broadcast();
    _searchController = StreamController<SearchState>.broadcast();
    _searchProvider = SearchProvider();
    _requestsController.stream.forEach((SearchEvent event) {
      event.execute(this);
    });
  }

  //need a separate initialize method because there are dependencies that are tied in a circle
  //so break it by calling a separate initialize method
  void initialize({@required EventListProvider eventListProvider}) {
    _eventListProvider = eventListProvider;
    initializeForSearchingEvents();
    initializeForSearchingStrings();
  }

  SearchState get initialEventSearchState => _initialEventSearchState;
  SearchState get initialStringSearchState => _initialStringSearchState;

  Stream get searchQueries => _searchController.stream;
  StreamSink<SearchEvent> get sink => _requestsController.sink;

  void initializeForSearchingStrings() {
    String emptyStr = '';
    Tuple2<List<String>, String> results =
        _searchProvider.tokenStringSearch(emptyStr);
    _initialStringSearchState = SearchStringsResult(
        token: emptyStr,
        results: results.item1,
        noResultsMessage: results.item2);
  }

  void initializeForSearchingEvents() async {
    String emptyStr = '';
    Tuple2<List<Event>, String> results =
        _searchProvider.tokenEventSearch(emptyStr);
    _initialEventSearchState = SearchEventsResult(
        token: emptyStr,
        results: results.item1,
        noResultsMessage: results.item2);
    DateTime now = DateTime.now();
    List<Event> searchableEvents =
        await _eventListProvider.refetchEventsBetween(
            now.subtract(Duration(days: 7)),
            now.add(Duration(days: 14)),
            false);
    _searchProvider.setAllSearchableEvents(searchableEvents);
  }

  void setSearchableStrings(List<String> searchStrings) {
    _searchProvider.setAllSearchableStrings(searchStrings);
  }

  void searchStrings(String token) {
    try {
      Tuple2<List<String>, String> results =
          _searchProvider.tokenStringSearch(token);
      _searchController.sink.add(SearchStringsResult(
          token: token,
          results: results.item1,
          noResultsMessage: results.item2));
    } catch (error) {
      print('error in search: ' + error.toString());
      _searchController.sink.add(SearchError());
    }
  }

  void searchEvents(String token) {
    try {
      Tuple2<List<Event>, String> results =
          _searchProvider.tokenEventSearch(token);
      _searchController.sink.add(SearchEventsResult(
          token: token,
          results: results.item1,
          noResultsMessage: results.item2));
    } catch (error) {
      print('error in search: ' + error.toString());
      _searchController.sink.add(SearchError());
    }
  }

  void changeEventFavoriteStatus(Event changedEvent) {
    try {
      _searchProvider.changeEventFavoriteStatus(changedEvent);
    } catch (error) {
      print('error in SearchBloc changeEventFavoriteStatus method: ' +
          error.toString());
      _searchController.sink.add(SearchError());
    }
  }

  void changeEventRSVPStatus(Event changedEvent) {
    try {
      _searchProvider.changeEventRSVPStatus(changedEvent);
    } catch (error) {
      print('error in SearchBloc changeEventRSVPStatus method: ' +
          error.toString());
      _searchController.sink.add(SearchError());
    }
  }

  void nullifyAllFavorites() {
    try {
      _searchProvider.nullifyAllFavorites();
    } catch (error) {
      print('error in SearchBloc nullifyAllFavorites method: ' +
          error.toString());
      _searchController.sink.add(SearchError());
    }
  }

  void nullifySelectedFavorites(List<Event> selectedFaves) {
    try {
      _searchProvider.nullifySelectedFavorites(selectedFaves);
    } catch (error) {
      print('error in SearchBloc nullifySelectedFavorites method: ' +
          error.toString());
      _searchController.sink.add(SearchError());
    }
  }

  void dispose() {
    _searchController.close();
    _requestsController.close();
  }
}

/*SEARCH BLOC input EVENTS */
abstract class SearchEvent extends Equatable {
  SearchEvent([List args = const []]) : super(args);
  void execute(SearchBloc searchBloc);
}

class SetSearchableStrings extends SearchEvent {
  final List<String> searchStrings;
  SetSearchableStrings({@required List<String> searchStrings})
      : searchStrings = searchStrings,
        super([searchStrings]);
  void execute(SearchBloc searchBloc) {
    searchBloc.setSearchableStrings(searchStrings);
  }
}

class SearchStrings extends SearchEvent {
  final String token;
  SearchStrings({@required String token})
      : token = token,
        super([token]);
  void execute(SearchBloc searchBloc) {
    searchBloc.searchStrings(token);
  }
}

class SearchEvents extends SearchEvent {
  final String token;
  SearchEvents({@required String token})
      : token = token,
        super([token]);
  void execute(SearchBloc searchBloc) {
    searchBloc.searchEvents(token);
  }
}

//when an event is edited in the edit bloc, can use this
class ReinitializeForSearchingEvents extends SearchEvent {
  void execute(SearchBloc searchBloc) {
    searchBloc.initializeForSearchingEvents();
  }
}

class ChangeEventFavoriteStatus extends SearchEvent {
  final Event changedEvent;
  ChangeEventFavoriteStatus({@required Event changedEvent})
      : changedEvent = changedEvent,
        super([changedEvent]);
  void execute(SearchBloc searchBloc) {
    searchBloc.changeEventFavoriteStatus(changedEvent);
  }
}

class ChangeEventRSVPStatus extends SearchEvent {
  final Event changedEvent;
  ChangeEventRSVPStatus({@required Event changedEvent})
      : changedEvent = changedEvent,
        super([changedEvent]);
  void execute(SearchBloc searchBloc) {
    searchBloc.changeEventRSVPStatus(changedEvent);
  }
}

class NullifyAllFavorites extends SearchEvent {
  void execute(SearchBloc searchBloc) {
    searchBloc.nullifyAllFavorites();
  }
}

class NullifySelectedFavorites extends SearchEvent {
  final List<Event> selectedFavorites;
  NullifySelectedFavorites({@required List<Event> selectedFavorites})
      : selectedFavorites = selectedFavorites,
        super([selectedFavorites]);
  void execute(SearchBloc searchBloc) {
    searchBloc.nullifySelectedFavorites(selectedFavorites);
  }
}

/*SEARCH BLOC output STATES */
abstract class SearchState extends Equatable {
  SearchState([List args = const []]) : super(args);
}

class SearchError extends SearchState {}

class SearchEventsResult extends SearchState {
  final String token;
  final String noResultsMessage;
  final List<Event> results;
  SearchEventsResult(
      {@required this.token,
      @required this.noResultsMessage,
      @required this.results})
      : super([token, noResultsMessage, results]);
}

class SearchStringsResult extends SearchState {
  final String token;
  final String noResultsMessage;
  final List<String> results;
  SearchStringsResult(
      {@required this.token,
      @required this.noResultsMessage,
      @required this.results})
      : super([token, noResultsMessage, results]);
}
