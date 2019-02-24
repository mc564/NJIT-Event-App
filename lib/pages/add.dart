import 'package:flutter/material.dart';
import '../widgets/datetime_picker.dart';

import 'package:scoped_model/scoped_model.dart';
import '../scoped_models/events.dart';
import '../models/event.dart';
import 'package:uuid/uuid.dart';
import '../widgets/suggestion_dialog.dart';
import '../widgets/success_dialog.dart';

class AddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddPageState();
  }
}

class _AddPageState extends State<AddPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _formData = {
    'id': null,
    'location': null,
    'title': null,
    'startDateTime': null,
    'endDateTime': null,
    'organization': null,
    'description': null
  };

  void updateStartDate(DateTime date) {
    _formData['startDateTime'] = date;
  }

  void updateEndDate(DateTime date) {
    _formData['endDateTime'] = date;
  }

  TextFormField _buildTitleField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Event Title',
      ),
      validator: (String value) {
        if (value.isEmpty) return 'Title is required.';
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

  DateTimePicker _buildStartTimeField() {
    return DateTimePicker('Start Time: ', updateStartDate);
  }

  DateTimePicker _buildEndTimeField() {
    return DateTimePicker('End Time: ', updateEndDate);
  }

  TextFormField _buildDescriptionField() {
    return TextFormField(
      maxLines: 6,
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
      Event eventToAdd, List<Event> similarEvents, Function addEvent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuggestionDialog(
            event: eventToAdd,
            similarEvents: similarEvents,
            continuePrompt: "No, continue to add event",
            callback: (Event event) {
              addEvent(event);
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

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<EventsModel>(
        builder: (BuildContext context, Widget child, EventsModel model) {
      return model.isLoading
          ? Center(child: CircularProgressIndicator())
          : RaisedButton(
              child: Text('Add Event'),
              onPressed: () {
                if (!_formKey.currentState.validate()) {
                  return;
                }
                _formKey.currentState.save();

                Uuid idGen = Uuid();
                Event eventToAdd = Event(
                  eventId: idGen.v4(),
                  location: _formData['location'],
                  title: _formData['title'],
                  startTime: _formData['startDateTime'],
                  endTime: _formData['endDateTime'],
                  organization: _formData['organization'],
                  description: _formData['description'],
                );

                model
                    .getSimilarEvents(eventToAdd)
                    .then((List<Event> similarEvents) {
                  if (similarEvents.length > 0) {
                    _suggestEditingSimilarEvents(
                        eventToAdd, similarEvents, model.addEvent);
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        model.addEvent(eventToAdd);
                        return SuccessDialog("Event successfully added!");
                      },
                    );
                  }
                });
              },
            );
    });
  }

  Widget _buildAddForm(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTitleField(),
              SizedBox(height: 10.0),
              _buildOrganizationField(),
              SizedBox(height: 10.0),
              _buildLocationField(),
              SizedBox(height: 10.0),
              _buildDescriptionField(),
              _buildStartTimeField(),
              SizedBox(height: 10.0),
              _buildEndTimeField(),
              SizedBox(height: 10.0),
              _buildSubmitButton(),
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
      body: _buildAddForm(context),
    );
  }
}
