import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../models/event.dart';
import '../providers/favorite_provider.dart';

class FavoriteBloc {
  StreamController<FavoriteEvent> _requestsController;
  StreamController<FavoriteState>
      _favoriteErrorsController; //stream that just logs errors setting favorites
  StreamController<FavoriteState>
      _favoriteController; //stream that has both error and non-error states with favorite event lists - used for favorites page
  FavoriteProvider _favoriteProvider;
  FavoriteState _prevState;
  String _ucid;

  FavoriteBloc({@required String ucid}) {
    _ucid = ucid;
    _favoriteProvider = FavoriteProvider(ucid: _ucid);
    _favoriteErrorsController = StreamController<FavoriteState>.broadcast();
    _favoriteController = StreamController<FavoriteState>.broadcast();
    _requestsController = StreamController<FavoriteEvent>.broadcast();
    _prevState = FavoriteInitial();
    _favoriteController.stream.listen((FavoriteState state) {
      _prevState = state;
    });
    fetchFavorites();
    _requestsController.stream.forEach((FavoriteEvent event) {
      event.execute(this);
    });
  }

  Stream get favoriteSettingErrors => _favoriteErrorsController.stream;
  Stream get favoriteRequests => _favoriteController.stream;

  StreamSink<FavoriteEvent> get sink => _requestsController.sink;

  FavoriteState get initialState => _prevState;

  FavoriteProvider get favoriteProvider => _favoriteProvider;

  void _alertFavoriteError(Event errorEvent, List<Event> rollbackFavorites,
      bool favorited, String errorMsg) {
    FavoriteError errorState = FavoriteError(
        eventId: errorEvent.eventId,
        ucid: _ucid,
        favorited: favorited,
        rollbackFavorites: rollbackFavorites,
        errorMsg: errorMsg);
    _favoriteErrorsController.sink.add(errorState);
    _favoriteController.sink.add(errorState);
  }

  void _alertFavoriteErrorWithoutRollback(
      Event errorEvent, bool favorited, String errorMsg) {
    FavoriteError errorState = FavoriteError(
        eventId: errorEvent.eventId,
        ucid: _ucid,
        favorited: favorited,
        errorMsg: errorMsg);
    _favoriteErrorsController.sink.add(errorState);
    _favoriteController.sink.add(errorState);
  }

  void _alertFavoritesFetchError(String errorMsg) {
    FavoritesFetchError errorState = FavoritesFetchError(errorMsg: errorMsg);
    _favoriteController.sink.add(errorState);
    _favoriteErrorsController.sink.add(errorState);
  }

  void fetchFavorites() async {
    try {
      bool fetched = await _favoriteProvider.fetchFavorites();
      if (fetched) {
        _favoriteController.sink
            .add(FavoritesUpdated(favorites: _favoriteProvider.allFavorites));
      } else {
        _alertFavoritesFetchError(
            'Error in fetchFavorites method of favorite BLOC.');
      }
    } catch (error) {
      _alertFavoritesFetchError(
          'Error in fetchFavorites method of favorite BLOC: ' +
              error.toString());
    }
  }

  void addFavorite(Event event) async {
    try {
      bool successfullyAdded = await _favoriteProvider.addFavorite(event);
      List<Event> favorites = _favoriteProvider.allFavorites;
      print('favorites length is: '+favorites.length.toString());
      if (successfullyAdded) {
        _favoriteController.sink.add(FavoritesUpdated(favorites: favorites));
      } else {
        _alertFavoriteError(
            event, favorites, true, 'Failed to addFavorite in favoriteBloc');
      }
    } catch (error) {
      _alertFavoriteErrorWithoutRollback(event, true,
          'Failed to addFavorite in favoriteBloc error: ' + error.toString());
    }
  }

  void removeFavorite(Event event) async {
    try {
      bool successfullyRemoved = await _favoriteProvider.removeFavorite(event);
      List<Event> favorites = _favoriteProvider.allFavorites;
      if (successfullyRemoved) {
        _favoriteController.sink.add(FavoritesUpdated(favorites: favorites));
      } else {
        _alertFavoriteError(event, favorites, false,
            'Failed to removeFavorite in favoriteBloc');
      }
    } catch (error) {
      _alertFavoriteErrorWithoutRollback(
          event,
          false,
          'Failed to removeFavorite in favoriteBloc error: ' +
              error.toString());
    }
  }

  void dispose() {
    _favoriteErrorsController.close();
    _favoriteController.close();
    _requestsController.close();
  }
}

/*FAVORITE BLOC input EVENTS */
abstract class FavoriteEvent extends Equatable {
  FavoriteEvent([List args = const []]) : super(args);
  void execute(FavoriteBloc favoriteBloc);
}

class FetchFavorites extends FavoriteEvent {
  void execute(FavoriteBloc favoriteBloc) {
    favoriteBloc.fetchFavorites();
  }
}

class AddFavorite extends FavoriteEvent {
  final Event eventToFavorite;
  AddFavorite({@required Event eventToFavorite})
      : eventToFavorite = eventToFavorite;
  void execute(FavoriteBloc favoriteBloc) {
    favoriteBloc.addFavorite(eventToFavorite);
  }
}

class RemoveFavorite extends FavoriteEvent {
  final Event eventToUnfavorite;
  RemoveFavorite({@required Event eventToUnfavorite})
      : eventToUnfavorite = eventToUnfavorite;
  void execute(FavoriteBloc favoriteBloc) {
    favoriteBloc.removeFavorite(eventToUnfavorite);
  }
}

/*FAVORITE BLOC output STATES */
//favorite only has 2 states: initial and error
//because the ui only needs to know if there was an error setting a favorite
abstract class FavoriteState extends Equatable {
  FavoriteState([List args = const []]) : super(args);
}

class FavoriteInitial extends FavoriteState {}

class FavoritesFetchError extends FavoriteState {
  String errorMsg;
  FavoritesFetchError({@required String errorMsg}) : errorMsg = errorMsg;
}

class FavoriteError extends FavoriteState {
  String errorMsg;
  String eventId;
  String ucid;
  bool favorited;
  List<Event> rollbackFavorites;
  FavoriteError(
      {@required this.eventId,
      @required this.ucid,
      @required this.favorited,
      @required this.errorMsg,
      this.rollbackFavorites})
      : super([eventId, ucid, favorited, rollbackFavorites, errorMsg]);
}

class FavoritesUpdated extends FavoriteState {
  final List<Event> favorites;
  FavoritesUpdated({@required List<Event> favorites})
      : favorites = favorites,
        super([favorites]);
}
