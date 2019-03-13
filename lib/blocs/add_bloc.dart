import 'dart:async';
import '../providers/event_list_provider.dart';
import '../providers/add_event_provider.dart';
import '../models/event.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

//helps implement add event form logic
class AddEventBloc {
  final StreamController<AddFormState> _formController;
  final EventListProvider _eventListProvider;
  final AddEventProvider _addEventProvider;
  FormInitial _initialState;

  AddEventBloc({@required EventListProvider eventListProvider})
      : assert(eventListProvider != null),
        _eventListProvider = eventListProvider,
        _addEventProvider = AddEventProvider(),
        _formController = StreamController.broadcast() {
    print('in addbloc constructor!!');
    _initialState = FormInitial(
      description: _addEventProvider.description,
      title: _addEventProvider.title,
      organization: _addEventProvider.organization,
      category: _addEventProvider.category,
      endDateTime: _addEventProvider.endTime,
      startDateTime: _addEventProvider.startTime,
      location: _addEventProvider.location,
      titleValidator: _addEventProvider.titleValidator,
      locationValidator: _addEventProvider.locationValidator,
      descriptionValidator: _addEventProvider.descriptionValidator,
      organizationValidator: _addEventProvider.orgValidator,
      categoryValidator: _addEventProvider.categoryValidator,
    );
  }

  FormInitial get initialState => _initialState;

  Stream get formSubmissions => _formController.stream;

  void setLocation(String location) {
    _addEventProvider.setLocation(location);
  }

  void setTitle(String title) {
    _addEventProvider.setTitle(title);
  }

  void setStartTime(DateTime startDateTime) {
    _addEventProvider.setStartTime(startDateTime);
  }

  void setEndTime(DateTime endDateTime) {
    _addEventProvider.setEndTime(endDateTime);
  }

  void setOrganization(String org) {
    _addEventProvider.setOrganization(org);
  }

  void setDescription(String desc) {
    _addEventProvider.setDescription(desc);
  }

  void setCategory(String category) {
    _addEventProvider.setCategory(category);
  }

  void _alertFormSubmitting() {
    _formController.sink.add(FormSubmitting(
        description: _addEventProvider.description,
        title: _addEventProvider.title,
        organization: _addEventProvider.organization,
        category: _addEventProvider.category,
        endDateTime: _addEventProvider.endTime,
        startDateTime: _addEventProvider.startTime,
        location: _addEventProvider.location));
  }

  void _alertUserCanEditSimilarEvents(
      List<Event> similarEvents, Event eventToAdd) {
    _formController.sink.add(FormSubmitAlternative(
        editableSimilarEvents: similarEvents, eventToAdd: eventToAdd));
  }

  void _alertFormSubmitError() {
    _formController.sink.add(FormSubmitError(
        'Something went wrong adding the event to the database. Please try again!'));
  }

  void _alertFormSubmitErrorCustom(dynamic error) {
    _formController.sink.add(FormSubmitError(error.toString()));
  }

  void _alertFormSubmitted(Event eventToAdd) {
    _formController.sink.add(FormSubmitted(submittedEvent: eventToAdd));
  }

  void _alertFormReadyForNextSubmission() {
    //delay a little to give the ui time to react to the formsubmitted on the stream
    //then push the formready state to the stream to let the ui know the form is ready
    //for another submission
    Future.delayed(Duration(milliseconds: 100)).then((_) {
      _formController.sink.add(FormReady(
          description: _addEventProvider.description,
          title: _addEventProvider.title,
          organization: _addEventProvider.organization,
          category: _addEventProvider.category,
          endDateTime: _addEventProvider.endTime,
          startDateTime: _addEventProvider.startTime,
          location: _addEventProvider.location));
    });
  }

  //used after suggested to edit similar events instead of adding one
  //same as submitForm() except doesn't have suggestions
  void submitDespiteSuggestions(Event eventToAdd) async {
    try {
      _alertFormSubmitting();
      bool successfullyAdded = await _eventListProvider.addEvent(eventToAdd);
      if (!successfullyAdded) {
        _alertFormSubmitError();
      } else {
        _alertFormSubmitted(eventToAdd);
        _alertFormReadyForNextSubmission();
      }
    } catch (error) {
      _alertFormSubmitErrorCustom(error);
    }
  }

  void submitForm() async {
    try {
      _alertFormSubmitting();
      Event eventToAdd = _addEventProvider.getEventFromFormData();
      List<Event> similarEvents =
          await _eventListProvider.getSimilarEvents(eventToAdd);
      if (similarEvents.length > 0) {
        _alertUserCanEditSimilarEvents(similarEvents, eventToAdd);
      } else {
        bool successfullyAdded = await _eventListProvider.addEvent(eventToAdd);
        if (!successfullyAdded) {
          _alertFormSubmitError();
        } else {
          _alertFormSubmitted(eventToAdd);
          //TODO right now form doesn't clear on its own...figure out how to work with this
          _alertFormReadyForNextSubmission();
        }
      }
    } catch (error) {
      _alertFormSubmitErrorCustom(error);
    }
  }

  void dispose() {
    _formController.close();
  }
}

abstract class AddFormState extends Equatable {
  AddFormState([List args = const []]) : super(args);
}

//basically exists for the ui to tell the user there are events that exist that are editable and similar
class FormSubmitAlternative extends AddFormState {
  final Event eventToAdd;
  final List<Event> editableSimilarEvents;
  FormSubmitAlternative(
      {@required this.editableSimilarEvents, @required this.eventToAdd})
      : super([editableSimilarEvents, eventToAdd]);
}

class FormSubmitted extends AddFormState {
  final Event submittedEvent;
  FormSubmitted({@required this.submittedEvent}) : super([submittedEvent]);
}

class FormSubmitting extends AddFormState {
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

class FormSubmitError extends AddFormState {
  String error;
  FormSubmitError([this.error]);
}

//ready for next form submission
class FormReady extends AddFormState {
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

//has all validators for form setup
class FormInitial extends AddFormState {
  final String location;
  final String title;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String organization;
  final String description;
  final String category;
  final Function titleValidator;
  final Function organizationValidator;
  final Function locationValidator;
  final Function descriptionValidator;
  final Function categoryValidator;

  FormInitial({
    @required String location,
    @required String title,
    @required DateTime startDateTime,
    @required DateTime endDateTime,
    @required String organization,
    @required String description,
    @required String category,
    @required Function titleValidator,
    @required Function organizationValidator,
    @required Function locationValidator,
    @required Function descriptionValidator,
    @required Function categoryValidator,
  })  : location = location,
        title = title,
        startDateTime = startDateTime,
        endDateTime = endDateTime,
        organization = organization,
        description = description,
        category = category,
        titleValidator = titleValidator,
        organizationValidator = organizationValidator,
        locationValidator = locationValidator,
        descriptionValidator = descriptionValidator,
        categoryValidator = categoryValidator,
        super([
          location,
          title,
          startDateTime,
          endDateTime,
          organization,
          description,
          category,
          titleValidator,
          organizationValidator,
          locationValidator,
          descriptionValidator,
          categoryValidator,
        ]);
}
