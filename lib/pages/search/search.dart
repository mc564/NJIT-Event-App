import 'package:flutter/material.dart';
import '../../common/event_list_tile.dart';
import '../../blocs/search_bloc.dart';
import '../../blocs/favorite_bloc.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/edit_bloc.dart';

class SearchPage extends StatefulWidget {
  final EditEventBloc _editBloc;
  final SearchBloc _searchBloc;
  final FavoriteBloc _favoriteBloc;
  final EventBloc _eventBloc;
  final Function _canEdit;

  SearchPage(
      {@required SearchBloc searchBloc,
      @required FavoriteBloc favoriteBloc,
      @required EventBloc eventBloc,
      @required EditEventBloc editBloc,
      @required Function canEdit})
      : _searchBloc = searchBloc,
        _favoriteBloc = favoriteBloc,
        _eventBloc = eventBloc,
        _editBloc = editBloc,
        _canEdit = canEdit;

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SearchState>(
      stream: widget._searchBloc.searchQueries,
      initialData: widget._searchBloc.initialEventSearchState,
      builder: (BuildContext context, AsyncSnapshot<SearchState> snapshot) {
        SearchState state = snapshot.data;
        if (state is SearchError) {
          return Center(
              child: Text('Whoops, there was an error! Please try again! ☺️'));
        }
        SearchEventsResult searchResult = state;
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            backgroundColor: Color(0xffffff00),
            title: Row(
              children: <Widget>[
                Container(
                  width: 280.0,
                  height: 40,
                  margin: EdgeInsets.all(2),
                  decoration: new BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0xffDAA520),
                        offset: Offset(-2, 4),
                        blurRadius: 2.0,
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      widget._searchBloc.sink.add(SearchEvents(token: value));
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Events',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: searchResult.results.length == 0
                      ? Center(child: Text(searchResult.noResultsMessage))
                      : ListView.builder(
                          cacheExtent: 0,
                          shrinkWrap: true,
                          itemCount: searchResult.results.length,
                          itemBuilder: (context, index) {
                            return EventListTile(
                                event: searchResult.results[index],
                                color: 0xffFFFFFF,
                                favoriteBloc: widget._favoriteBloc,
                                eventBloc: widget._eventBloc,
                                editBloc: widget._editBloc,
                                canEdit: widget._canEdit);
                          }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
