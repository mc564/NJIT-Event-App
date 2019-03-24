import 'dart:async';
import '../models/event.dart';
import '../models/event_details.dart';
import '../api/database_event_api.dart';

//keeps track of view count, could probably be extended to other things as well as needed
class MetricsProvider {
  DatabaseEventAPI _dbAPI;

  MetricsProvider() {
    _dbAPI = DatabaseEventAPI();
  }

  Future<bool> incrementViewCount(Event event) {
    return _dbAPI.incrementViewCount(event);
  }

  Future<EventDetails> getMetrics(Event event) async {
    EventDetails details = await _dbAPI.getEventDetails(event);
    if (details == null) {
      EventDetails empty = EventDetails();
      empty.eventId = event.eventId;
      empty.lastWeekViewCount = 0;
      empty.thisWeekViewCount = 0;
      return empty;
    }
    return details;
  }

  Future<List<EventDetails>> bulkReadMetrics(List<Event> events) async {
    return _dbAPI.bulkReadEventDetails(events);
  }
}
