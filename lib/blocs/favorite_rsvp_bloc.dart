import 'package:flutter/material.dart';
import 'dart:async';
import './rsvp_bloc.dart';
import './favorite_bloc.dart';
import './search_bloc.dart';

import '../providers/favorite_rsvp_provider.dart';

class FavoriteAndRSVPBloc {
  bool _updated;
  FavoriteBloc favoriteBloc;
  RSVPBloc rsvpBloc;
  FavoriteAndRSVPProvider favoriteAndRSVPProvider;

  FavoriteAndRSVPBloc(
      {@required String ucid, @required StreamSink<SearchEvent> searchSink}) {
    _updated = false;
    favoriteAndRSVPProvider = FavoriteAndRSVPProvider();
    favoriteBloc = FavoriteBloc(
        ucid: ucid,
        favoriteAndRSVPProvider: favoriteAndRSVPProvider,
        searchSink: searchSink);
    rsvpBloc = RSVPBloc(
        ucid: ucid,
        favoriteAndRSVPProvider: favoriteAndRSVPProvider,
        searchSink: searchSink);
    favoriteBloc.favoriteRequests.listen((dynamic state) {
      if (state is FavoritesUpdated) {
        if (!_updated) {
          _updated = true;
          rsvpBloc.sink.add(FetchUserRSVPs());
        } else {
          _updated = false;
        }
      }
    });
    rsvpBloc.userRSVPRequests.listen((dynamic state) {
      if (state is UserRSVPsUpdated) {
        if (!_updated) {
          _updated = true;
          favoriteBloc.sink.add(FetchFavorites());
        } else {
          _updated = false;
        }
      }
    });
  }

  void dispose() {
    favoriteBloc.dispose();
    rsvpBloc.dispose();
  }
}
