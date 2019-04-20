import 'package:flutter/material.dart';
import '../../blocs/favorite_bloc.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/edit_bloc.dart';
import '../../blocs/favorite_rsvp_bloc.dart';
import '../../models/event.dart';
import '../../common/error_dialog.dart';
import '../../common/event_list_tile.dart';
import '../../common/loading_squirrel.dart';
import 'dart:async';

class FavoritesPage extends StatefulWidget {
  final EditEventBloc _editBloc;
  final FavoriteAndRSVPBloc _favoriteAndRSVPBloc;
  final EventBloc _eventBloc;
  final Function _canEditEvent;

  FavoritesPage(
      {@required EditEventBloc editBloc,
      @required FavoriteAndRSVPBloc favoriteAndRSVPBloc,
      @required EventBloc eventBloc,
      @required Function canEditEvent})
      : _editBloc = editBloc,
        _favoriteAndRSVPBloc = favoriteAndRSVPBloc,
        _eventBloc = eventBloc,
        _canEditEvent = canEditEvent;

  @override
  State<StatefulWidget> createState() {
    return _FavoritesPageState();
  }
}

class _FavoritesPageState extends State<FavoritesPage> {
  StreamSubscription _errorListener;
  List<Event> _faves;
  bool _isLoading;

  void _setupTempListenerForResetFavorites() {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    StreamSubscription<FavoriteState> tempListener;
    tempListener = widget._favoriteAndRSVPBloc.favoriteBloc.favoriteRequests
        .listen((dynamic state) {
      if (state is FavoritesUpdated) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _faves = state.favorites;
          });
        }

        tempListener.cancel();
      } else if (state is FavoriteError) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        tempListener.cancel();
      }
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => ErrorDialog(
          errorMsg:
              'There was an error setting favorites. Didn\'t implement changes!'),
    );
  }

  void _showAreYouSureDialog(String message, Function onConfirm) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('RETURN'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text('CONTINUE'),
                onPressed: () {
                  onConfirm();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget _buildBaseTile(Event event, int color) {
    return EventListTileBasicAbbrevStyle(
      editBloc: widget._editBloc,
      favoriteAndRSVPBloc: widget._favoriteAndRSVPBloc,
      eventBloc: widget._eventBloc,
      event: event,
      color: color,
      canEditEvent: widget._canEditEvent,
      onFavorited: (_) {},
      onUnfavorited: (Event unfavoritedEvent) {
        if (mounted) {
          setState(() {
            _faves.removeWhere(
                (Event e) => e.eventId == unfavoritedEvent.eventId);
          });
        }
      },
    );
  }

  Dismissible _buildTile(Event event, int color) {
    return Dismissible(
        key: Key(DateTime.now().toString()),
        onDismissed: (DismissDirection direction) {
          widget._favoriteAndRSVPBloc.favoriteBloc.sink
              .add(RemoveFavorite(eventToUnfavorite: event));
          if (mounted) {
            setState(() {
              _faves.removeWhere((Event e) => event.eventId == e.eventId);
            });
          }
        },
        background: Container(
            color: Colors.red,
            padding: EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Remove Favorite ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.delete, color: Colors.white),
              ],
            )),
        child: _buildBaseTile(event, color));
  }

  Container _noFavoritesTile() {
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Text(
        'No Favorites For Now! 🙂',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }

  List<Widget> _buildActionTiles() {
    List<Widget> list = List<Widget>();
    list.add(
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              child: Text('Delete All Favorites'),
              color: Color(0xffffdde2),
              onPressed: () => _showAreYouSureDialog(
                    'Are you sure you want to delete ALL your favorites?',
                    () {
                      widget._favoriteAndRSVPBloc.favoriteBloc.sink.add(
                        RemoveAllFavorites(),
                      );
                      _setupTempListenerForResetFavorites();
                    },
                  ),
            ),
            FlatButton(
              child: Text('Delete Past Favorites'),
              color: Color(0xffFFFFCC),
              onPressed: () => _showAreYouSureDialog(
                      'Are you sure you want to delete ALL favorites for PAST events?',
                      () {
                    widget._favoriteAndRSVPBloc.favoriteBloc.sink
                        .add(RemovePastFavorites());
                    _setupTempListenerForResetFavorites();
                  }),
            ),
          ],
        ),
      ),
    );
    return list;
  }

  List<Widget> _buildDynamicPortion(List<Event> favorites) {
    //this is for the favorites
    List<int> colors = [
      0xffffdde2,
      0xffFFFFCC,
      0xffdcf9ec,
      0xffFFFFFF,
      0xffF0F0F0,
    ];
    List<Widget> lst = List<Widget>();

    //empty list
    if (favorites == null || favorites.length == 0) {
      lst.add(_noFavoritesTile());
      return lst;
    }
    //build the list with favorites
    for (int i = 0; i < favorites.length; i++) {
      lst.add(_buildTile(favorites[i], colors[i % colors.length]));
    }
    return lst;
  }

  List<Widget> _buildChildren(List<Event> favorites) {
    List<Widget> list = List<Widget>();
    list.addAll(_buildActionTiles());
    list.addAll(_buildDynamicPortion(favorites));
    return list;
  }

  Widget _buildBody() {
    //don't use a streamBuilder here because if a user keeps on swiping to delete, I want to use optimistic updating
    //instead of loading stale data
    if (_isLoading) return LoadingSquirrel();
    return ListView(children: _buildChildren(_faves));
  }

  @override
  void initState() {
    super.initState();
    _errorListener = widget
        ._favoriteAndRSVPBloc.favoriteBloc.favoriteSettingErrors
        .listen((error) {
      if (error is FavoriteError) {
        print("generic error: " + error.errorMsg);
      } else if (error is FavoriteSettingError) {
        print("setting error: " + error.errorMsg);
      }
      _showErrorDialog();
    });
    _faves = List<Event>();
    FavoriteState state = widget._favoriteAndRSVPBloc.favoriteBloc.initialState;
    if (state is FavoriteSettingError) {
      if (state.rollbackFavorites != null &&
          state.rollbackFavorites.length > 0) {
        _faves = state.rollbackFavorites;
      }
    } else if (state is FavoritesUpdated) {
      if (state.favorites != null && state.favorites.length > 0) {
        _faves = state.favorites;
      }
    }
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.lightBlue[50],
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Favorites',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                widget._favoriteAndRSVPBloc.favoriteBloc.sink.add(
                  FetchFavorites(),
                );
                _setupTempListenerForResetFavorites();
              },
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  @override
  void dispose() {
    _errorListener.cancel();
    super.dispose();
  }
}
