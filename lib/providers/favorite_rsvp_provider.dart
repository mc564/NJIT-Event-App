import './favorite_provider.dart';
import './rsvp_provider.dart';
import '../models/event.dart';

class FavoriteAndRSVPProvider {
  FavoriteProvider _favoriteProvider;
  RSVPProvider _rsvpProvider;

  //use setters instead of asking for arguments in constructor because favorite and rsvpBlocs need to initialize
  //before they can give out their providers, BUT they need access to this provider beforehand in THEIR constructors
  void setFavoriteProvider(FavoriteProvider favoriteProvider) {
    _favoriteProvider = favoriteProvider;
  }

  void setRSVPProvider(RSVPProvider rsvpProvider) {
    _rsvpProvider = rsvpProvider;
  }

  void markFavoritedAndRSVPdEvents(List<Event> events) {
    if (_favoriteProvider == null || _rsvpProvider == null) return;
    _markFavoritedEvents(events);
    _markRSVPdEvents(events);
  }

  void _markFavoritedEvents(List<Event> events) {
    events = events.map((Event event) {
      if (_favoriteProvider.favorited(event)) {
        event.favorited = true;
      } else {
        event.favorited = false;
      }
    }).toList();
  }

  void _markRSVPdEvents(List<Event> events) {
    events = events.map((Event event) {
      if (_rsvpProvider.isRSVPd(event)) {
        event.rsvpd = true;
      } else {
        event.rsvpd = false;
      }
    }).toList();
  }
}
