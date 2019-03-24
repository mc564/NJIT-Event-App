import 'package:flutter/material.dart';
import '../../blocs/favorite_bloc.dart';
import '../../blocs/event_bloc.dart';
import '../../models/event.dart';
import '../../common/error_dialog.dart';
import './favorites_widgets.dart';
import 'dart:async';

class FavoritesPage extends StatefulWidget {
  final FavoriteBloc _favoriteBloc;
  final EventBloc _eventBloc;

  FavoritesPage({@required FavoriteBloc favoriteBloc, @required EventBloc eventBloc})
      : _favoriteBloc = favoriteBloc,
      _eventBloc = eventBloc;
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

  TextStyle _accentTileTextStyle(Color color) {
    return TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 60,
      color: color,
    );
  }

  Widget _buildAccentTile1() {
    return Container(
      alignment: Alignment.centerRight,
      child: Text(
        'FAV',
        textAlign: TextAlign.right,
        style: _accentTileTextStyle(Color(0xff0200ff)),
      ),
      color: Color(0xffffff00),
    );
  }

  Widget _buildAccentTile2() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'ORI',
        textAlign: TextAlign.center,
        style: _accentTileTextStyle(Color(0xffff0700)),
      ),
      color: Color(0xff0200ff),
    );
  }

  Widget _buildAccentTile3() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        'TES',
        textAlign: TextAlign.left,
        style: _accentTileTextStyle(Color(0xffffff00)),
      ),
      color: Color(0xffff0700),
    );
  }

  Widget _buildAccentTile4() {
    return Container(
      color: Color(0xff02d100),
      alignment: Alignment.center,
      padding:EdgeInsets.all(10),
      child: Stack(children: <Widget>[
        Icon(Icons.check_circle, color:Colors.white),
        Text(
          '  means \nit\'s happening TODAY!!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ]),
    );
  }

  FavoriteGridTile _buildTile(Event event, int color) {
    return FavoriteGridTile(
        favoriteBloc: widget._favoriteBloc, event: event, color: color, eventBloc: widget._eventBloc);
  }

  List<Widget> _buildDynamicPortion(List<Event> favorites) {
    List<int> colors = [
      0xffffa500,
      0xffffff00,
      0xff0200ff,
      0xffff0700,
      0xff02d100,
    ];
    List<Widget> tiles = List<Widget>();
    if (favorites == null) return tiles;
    for (int i = 0; i < favorites.length; i++) {
      tiles.add(_buildTile(favorites[i], colors[i % colors.length]));
    }
    return tiles;
  }

  List<Widget> _buildChildren(List<Event> favorites) {
    List<Widget> list = List<Widget>();
    list.addAll(<Widget>[
      _buildAccentTile1(),
      _buildAccentTile2(),
      _buildAccentTile3(),
      _buildAccentTile4(),
    ]);
    list.addAll(_buildDynamicPortion(favorites));
    return list;
  }

  @override
  void initState() {
    super.initState();
    _errorListener = widget._favoriteBloc.favoriteSettingErrors.listen((error) {
      _showErrorDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Favorites',
          style: TextStyle(
              fontFamily: 'Libre-Baskerville', fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<FavoriteState>(
        stream: widget._favoriteBloc.favoriteRequests,
        initialData: widget._favoriteBloc.initialState,
        builder: (BuildContext context, AsyncSnapshot<FavoriteState> snapshot) {
          FavoriteState state = snapshot.data;
          List<Event> faves = List<Event>();
          if (state is FavoriteError) {
            if (state.rollbackFavorites != null &&
                state.rollbackFavorites.length > 0) {
              faves = state.rollbackFavorites;
            }
          } else if (state is FavoritesUpdated) {
            if (state.favorites != null && state.favorites.length > 0) {
              faves = state.favorites;
            }
          }
          return GridView.count(
            crossAxisCount: 3,
            children: _buildChildren(faves),
          );
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
