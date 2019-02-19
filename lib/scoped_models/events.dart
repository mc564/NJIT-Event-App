import 'package:scoped_model/scoped_model.dart';
import '../models/event.dart';
import '../api/events_api.dart';

class EventsModel extends Model {
  bool _isLoading = true;
  List<Event> _events = [];
  EventAPI api = EventAPI();

  bool get isLoading => _isLoading;

  List<Event> get events {
    return List.from(_events);
  }

  Future<bool> getEventsOnDay(DateTime time) {
    _isLoading = true;
    return api.eventsOnDay(time).then((List<Event> events) {
      if (events != null) {
        _events = events;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      print('was an error');
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }
}
