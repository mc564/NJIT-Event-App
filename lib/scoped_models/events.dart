import 'package:scoped_model/scoped_model.dart';
import '../models/event.dart';
import '../api/events_api.dart';

class EventsModel extends Model {
  List<Event> _events = [];
  EventAPI api = EventAPI();

  List<Event> get events {
    return List.from(_events);
  }

  Future<bool> getEventsOnDay(DateTime time) {
    return api.eventsOnDay(time).then((List<Event> events) {
      if (events != null) {
        _events = events;
        notifyListeners();
      }
      return true;
    }).catchError((error) {
      print('in catch error of EventsModel (scoped): '+error);
      return false;
    });
  }
}
