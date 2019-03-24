import 'package:flutter/material.dart';
import 'dart:async';
import '../models/event.dart';
import '../api/database_event_api.dart';
import '../api/njit_event_api.dart';

class FavoriteProvider {
  DatabaseEventAPI _dbAPI;
  NJITEventAPI _njitAPI;
  String _ucid;
  List<Event> _allFavoritedEvents;

  FavoriteProvider({@required String ucid}) {
    _dbAPI = DatabaseEventAPI();
    _njitAPI = NJITEventAPI();
    _ucid = ucid;
  }

  //can be called by the favoriteBLOC to await initialization of the favoriteProvider events
  Future<bool> initialize(List<String> initialFavoriteIds) async {
    try {
      List<Event> favorites = await _allFavorites(initialFavoriteIds);
      if (favorites != null && favorites.length > 0) {
        favorites
            .sort((Event e1, Event e2) => e1.startTime.compareTo(e2.startTime));
        _allFavoritedEvents = favorites;
      }
      return true;
    } catch (error) {
      throw Exception('huh, failed to initialize in FavoriteProvider, error: ' +
          error.toString());
    }
  }

  List<Event> get allFavorites {
    if (_allFavoritedEvents == null || _allFavoritedEvents.length == 0) {
      return null;
    } else {
      return List<Event>.from(_allFavoritedEvents);
    }
  }

  bool favorited(Event event) {
    if (_allFavoritedEvents == null || event == null || event.eventId == null)
      return false;
    if (_allFavoritedEvents.map((Event e) => e.eventId).contains(event.eventId))
      return true;
    else
      return false;
  }

  Future<bool> addFavorite(Event event) async {
    try {
      event.favorited = true;
      bool success = await _dbAPI.addFavorite(event.eventId, _ucid);
      if (success) {
        _allFavoritedEvents.add(event);
        _allFavoritedEvents
            .sort((Event e1, Event e2) => e1.startTime.compareTo(e2.startTime));
        return true;
      } else {
        event.favorited = false;
        return false;
      }
    } catch (error) {
      event.favorited = false;
      return false;
    }
  }

  Future<bool> removeFavorite(Event event) async {
    try {
      event.favorited = false;
      bool success = await _dbAPI.removeFavorite(event.eventId, _ucid);
      if (success) {
        _allFavoritedEvents.removeWhere(
            (Event faveEvent) => faveEvent.eventId == event.eventId);
        return true;
      } else {
        event.favorited = true;
        return false;
      }
    } catch (error) {
      event.favorited = true;
      return false;
    }
  }

  //only for internal initialization use, users (blocs) can use the getter for the list
  Future<List<Event>> _allFavorites(List<String> initialFavoriteIds) async {
    try {
      List<Event> allFavorites = List<Event>();
      List<String> dbFaveIds = List<String>();
      List<String> njitFaveIds = List<String>();
      //change this to bulk get events with id for both apis
      for (int i = 0; i < initialFavoriteIds.length; i++) {
        String eventId = initialFavoriteIds[i];
        if (eventId.length > 20) {
          dbFaveIds.add(eventId);
        } else {
          njitFaveIds.add(eventId);
        }
      }
      allFavorites.addAll(await _dbAPI.getEventsWithIds(dbFaveIds));
      allFavorites.addAll(await _njitAPI.getEventsWithIds(njitFaveIds));
      return allFavorites;
    } catch (error) {
      throw Exception(
          'Error in FavoriteProvider class, allFavoritedEvents function: ' +
              error.toString());
    }
  }
}
