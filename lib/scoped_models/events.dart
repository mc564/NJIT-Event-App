import 'dart:math';
import 'package:scoped_model/scoped_model.dart';
import '../models/event.dart';
import '../data/events_api.dart';
import '../data/database.dart';

class EventsModel extends Model {
  bool _isLoading = false;
  List<Event> _events = [];
  EventAPI api = EventAPI();
  Database db = Database();

  bool get isLoading => _isLoading;

  List<Event> get events {
    return List.from(_events);
  }

  double vectorMagnitude(List<int> vector) {
    int ans = 0;
    vector.forEach((int num) {
      ans += (num * num);
    });

    return sqrt(ans);
  }

  double dotProduct(List<int> v1, List<int> v2) {
    double prod = 0;
    for (int i = 0; i < v1.length; i++) {
      prod += v1[i] * v2[i];
    }
    return prod;
  }

  //works better if some words are the same - so can work on different length titles
  double cosineSimilarityWords(Event one, Event two) {
    Map<String, List<int>> wordFreq = Map<String, List<int>>();
    for (String word in one.title.toLowerCase().split(' ')) {
      if (!wordFreq.containsKey(word)) wordFreq[word] = [0, 0];
      wordFreq[word][0] = wordFreq[word][0] + 1;
    }
    for (String word in two.title.toLowerCase().split(' ')) {
      if (!wordFreq.containsKey(word)) wordFreq[word] = [0, 0];
      wordFreq[word][1] = wordFreq[word][1] + 1;
    }

    List<int> v1 = [];
    List<int> v2 = [];

    wordFreq.forEach((String char, List<int> freqList) {
      v1.add(freqList[0]);
      v2.add(freqList[1]);
    });

    double magOne = vectorMagnitude(v1);
    double magTwo = vectorMagnitude(v2);
    double dotProd = dotProduct(v1, v2);
    return dotProd / (magOne * magTwo);
  }

  //works better if there are minor spell check differences between the
  //first title and the second
  double cosineSimilarityCharacters(Event one, Event two) {
    Map<String, List<int>> charFreq = Map<String, List<int>>();
    for (int i = 0; i < one.title.length; i++) {
      String char = one.title[i];
      if (!charFreq.containsKey(char)) charFreq[char] = [0, 0];
      charFreq[char][0] = charFreq[char][0] + 1;
    }

    for (int i = 0; i < two.title.length; i++) {
      String char = two.title[i];
      if (!charFreq.containsKey(char)) charFreq[char] = [0, 0];
      charFreq[char][1] = charFreq[char][1] + 1;
    }

    List<int> v1 = [];
    List<int> v2 = [];

    charFreq.forEach((String char, List<int> freqList) {
      v1.add(freqList[0]);
      v2.add(freqList[1]);
    });

    double magOne = vectorMagnitude(v1);
    double magTwo = vectorMagnitude(v2);
    double dotProd = dotProduct(v1, v2);
    return dotProd / (magOne * magTwo);
  }

  Future<bool> getEventsOnDay(DateTime time) async {
    _isLoading = true;
    notifyListeners();

    List<Event> _localEvents = [];
    final apiEvents = await api.eventsOnDay(time);
    final dbEvents = await db.eventsOnDay(time);
    _localEvents.addAll(apiEvents);
    _localEvents.addAll(dbEvents);
    _events = _localEvents;

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> getEventsBetween(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();

    List<Event> _localEvents = [];
    final apiEvents = await api.eventsBetween(start, end);
    final dbEvents = await db.eventsBetween(start, end);
    _localEvents.addAll(apiEvents);
    _localEvents.addAll(dbEvents);
    _events = _localEvents;

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<List<Event>> getSimilarEvents(Event event) {
    _isLoading = true;
    notifyListeners();
    DateTime earlierStart = event.startTime.subtract(Duration(days: 14));
    DateTime laterEnd = event.endTime.add(Duration(days: 14));

    return getEventsBetween(earlierStart, laterEnd).then((bool success) {
      List<Event> rtn = [];
      _events.forEach((Event recentEvent) {
        double charSimilarity = cosineSimilarityCharacters(event, recentEvent);
        double wordSimilarity = cosineSimilarityWords(event, recentEvent);
        if (charSimilarity > 0.8 || wordSimilarity > 0.2) {
          rtn.add(recentEvent);
        }
      });
      _isLoading = false;
      notifyListeners();
      //keep the list items with high cosine similarity (titles only) and add them to the list
      return rtn;
    });
  }

  Future<bool> addEvent(Event event) {
    return db.addEvent(event).then((bool success) {
      if (success) {
        print("success");
        return true;
      } else {
        print("failure");
        return false;
      }
    });
  }
}
