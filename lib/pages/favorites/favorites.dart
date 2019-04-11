import 'package:flutter/material.dart';
import '../../blocs/favorite_bloc.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/edit_bloc.dart';
import '../../models/event.dart';
import '../../common/error_dialog.dart';
import './favorites_widgets.dart';
import 'dart:async';

class FavoritesPage extends StatefulWidget {
  final EditEventBloc _editBloc;
  final FavoriteBloc _favoriteBloc;
  final EventBloc _eventBloc;
  final Function _canEditEvent;

  FavoritesPage(
      {@required EditEventBloc editBloc,
      @required FavoriteBloc favoriteBloc,
      @required EventBloc eventBloc,
      @required Function canEditEvent})
      : _editBloc = editBloc,
        _favoriteBloc = favoriteBloc,
        _eventBloc = eventBloc,
        _canEditEvent = canEditEvent;

  @override
  State<StatefulWidget> createState() {
    return _FavoritesPageState();
  }
}

class _FavoritesPageState extends State<FavoritesPage> {
  StreamSubscription _errorListener;

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

  FavoriteGridTile _buildTile(Event event, int color) {
    return FavoriteGridTile(
      editBloc: widget._editBloc,
      favoriteBloc: widget._favoriteBloc,
      eventBloc: widget._eventBloc,
      event: event,
      color: color,
      canEditEvent: widget._canEditEvent,
    );
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
    //TODO 1 tile to delete all favorites or past favorites for now
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
                    () => widget._favoriteBloc.sink.add(
                          RemoveAllFavorites(),
                        ),
                  ),
            ),
            FlatButton(
              child: Text('Delete Past Favorites'),
              color: Color(0xffFFFFCC),
              onPressed: () => _showAreYouSureDialog(
                    'Are you sure you want to delete ALL favorites for PAST events?',
                    () => widget._favoriteBloc.sink.add(
                          RemovePastFavorites(),
                        ),
                  ),
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

  @override
  void initState() {
    super.initState();
    _errorListener = widget._favoriteBloc.favoriteSettingErrors.listen((error) {
      if(error is FavoriteError){
        print("generic error: "+error.errorMsg);
      }else if(error is FavoriteSettingError){
        print("setting error: "+error.errorMsg);
      }
      _showErrorDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.lightBlue[50],
        centerTitle: true,
        title: Text(
          'Favorites',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder<FavoriteState>(
        stream: widget._favoriteBloc.favoriteRequests,
        initialData: widget._favoriteBloc.initialState,
        builder: (BuildContext context, AsyncSnapshot<FavoriteState> snapshot) {
          FavoriteState state = snapshot.data;
          List<Event> faves = List<Event>();
          if (state is FavoriteSettingError) {
            if (state.rollbackFavorites != null &&
                state.rollbackFavorites.length > 0) {
              faves = state.rollbackFavorites;
            }
          } else if (state is FavoritesUpdated) {
            if (state.favorites != null && state.favorites.length > 0) {
              faves = state.favorites;
            }
          }
          return ListView(children: _buildChildren(faves));
        },
      ),
    );
  }

  @override
  void dispose() {
    _errorListener.cancel();
    super.dispose();
  }
}
