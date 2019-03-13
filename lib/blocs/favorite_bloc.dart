import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../models/event.dart';
import '../providers/event_list_provider.dart';

class FavoriteBloc {
  StreamController<FavoriteState> _favoriteController;
  EventListProvider _eventListProvider;

  FavoriteBloc({@required eventListProvider}) {
    _eventListProvider = eventListProvider;
    _favoriteController = StreamController<FavoriteState>.broadcast();
  }

  Stream get favorites => _favoriteController.stream;

  FavoriteState get initialState => FavoriteInitial();

  void addFavorite(String eventId, String ucid) {
    try {
      _eventListProvider.addFavorite(ucid, eventId).then((bool success) {
        if (success) {
          _favoriteController.sink
              .add(FavoriteUpdated(eventId: eventId, ucid: ucid, favorited: true));
        } else {
          _favoriteController.sink
              .add(FavoriteError(eventId: eventId, ucid: ucid, favorited: true));
        }
      });
    } catch (error) {
      _favoriteController.sink
          .add(FavoriteError(eventId: eventId, ucid: ucid, favorited: true));
    }
  }

  void removeFavorite(String eventId, String ucid) {
    try {
      //TODO change this.
      _eventListProvider.addFavorite(ucid, eventId).then((bool success) {
        if (success) {
          _favoriteController.sink
              .add(FavoriteUpdated(eventId: eventId, ucid: ucid, favorited: false));
        } else {
          _favoriteController.sink
              .add(FavoriteError(eventId: eventId, ucid: ucid, favorited: false));
        }
      });
    } catch (error) {
      _favoriteController.sink
          .add(FavoriteError(eventId: eventId, ucid: ucid, favorited: false));
    }
  }

  void dispose() {
    _favoriteController.close();
  }
}

abstract class FavoriteState extends Equatable {
  FavoriteState([List args = const []]) : super(args);
}

class FavoriteError extends FavoriteState {
  String eventId;
  String ucid;
  bool favorited;
  FavoriteError({@required this.eventId, @required this.ucid, @required this.favorited})
      : super([eventId, ucid, favorited]);
}

class FavoriteUpdated extends FavoriteState {
  String eventId;
  String ucid;
  bool favorited;
  FavoriteUpdated({@required this.eventId, @required this.ucid, @required this.favorited})
      : super([eventId, ucid, favorited]);
}

class FavoriteInitial extends FavoriteState {}
