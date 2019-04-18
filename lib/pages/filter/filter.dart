import 'package:flutter/material.dart';
import '../../blocs/filter_bloc.dart';
import '../../models/category.dart';
import '../../models/location.dart';
import '../../models/sort.dart';
import './filter_widgets.dart';
import '../../blocs/search_bloc.dart';
import '../../blocs/event_bloc.dart';

class FilterPage extends StatefulWidget {
  //fetchCachedEvents used to refresh events on the calendar page
  final EventBloc _eventBloc;
  final SearchBloc _searchBloc;
  final DateTime _viewDay;

  FilterPage(
      {@required EventBloc eventBloc,
      @required SearchBloc searchBloc,
      @required DateTime viewDay})
      : _eventBloc = eventBloc,
        _viewDay = viewDay,
        _searchBloc = searchBloc;

  @override
  State<StatefulWidget> createState() {
    return _FilterPageState();
  }
}

class _FilterPageState extends State<FilterPage> {
  FilterBloc _filterBloc;
  bool _locationPanelExpanded;
  bool _categoryPanelExpanded;

  List<Widget> _buildChipBox(FilterState state) {
    if (state is FiltersSelected) {
      List<Widget> chipList = [];

      for (Category category in state.selectedCategories) {
        chipList.add(
          Chip(
            label: Text(CategoryHelper.getString(category)),
            backgroundColor: Colors.yellow,
            deleteIconColor: Colors.cyan,
            onDeleted: () {
              _filterBloc.sink.add(RemoveCategory(category));
            },
          ),
        );
      }
      for (Location location in state.selectedLocations) {
        chipList.add(
          Chip(
            label: Text(LocationHelper.getLongName(location)),
            backgroundColor: Colors.cyan,
            deleteIconColor: Colors.yellow,
            onDeleted: () {
              _filterBloc.sink.add(RemoveLocation(location));
            },
          ),
        );
      }

      for (String organization in state.selectedOrganizations) {
        chipList.add(
          Chip(
            label: Text(organization),
            backgroundColor: Color(0xffFFB2FF),
            deleteIconColor: Colors.yellow,
            onDeleted: () {
              _filterBloc.sink.add(RemoveOrganization(organization));
            },
          ),
        );
      }

      if (chipList.length > 0) {
        chipList.insert( 0,
          FlatButton(
            color: Colors.white,
            textColor: Colors.blue,
            child: Text('clear all'),
            onPressed: () {
              _filterBloc.sink.add(ClearFilters());
            },
          ),
        );
      }
      return chipList;
    } else {
      return List<Widget>();
    }
  }

  Container _createOrganizationListTile(
      String organization, FiltersSelected filters) {
    return Container(
      height: 50,
      child: CheckboxListTile(
        value: filters.selectedOrganizations.contains(organization),
        title: Text(organization),
        onChanged: (checked) {
          if (checked) {
            _filterBloc.sink.add(AddOrganization(organization));
          } else {
            _filterBloc.sink.add(RemoveOrganization(organization));
          }
        },
      ),
    );
  }

  Widget _buildFilterExpansionList(FilterState state) {
    if (state is FilterError) {
      return Text('Hm, there was an error! Please try again! 😕');
    } else if (state is FiltersSelected) {
      FiltersSelected filters = state;
      return FilterExpansionList(
        locationPanelExpanded: _locationPanelExpanded,
        categoryPanelExpanded: _categoryPanelExpanded,
        expansionCallback: (int index, bool expanded) {
          setState(() {
            if (index == 0) {
              _categoryPanelExpanded = !_categoryPanelExpanded;
            } else if (index == 1) {
              _locationPanelExpanded = !_locationPanelExpanded;
            }
          });
        },
        selectedCategories: filters.selectedCategories,
        selectedLocations: filters.selectedLocations,
        onCategoryFilterChanged: (List<Category> chosenCategories) {
          _filterBloc.sink.add(SetCategories(chosenCategories));
        },
        onLocationFilterChanged: (List<Location> chosenLocations) {
          _filterBloc.sink.add(SetLocations(chosenLocations));
        },
      );
    } else if (state is FilterComplete) {
      return Container();
    } else {
      return Text(
          'There is a logic flaw in the program! Otherwise you wouldn\'t be here. uh oh, sorry man! 😑');
    }
  }

  Widget _buildOrganizationSection(FilterState state) {
    if (state is FilterError) {
      return Text('Hm, there was an error! Please try again! 😕');
    } else if (state is FiltersSelected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'Organizations',
            textAlign: TextAlign.left,
          ),
          SizedBox(height: 10),
          TextField(
            onChanged: (token) {
              widget._searchBloc.sink.add(SearchStrings(token: token));
            },
            decoration: InputDecoration(
              hintText: 'Search Organizations',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(height: 10),
          StreamBuilder<SearchState>(
            stream: widget._searchBloc.searchQueries,
            initialData: widget._searchBloc.initialStringSearchState,
            builder:
                (BuildContext context, AsyncSnapshot<SearchState> snapshot) {
              SearchState searchState = snapshot.data;
              if (searchState is SearchError) {
                return Text('Oh no, there was an error! Please try again!');
              }
              SearchStringsResult searchResult = searchState;
              if (searchResult.results.length == 0) {
                return Text(searchResult.noResultsMessage);
              }
              return Container(
                height: 300,
                child: Scrollbar(
                  child: ListView.builder(
                    cacheExtent: 0,
                    shrinkWrap: true,
                    itemCount: searchResult.results.length,
                    itemBuilder: (context, index) {
                      return _createOrganizationListTile(
                          searchResult.results[index], state);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      );
    } else if (state is FilterComplete) {
      return Container();
    } else {
      return Text('LOGIC ERROR beep beep BORP BORP LOGIC ERROR!!');
    }
  }

  Widget _buildRelevanceOrDateSortButton(FilterState state) {
    if (state is FilterError) {
      return Text('• Error! Error! •');
    } else if (state is FilterComplete) {
      return Center(child: Text('Filtering Complete! ☺'));
    } else if (state is FiltersSelected) {
      FiltersSelected selected = state;
      return RelevanceOrDateSortButton(
        initialSort: selected.sort,
        onSortChanged: (Sort sortType) {
          print('sort set is : ' + sortType.toString());
          _filterBloc.sink.add(SetSort(sortType));
        },
      );
    } else {
      return Text('how da heck did you get here');
    }
  }

  @override
  void initState() {
    super.initState();
    _filterBloc = FilterBloc(
        eventBlocSink: widget._eventBloc.sink,
        eventListProvider: widget._eventBloc.eventListProvider,
        day: widget._viewDay);
    _filterBloc.searchableOrganizations.then((List<String> orgs) {
      widget._searchBloc.sink.add(SetSearchableStrings(searchStrings: orgs));
    });
    _locationPanelExpanded = false;
    _categoryPanelExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FilterState>(
      stream: _filterBloc.filterProgress,
      initialData: _filterBloc.initialState,
      builder: (BuildContext context, AsyncSnapshot<FilterState> snapshot) {
        FilterState state = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            title: state is FilterComplete
                ? Center(
                    child: Text(
                      'Heading back in a second...',
                      style: TextStyle(fontSize: 17),
                    ),
                  )
                : Text('Filter Results'),
            backgroundColor: Colors.white,
            textTheme: TextTheme(
              title: TextStyle(
                color: Colors.black87,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
            elevation: 0,
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Colors.lightBlue[300],
                  ),
                  onPressed: () {
                    _filterBloc.sink.add(Filter());
                    Navigator.of(context).pop();
                  }),
            ],
          ),
          body: Container(
            margin: EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: state is FilterComplete
                      ? Text('')
                      : Text(
                          'Sort By',
                          style: TextStyle(fontSize: 20),
                        ),
                ),
                SizedBox(height: 5),
                _buildRelevanceOrDateSortButton(state),
                SizedBox(height: 5),
                Wrap(
                  children: _buildChipBox(state),
                ),
                SizedBox(height: 10),
                _buildFilterExpansionList(state),
                SizedBox(height: 30),
                _buildOrganizationSection(state),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _filterBloc.dispose();
    super.dispose();
  }
}
