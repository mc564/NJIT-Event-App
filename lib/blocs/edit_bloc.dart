import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../providers/edit_event_provider.dart';

import '../models/event.dart';

//helps implement edit event form logic
class EditEventBloc {
  final StreamController<EditFormState> _formController;
  final EditEventProvider _editEventProvider;
  EditFormState _prevState;

  EditEventBloc({@required initialEventToEdit})
      : _editEventProvider = EditEventProvider(initialEventToEdit: initialEventToEdit),
        _formController = StreamController.broadcast() {
    _formController.stream.listen((EditFormState state) {
      _prevState = state;
    });
  }

  EditFormState get initialState => _prevState;
  Function get titleValidator => _editEventProvider.titleValidator;
  Function get descriptionValidator => _editEventProvider.descriptionValidator;
  Function get locationValidator => _editEventProvider.locationValidator;
  Function get organizationValidator => _editEventProvider.orgValidator;
  Function get categoryValidator => _editEventProvider.categoryValidator;
  List<String> get allSelectableCategories =>
      _editEventProvider.allSelectableCategories;

  Stream get formSubmissions => _formController.stream;

  void setEventToEdit(Event eventToEdit) {
    _editEventProvider.setEventToEdit(eventToEdit);
    _alertFormReadyForNextSubmission();
  }

  void setLocation(String location) {
    _editEventProvider.setLocation(location);
  }

  void setTitle(String title) {
    _editEventProvider.setTitle(title);
  }

  void setStartTime(DateTime startDateTime) {
    _editEventProvider.setStartTime(startDateTime);
  }

  void setEndTime(DateTime endDateTime) {
    _editEventProvider.setEndTime(endDateTime);
  }

  void setOrganization(String org) {
    _editEventProvider.setOrganization(org);
  }

  void setDescription(String desc) {
    _editEventProvider.setDescription(desc);
  }

  void setCategory(String category) {
    _editEventProvider.setCategory(category);
  }

  void _alertFormSubmitting() {
    _formController.sink.add(FormSubmitting(
        description: _editEventProvider.description,
        title: _editEventProvider.title,
        organization: _editEventProvider.organization,
        category: _editEventProvider.category,
        endDateTime: _editEventProvider.endTime,
        startDateTime: _editEventProvider.startTime,
        location: _editEventProvider.location));
  }

  void _alertFormSubmitError() {
    _formController.sink.add(FormSubmitError(
        'Something went wrong editing the event in the database. Please try again!'));
  }

  void _alertFormSubmitErrorCustom(dynamic error) {
    print(error.toString());
    _formController.sink.add(FormSubmitError(
        'Something went wrong editing the event in the database: ' +
            error.toString()));
  }

  void _alertFormSubmitted(Event eventToAdd) {
    _formController.sink.add(FormSubmitted(submittedEvent: eventToAdd));
  }

  void _alertFormReadyForNextSubmission() {
    _formController.sink.add(FormReady(
        description: _editEventProvider.description,
        title: _editEventProvider.title,
        organization: _editEventProvider.organization,
        category: _editEventProvider.category,
        endDateTime: _editEventProvider.endTime,
        startDateTime: _editEventProvider.startTime,
        location: _editEventProvider.location));
  }

  void submitForm() async {
    try {
      _alertFormSubmitting();
      Event editedEvent = _editEventProvider.getEventFromFormData();

      bool successfullyEdited = await _editEventProvider.editEvent(editedEvent);
      if (!successfullyEdited) {
        _alertFormSubmitError();
      } else {
        _alertFormSubmitted(editedEvent);
      }
    } catch (error) {
      _alertFormSubmitErrorCustom(error);
    }
  }

  void dispose() {
    _formController.close();
  }
}

abstract class EditFormState extends Equatable {
  EditFormState([List args = const []]) : super(args);
}

class FormSubmitted extends EditFormState {
  final Event submittedEvent;
  FormSubmitted({@required this.submittedEvent}) : super([submittedEvent]);
}

class FormSubmitting extends EditFormState {
  final String location;
  final String title;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String organization;
  final String description;
  final String category;
  FormSubmitting({
    @required String location,
    @required String title,
    @required DateTime startDateTime,
    @required DateTime endDateTime,
    @required String organization,
    @required String description,
    @required String category,
  })  : location = location,
        title = title,
        startDateTime = startDateTime,
        endDateTime = endDateTime,
        organization = organization,
        description = description,
        category = category,
        super([
          location,
          title,
          startDateTime,
          endDateTime,
          organization,
          description,
          category
        ]);
}

class FormSubmitError extends EditFormState {
  String error;
  FormSubmitError([this.error]);
}

//ready for next form submission
class FormReady extends EditFormState {
  final String location;
  final String title;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String organization;
  final String description;
  final String category;
  FormReady({
    @required String location,
    @required String title,
    @required DateTime startDateTime,
    @required DateTime endDateTime,
    @required String organization,
    @required String description,
    @required String category,
  })  : location = location,
        title = title,
        startDateTime = startDateTime,
        endDateTime = endDateTime,
        organization = organization,
        description = description,
        category = category,
        super([
          location,
          title,
          startDateTime,
          endDateTime,
          organization,
          description,
          category
        ]);
}
