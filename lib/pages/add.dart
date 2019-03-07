import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import '../models/event.dart';
import '../models/category.dart';
import '../models/location.dart';

import '../widgets/suggestion_dialog.dart';
import '../widgets/success_dialog.dart';
import '../widgets/error_dialog.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/dropdown_button.dart';

class AddPage extends StatefulWidget {
  final Function _getSimilarEvents;
  final Function _addEvent;

  AddPage({Function getSimilarEvents, Function addEvent})
      : _getSimilarEvents = getSimilarEvents,
        _addEvent = addEvent;

  @override
  State<StatefulWidget> createState() {
    return _AddPageState();
  }
}

class _AddPageState extends State<AddPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _submittingForm = false;

  Map<String, dynamic> _formData = {
    'id': null,
    'location': null,
    'title': null,
    'startDateTime': null,
    'endDateTime': null,
    'organization': null,
    'description': null,
    'category': null,
  };

  TextFormField _buildTitleField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Event Title',
      ),
      validator: (String value) {
        if (value.isEmpty) return 'Title is required.';
      },
      onFieldSubmitted: (String value) {
        print("field submitted: " + value);
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  TextFormField _buildOrganizationField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Event Organization',
      ),
      validator: (String value) {
        if (value.isEmpty) return 'Organization is required.';
      },
      onSaved: (String value) {
        _formData['organization'] = value;
      },
    );
  }

  TextFormField _buildLocationField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Event Location',
      ),
      validator: (String value) {
        if (value.isEmpty) return 'Location is required.';
      },
      onSaved: (String value) {
        _formData['location'] = value;
      },
    );
  }

  DateRangePicker _buildDateRangeField() {
    if (_formData['startDateTime'] == null ||
        _formData['endDateTime'] == null) {
      DateTime initial = DateTime.now();
      _formData['startDateTime'] = initial;
      _formData['endDateTime'] = initial;
    }

    return DateRangePicker(
      initialStartTime: _formData['startDateTime'],
      initialEndTime: _formData['endDateTime'],
      onStartChanged: (DateTime start) {
        print('editing start');
        _formData['startDateTime'] = start;
      },
      onEndChanged: (DateTime end) {
        print('editing end');
        _formData['endDateTime'] = end;
      },
    );
  }

  TextFormField _buildDescriptionField() {
    return TextFormField(
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Event Description',
      ),
      validator: (String value) {
        if (value.isEmpty) return 'Description is required.';
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  void _suggestEditingSimilarEvents(
      Event eventToAdd, List<Event> similarEvents) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuggestionDialog(
            event: eventToAdd,
            similarEvents: similarEvents,
            continuePrompt: "No, continue to add event",
            callback: (Event event) {
              widget._addEvent(event);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return SuccessDialog("Event successfully added!");
                  },
                ),
              );
            });
      },
    );
  }

  DropDownButtonFormField _buildCategoryField() {
    List<DropdownMenuItem<String>> dropdownItems =
        List<DropdownMenuItem<String>>();
    CategoryHelper.categoryFrom.forEach((String string, Category category) {
      dropdownItems.add(DropdownMenuItem(value: string, child: Text(string)));
    });

    return DropDownButtonFormField(
      hint: '[ Event Category ]',
      items: dropdownItems,
      onChanged: (String value) {},
      onSaved: (String value) {
        _formData['category'] = value;
      },
      validator: (String value) {
        if (value == null || value.isEmpty) return 'Category is required.';
      },
    );
  }

  void _addEvent() {
    print("RUNNING _addEvent");

    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    setState(() {
      _submittingForm = true;
    });

    Uuid idGen = Uuid();

    Event eventToAdd = Event(
      eventId: idGen.v4(),
      location: _formData['location'],
      title: _formData['title'],
      startTime: _formData['startDateTime'],
      endTime: _formData['endDateTime'],
      organization: _formData['organization'],
      description: _formData['description'],
      category: CategoryHelper.getCategory(_formData['category']),
      locationCode: LocationHelper.getLocationCode(_formData['location']),
    );

    widget._getSimilarEvents(eventToAdd).then((List<Event> similarEvents) {
      if (similarEvents.length > 0) {
        _suggestEditingSimilarEvents(eventToAdd, similarEvents);
        setState(() {
          _submittingForm = false;
        });
      } else {
        widget._addEvent(eventToAdd).then((bool success) {
          if (success) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SuccessDialog("Event successfully added!");
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog();
              },
            );
          }
          setState(() {
            _submittingForm = false;
          });
        });
      }
    });
  }

  Widget _buildSubmitButton() {
    return _submittingForm
        ? Center(child: CircularProgressIndicator())
        : RaisedButton(
            child: Text('Add Event'),
            onPressed: () {
              _addEvent();
            });
  }

  GestureDetector _buildAddForm() {
    print("building add form!");
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildTitleField(),
              SizedBox(height: 10.0),
              _buildOrganizationField(),
              SizedBox(height: 10.0),
              _buildCategoryField(),
              SizedBox(height: 10.0),
              _buildLocationField(),
              SizedBox(height: 10.0),
              _buildDescriptionField(),
              _buildDateRangeField(),
              SizedBox(height: 10.0),
              _buildSubmitButton(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add An Event'),
      ),
      body: _buildAddForm(),
    );
  }
}
