import 'dart:async';
import '../models/event.dart';
import '../models/event_details.dart';
import '../api/database_event_api.dart';

//keeps track of view count, could probably be extended to other things as well as needed
class MetricsProvider {

  Future<bool> incrementViewCount(Event event) {
    return DatabaseEventAPI.incrementViewCount(event);
  }

  Future<EventDetails> getMetrics(Event event) async {
    EventDetails details = await DatabaseEventAPI.getEventDetails(event);
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
    return DatabaseEventAPI.bulkReadEventDetails(events);
  }
}
