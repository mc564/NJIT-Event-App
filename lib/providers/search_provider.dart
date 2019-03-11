import '../models/event.dart';
import 'package:tuple/tuple.dart';

class SearchProvider {
  //can do 2 type of searches, event or string
  List<Event> _allSearchableEvents;
  List<String> _allSearchableStrings;
  String quotes;

  SearchProvider() {
    quotes = '""';
  }

  void setAllSearchableEvents(List<Event> events) {
    _allSearchableEvents = events;
  }

  void setAllSearchableStrings(List<String> strings) {
    _allSearchableStrings = strings;
  }

  List<String> tokenStringMatches(String token) {
    List<String> matches = List<String>();

    if (token != null && _allSearchableStrings != null && token.isNotEmpty) {
      token = token.toLowerCase();
      for (String str in _allSearchableStrings) {
        String searchResult = str.toLowerCase();
        if (searchResult.contains(token)) {
          matches.add(str);
        }
      }
    }

    matches.sort((String s1, String s2) => s1.compareTo(s2));

    return matches;
  }

  List<Event> tokenEventMatches(String token) {
    List<Event> matches = List<Event>();

    if (token != null && _allSearchableEvents != null && token.isNotEmpty) {
      token = token.toLowerCase();
      for (Event event in _allSearchableEvents) {
        String title = event.title.toLowerCase();
        if (title.contains(token)) {
          matches.add(event);
        }
      }
    }

    matches.sort((Event e1, Event e2) => e1.startTime.compareTo(e2.startTime));

    return matches;
  }

  String noResultsFoundMessage(String token) {
    return 'No results found for ${token == null || token.isEmpty ? quotes : token}.';
  }

  //returns a tuple of the matching events in a list and a no results found message in case it is needed
  Tuple2<List<Event>, String> tokenEventSearch(String token) {
    return Tuple2<List<Event>, String>(
        tokenEventMatches(token), noResultsFoundMessage(token));
  }

  Tuple2<List<String>, String> tokenStringSearch(String token) {
    return Tuple2<List<String>, String>(
        tokenStringMatches(token), noResultsFoundMessage(token));
  }
}
