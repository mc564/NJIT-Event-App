import '../../models/category.dart';
import '../../models/location.dart';
import '../../models/sort.dart';
import 'package:flutter/material.dart';

class RelevanceOrDateSortButton extends StatefulWidget {
  final Function _onSortChanged;
  final Sort _initialSort;

  RelevanceOrDateSortButton(
      {Function onSortChanged, @required Sort initialSort})
      : _onSortChanged = onSortChanged,
        _initialSort = initialSort;

  @override
  State<StatefulWidget> createState() {
    return _RelevanceOrDateSortButtonState();
  }
}

class _RelevanceOrDateSortButtonState extends State<RelevanceOrDateSortButton> {
  Color _dateButtonColor;
  Color _dateTextColor;
  Color _relevanceButtonColor;
  Color _relevanceTextColor;

  _changeButtonColors(Sort sortType) {
    if (sortType == Sort.Date) {
      _relevanceButtonColor = Colors.white;
      _relevanceTextColor = Colors.blue;
      _dateButtonColor = Colors.blue;
      _dateTextColor = Colors.white;
    } else {
      _relevanceButtonColor = Colors.blue;
      _relevanceTextColor = Colors.white;
      _dateButtonColor = Colors.white;
      _dateTextColor = Colors.blue;
    }
  }

  _changeToDateSort() {
    widget._onSortChanged(Sort.Date);
    _changeButtonColors(Sort.Date);
  }

  _changeToRelevanceSort() {
    widget._onSortChanged(Sort.Relevance);
    _changeButtonColors(Sort.Relevance);
  }

  FlatButton _buildDateButton() {
    return FlatButton(
      child: Text('Date'),
      onPressed: () {
        if (_dateButtonColor == Colors.white) {
          setState(() {
            _changeToDateSort();
          });
        }
      },
      padding: EdgeInsets.only(left: 62, right: 62),
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
            _changeToRelevanceSort();
          });
        }
      },
      padding: EdgeInsets.only(left: 50, right: 50),
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
  void initState() {
    super.initState();
    if (widget._initialSort == Sort.Date) {
      _changeButtonColors(Sort.Date);
    } else {
      _changeButtonColors(Sort.Relevance);
    }
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
