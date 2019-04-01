import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../models/event.dart';
import '../providers/favorite_provider.dart';

class FavoriteBloc {
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
    _prevState = FavoriteInitial();
    _favoriteController.stream.listen((FavoriteState state) {
      _prevState = state;
    });
    _favoriteProvider.initialize().then((bool success) {
      if (success) {
        _favoriteController.sink
            .add(FavoritesUpdated(favorites: _favoriteProvider.allFavorites));
      }
    });
  }

  Stream get favoriteSettingErrors => _favoriteErrorsController.stream;
  Stream get favoriteRequests => _favoriteController.stream;

  FavoriteState get initialState => _prevState;

  FavoriteProvider get favoriteProvider => _favoriteProvider;

  void _alertFavoriteError(
      Event errorEvent, List<Event> rollbackFavorites, bool favorited) {
    FavoriteError errorState = FavoriteError(
        eventId: errorEvent.eventId,
        ucid: _ucid,
        favorited: favorited,
        rollbackFavorites: rollbackFavorites);
    _favoriteErrorsController.sink.add(errorState);
    _favoriteController.sink.add(errorState);
  }

  void _alertFavoriteErrorWithoutRollback(Event errorEvent, bool favorited) {
    FavoriteError errorState = FavoriteError(
        eventId: errorEvent.eventId, ucid: _ucid, favorited: favorited);
    _favoriteErrorsController.sink.add(errorState);
    _favoriteController.sink.add(errorState);
  }

  void addFavorite(Event event) async {
    try {
      bool successfullyAdded = await _favoriteProvider.addFavorite(event);
      List<Event> favorites = _favoriteProvider.allFavorites;
      if (successfullyAdded) {
        _favoriteController.sink.add(FavoritesUpdated(favorites: favorites));
      } else {
        _alertFavoriteError(event, favorites, true);
      }
    } catch (error) {
      _alertFavoriteErrorWithoutRollback(event, true);
    }
  }

  void removeFavorite(Event event) async {
    try {
      bool successfullyRemoved = await _favoriteProvider.removeFavorite(event);
      List<Event> favorites = _favoriteProvider.allFavorites;
      if (successfullyRemoved) {
        _favoriteController.sink.add(FavoritesUpdated(favorites: favorites));
      } else {
        _alertFavoriteError(event, favorites, false);
      }
    } catch (error) {
      _alertFavoriteErrorWithoutRollback(event, false);
    }
  }

  void dispose() {
    _favoriteErrorsController.close();
    _favoriteController.close();
  }
}

//favorite only has 2 states: initial and error
//because the ui only needs to know if there was an error setting a favorite
abstract class FavoriteState extends Equatable {
  FavoriteState([List args = const []]) : super(args);
}

class FavoriteInitial extends FavoriteState {}

class FavoriteError extends FavoriteState {
  String eventId;
  String ucid;
  bool favorited;
  List<Event> rollbackFavorites;
  FavoriteError(
      {@required this.eventId,
      @required this.ucid,
      @required this.favorited,
      this.rollbackFavorites})
      : super([eventId, ucid, favorited, rollbackFavorites]);
}

class FavoritesUpdated extends FavoriteState {
  final List<Event> favorites;
  FavoritesUpdated({@required List<Event> favorites})
      : favorites = favorites,
        super([favorites]);
}
