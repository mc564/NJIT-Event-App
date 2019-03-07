import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/event.dart';

enum Sort { Date, Relevance }
enum FilterType { Category, Location, Organization }

class FilterPage extends StatefulWidget {
  final Function _onSubmit;
  final List<String> _organizations;

  FilterPage({Function onSubmit, @required List<String> organizations})
      : _onSubmit = onSubmit,
        _organizations = organizations;

  @override
  State<StatefulWidget> createState() {
    return _FilterPageState();
  }
}

class _FilterPageState extends State<FilterPage> {
  List<Category> _selectedCategories;
  List<Location> _selectedLocations;
  List<String> _selectedOrganizations;
  Sort _sort;
  bool _locationPanelExpanded;
  bool _categoryPanelExpanded;
  String _prevOrgSearchToken;
  List<String> _orgSearchResults;
  String _quotes;

  List<Widget> _buildChipBox() {
    List<Widget> chipList = [];
    for (Category category in _selectedCategories) {
      chipList.add(
        Chip(
          label: Text(CategoryHelper.getString(category)),
          backgroundColor: Colors.yellow,
          deleteIconColor: Colors.cyan,
          onDeleted: () {
            setState(() {
              _selectedCategories.removeWhere((Category c) => c == category);
            });
          },
        ),
      );
    }
    for (Location location in _selectedLocations) {
      chipList.add(
        Chip(
          label: Text(LocationHelper.getLongName(location)),
          backgroundColor: Colors.cyan,
          deleteIconColor: Colors.yellow,
          onDeleted: () {
            setState(() {
              _selectedLocations.removeWhere((Location l) => l == location);
            });
          },
        ),
      );
    }

    for (String organization in _selectedOrganizations) {
      chipList.add(
        Chip(
          label: Text(organization),
          backgroundColor: Color(0xffFFB2FF),
          deleteIconColor: Colors.yellow,
          onDeleted: () {
            setState(() {
              _selectedOrganizations
                  .removeWhere((String o) => o == organization);
            });
          },
        ),
      );
    }

    if (chipList.length > 0) {
      chipList.add(
        FlatButton(
          color: Colors.white,
          textColor: Colors.blue,
          child: Text('clear all'),
          onPressed: () {
            setState(() {
              _selectedCategories = [];
              _selectedLocations = [];
              _selectedOrganizations = [];
            });
          },
        ),
      );
    }
    return chipList;
  }

  void _changeSearchList(String token) {
    _prevOrgSearchToken = token;
    if (token.isNotEmpty) {
      String tokenLower = token.toLowerCase();
      List<String> matchingOrgs = List<String>();
      for (String org in widget._organizations) {
        String orgLower = org.toLowerCase();
        if (orgLower.contains(tokenLower)) {
          matchingOrgs.add(org);
        }
      }
      setState(() {
        _orgSearchResults.clear();
        _orgSearchResults.addAll(matchingOrgs);
        _orgSearchResults.sort((String o1, String o2) => o1.compareTo(o2));
      });
    } else {
      setState(() {
        _orgSearchResults.clear();
      });
    }
  }

  Container _createOrganizationListTile(String organization) {
    return Container(
      height: 50,
      child: CheckboxListTile(
        value: _selectedOrganizations.contains(organization),
        title: Text(organization),
        onChanged: (checked) {
          setState(() {
            if (checked) {
              _selectedOrganizations.add(organization);
            } else {
              _selectedOrganizations
                  .removeWhere((String org) => org == organization);
            }
          });
        },
      ),
    );
  }

  FilterExpansionList _buildFilterExpansionList() {
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
      selectedCategories: _selectedCategories,
      selectedLocations: _selectedLocations,
      onCategoryFilterChanged: (List<Category> chosenCategories) {
        setState(() {
          _selectedCategories = chosenCategories;
        });
      },
      onLocationFilterChanged: (List<Location> chosenLocations) {
        setState(() {
          _selectedLocations = chosenLocations;
        });
      },
    );
  }

  Column _buildOrganizationSection() {
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
          onChanged: (value) {
            _changeSearchList(value);
          },
          decoration: InputDecoration(
            hintText: 'Search Organizations',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search),
          ),
        ),
        SizedBox(height: 10),
        _orgSearchResults.length == 0
            ? Text(
                'No results found for ${_prevOrgSearchToken.isEmpty ? _quotes : _prevOrgSearchToken}.')
            : Container(
                height: 300,
                child: Scrollbar(
                  child: ListView.builder(
                    cacheExtent: 0,
                    shrinkWrap: true,
                    itemCount: _orgSearchResults.length,
                    itemBuilder: (context, index) {
                      return _createOrganizationListTile(
                        _orgSearchResults[index],
                      );
                    },
                  ),
                ),
              ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedCategories = List<Category>.from(EventHelper.filterCategories);
    _selectedLocations = List<Location>.from(EventHelper.filterLocations);
    _selectedOrganizations = List<String>.from(EventHelper.filterOrganizations);
    _sort = EventHelper.sort;
    _locationPanelExpanded = false;
    _categoryPanelExpanded = false;
    _prevOrgSearchToken = '';
    _quotes = '""';
    _orgSearchResults = List<String>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text('Filter Results'),
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
          Builder(
            // Create an inner BuildContext so that the onPressed methods
            // can refer to the Scaffold with Scaffold.of().
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.check,
                  color: Colors.lightBlue[300],
                ),
                onPressed: () {
                  Map<FilterType, List<dynamic>> filterParams = {
                    FilterType.Category: _selectedCategories,
                    FilterType.Location: _selectedLocations,
                    FilterType.Organization: _selectedOrganizations,
                  };
                  //save filter results to event class
                  EventHelper.setFilterParameters(filterParams);
                  EventHelper.setSort(_sort);

                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Filtering events now!',
                      style: TextStyle(color: Colors.yellow),
                    ),
                    action: SnackBarAction(
                      label: 'DISMISS',
                      onPressed: () {
                        Scaffold.of(context).hideCurrentSnackBar();
                      },
                    ),
                    duration: Duration(seconds: 5),
                  ));
                  widget
                      ._onSubmit()
                      .then((bool success) => Navigator.of(context).pop());
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            Text('Sort By', style: TextStyle(fontSize: 20)),
            SizedBox(height: 5),
            RelevanceOrDateSortButton(
              onSortChanged: (Sort sortType) {
                _sort = sortType;
              },
            ),
            SizedBox(height: 10),
            Wrap(
              children: _buildChipBox(),
            ),
            SizedBox(height: 10),
            _buildFilterExpansionList(),
            SizedBox(height: 30),
            _buildOrganizationSection(),
          ],
        ),
      ),
    );
  }
}

class RelevanceOrDateSortButton extends StatefulWidget {
  final Function _onSortChanged;

  RelevanceOrDateSortButton({Function onSortChanged})
      : _onSortChanged = onSortChanged;

  @override
  State<StatefulWidget> createState() {
    return _RelevanceOrDateSortButtonState();
  }
}

class _RelevanceOrDateSortButtonState extends State<RelevanceOrDateSortButton> {
  bool _dateSortOrder = true;
  Color _dateButtonColor = Colors.blue;
  Color _dateTextColor = Colors.white;
  Color _relevanceButtonColor = Colors.white;
  Color _relevanceTextColor = Colors.blue;

  FlatButton _buildDateButton() {
    return FlatButton(
      child: Text('Date'),
      onPressed: () {
        if (_dateButtonColor == Colors.white) {
          setState(() {
            _dateSortOrder = true;
            widget._onSortChanged(Sort.Date);
            _relevanceButtonColor = Colors.white;
            _relevanceTextColor = Colors.blue;
            _dateButtonColor = Colors.blue;
            _dateTextColor = Colors.white;
          });
        }
      },
      padding: EdgeInsets.only(left: 75, right: 75),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(5.0),
          bottomRight: Radius.circular(5.0),
        ),
        side: BorderSide(
          color: Colors.blue,
        ),
      ),
      color: _dateButtonColor,
      textColor: _dateTextColor,
    );
  }

  FlatButton _buildRelevanceButton() {
    return FlatButton(
      child: Text('Relevance'),
      onPressed: () {
        if (_relevanceButtonColor == Colors.white) {
          setState(() {
            _dateSortOrder = false;
            widget._onSortChanged(Sort.Relevance);
            _relevanceButtonColor = Colors.blue;
            _relevanceTextColor = Colors.white;
            _dateButtonColor = Colors.white;
            _dateTextColor = Colors.blue;
          });
        }
      },
      padding: EdgeInsets.only(left: 62, right: 62),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5.0),
          bottomLeft: Radius.circular(5.0),
        ),
        side: BorderSide(
          color: Colors.blue,
        ),
      ),
      color: _relevanceButtonColor,
      textColor: _relevanceTextColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildRelevanceButton(),
        _buildDateButton(),
      ],
    );
  }
}

class FilterExpansionList extends StatelessWidget {
  final Function _onCategoryFilterChanged;
  final Function _onLocationFilterChanged;
  final Function _expansionCallback;
  final List<Category> _selectedCategories;
  final List<Location> _selectedLocations;
  final bool _categoriesExpanded;
  final bool _locsExpanded;

  FilterExpansionList({
    @required Function onCategoryFilterChanged,
    @required Function onLocationFilterChanged,
    @required Function expansionCallback,
    @required List<Category> selectedCategories,
    @required List<Location> selectedLocations,
    @required bool categoryPanelExpanded,
    @required bool locationPanelExpanded,
  })  : _onCategoryFilterChanged = onCategoryFilterChanged,
        _onLocationFilterChanged = onLocationFilterChanged,
        _expansionCallback = expansionCallback,
        _selectedCategories = selectedCategories,
        _selectedLocations = selectedLocations,
        _categoriesExpanded = categoryPanelExpanded,
        _locsExpanded = locationPanelExpanded;

  Container _createCategoryListTile(Category category) {
    return Container(
      height: 50,
      child: CheckboxListTile(
        value: _selectedCategories.contains(category),
        title: Text(CategoryHelper.getString(category)),
        onChanged: (checked) {
          if (checked) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.removeWhere((Category c) => c == category);
          }
          _onCategoryFilterChanged(_selectedCategories);
        },
      ),
    );
  }

  Column _createCategorySection() {
    List<Widget> categoryListTiles = List<Widget>();

    for (Category category in Category.values) {
      categoryListTiles.add(_createCategoryListTile(category));
    }
    return Column(children: categoryListTiles);
  }

  Container _createLocationListTile(Location location) {
    return Container(
      height: 50,
      child: CheckboxListTile(
        value: _selectedLocations.contains(location),
        title: Text(LocationHelper.getLongName(location)),
        onChanged: (checked) {
          if (checked) {
            _selectedLocations.add(location);
          } else {
            _selectedLocations.removeWhere((Location l) => l == location);
          }
          _onLocationFilterChanged(_selectedLocations);
        },
      ),
    );
  }

  Column _createLocationSection() {
    List<Widget> locationListTiles = List<Widget>();
    for (Location location in Location.values) {
      locationListTiles.add(_createLocationListTile(location));
    }
    return Column(children: locationListTiles);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool expanded) {
        _expansionCallback(index, expanded);
      },
      children: [
        ExpansionPanel(
          isExpanded: _categoriesExpanded,
          headerBuilder: (BuildContext context, bool expanded) {
            return Center(child: Text('Categories'));
          },
          body: _createCategorySection(),
        ),
        ExpansionPanel(
          isExpanded: _locsExpanded,
          headerBuilder: (BuildContext context, bool expanded) {
            return Center(child: Text('Locations'));
          },
          body: _createLocationSection(),
        ),
      ],
    );
  }
}
