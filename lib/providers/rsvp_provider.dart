import 'package:flutter/material.dart';
import 'dart:async';
import '../models/event.dart';
import '../api/database_event_api.dart';
import '../api/njit_event_api.dart';

class RSVPProvider {
  String _ucid;
  List<Event> _allRSVPdEvents;

  RSVPProvider({@required String ucid}) {
    _ucid = ucid;
  }

  Future<bool> fetchUserRSVPs() async {
    try {
      print('fetching user rsvps');
      List<String> rsvpIds = await DatabaseEventAPI.getRSVPEvents(_ucid);
      List<Event> rsvpEvents = await _getAllRSVPdEvents(rsvpIds);
      if (rsvpEvents != null) {
        rsvpEvents
            .sort((Event e1, Event e2) => e1.startTime.compareTo(e2.startTime));
        _allRSVPdEvents = rsvpEvents;
      }
      return true;
    } catch (error) {
      throw Exception('huh, failed to fetchRSVPs in RSVPProvider, error: ' +
          error.toString());
    }
  }

  Future<List<String>> fetchEventRSVPs(Event event) async {
    try {
      List<String> rsvpUCIDs = await DatabaseEventAPI.getRSVPUsers(event);
      if (rsvpUCIDs != null) {
        rsvpUCIDs.sort((String ucid1, String ucid2) => ucid1.compareTo(ucid2));
      }
      return rsvpUCIDs;
    } catch (error) {
      throw Exception(
          'huh, failed to fetchEventRSVPs in RSVPProvider, error: ' +
              error.toString());
    }
  }

  List<Event> get allRSVPdEvents {
    if (_allRSVPdEvents == null) {
      return null;
    } else {
      return List<Event>.from(_allRSVPdEvents);
    }
  }

  bool isRSVPd(Event event) {
    if (_allRSVPdEvents == null || event == null || event.eventId == null)
      return false;
    if (_allRSVPdEvents.map((Event e) => e.eventId).contains(event.eventId))
      return true;
    else
      return false;
  }

  Future<bool> addRSVP(Event event) async {
    try {
      event.rsvpd = true;
      bool success = await DatabaseEventAPI.addRSVP(event.eventId, _ucid);
      if (success) {
        _allRSVPdEvents.add(event);
        _allRSVPdEvents
            .sort((Event e1, Event e2) => e1.startTime.compareTo(e2.startTime));
        return true;
      } else {
        event.rsvpd = false;
        return false;
      }
    } catch (error) {
      event.rsvpd = false;
      throw Exception(
          'Error in RSVPProvider addRSVP method: ' + error.toString());
    }
  }

  Future<bool> removeRSVP(Event event) async {
    try {
      event.rsvpd = false;
      bool success = await DatabaseEventAPI.removeRSVP(event.eventId, _ucid);
      if (success) {
        _allRSVPdEvents.removeWhere(
            (Event rsvpEvent) => rsvpEvent.eventId == event.eventId);
        return true;
      } else {
        event.rsvpd = true;
        return false;
      }
    } catch (error) {
      event.rsvpd = true;
      throw Exception(
          'Error in RSVPProvider removeRSVP method: ' + error.toString());
    }
  }

  Future<bool> removeAllRSVPs() async {
    try {
      bool success = await DatabaseEventAPI.removeAllRSVPs(_ucid);
      if (success) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error in RSVPProvider removeAllRSVPs method: ' + error.toString());
    }
  }

  Future<bool> removeSelectedRSVPs(List<String> rsvpIds) async {
    //TODO change to use rsvp database methods
    try {
      if (rsvpIds == null || rsvpIds.length == 0) return true;
      bool success = await DatabaseEventAPI.removeSelectedRSVPs(_ucid, rsvpIds);
      if (success) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error in RSVPProvider removeSelectedRSVPs method: ' +
              error.toString());
    }
  }

  Future<bool> removePastRSVPs() async {
    try {
      List<Event> pastEventsRSVPd = _allRSVPdEvents
          .where((Event e) => e.endTime.isBefore(DateTime.now()))
          .toList();
      List<String> pastEventIds =
          pastEventsRSVPd.map((Event e) => e.eventId).toList();
      bool removedPastRSVPs = await removeSelectedRSVPs(pastEventIds);
      if (removedPastRSVPs) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error in RSVPProvider removePastRSVPs method: ' + error.toString());
    }
  }

  void _deleteDupEdited(List<Event> dbEvents, List<Event> apiEvents) {
    for (Event event in dbEvents) {
      if (event.eventId.length < 20) {
        apiEvents
            .removeWhere((Event event2) => event2.eventId == event.eventId);
      }
    }
  }

  //only for internal initialization use, users (blocs) can use the getter for the list
  Future<List<Event>> _getAllRSVPdEvents(List<String> initialRSVPIds) async {
    try {
      List<Event> allRSVPdEvents = List<Event>();
      List<String> dbRSVPIds = List<String>();
      List<String> njitRSVPIds = List<String>();
      for (int i = 0; i < initialRSVPIds.length; i++) {
        String eventId = initialRSVPIds[i];
        if (eventId.length < 20) {
          njitRSVPIds.add(eventId);
        }
        //just add them all to dbRSVPIds in case an edited (duplicate) record is in my db
        dbRSVPIds.add(eventId);
      }
      List<Event> dbEvents = await DatabaseEventAPI.getEventsWithIds(dbRSVPIds);
      List<Event> njitEvents = await NJITEventAPI.getEventsWithIds(njitRSVPIds);
      _deleteDupEdited(dbEvents, njitEvents);
      if (dbEvents.length > 0) allRSVPdEvents.addAll(dbEvents);
      if (njitEvents.length > 0) allRSVPdEvents.addAll(njitEvents);
      return allRSVPdEvents;
    } catch (error) {
      throw Exception(
          'Error in RSVPProvider class, _getAllRSVPdEvents function: ' +
              error.toString());
    }
  }
}
