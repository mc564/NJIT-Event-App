import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../providers/edit_event_provider.dart';

import '../models/event.dart';

import '../blocs/search_bloc.dart';
import '../blocs/favorite_bloc.dart';

//helps implement edit event form logic
class EditEventBloc {
  final StreamController<EditEvent> _requestsController;
  final StreamController<EditFormState> _formController;
  final EditEventProvider _editEventProvider;
  EditFormState _prevState;

  final StreamSink<SearchEvent> _searchSink;
  final StreamSink<FavoriteEvent> _favoriteSink;

  EditEventBloc(
      {@required StreamSink<SearchEvent> searchSink,
      @required StreamSink<FavoriteEvent> favoriteSink})
      : _editEventProvider = EditEventProvider(),
        _formController = StreamController.broadcast(),
        _requestsController = StreamController.broadcast(),
        _searchSink = searchSink,
        _favoriteSink = favoriteSink {
    _formController.stream.listen((EditFormState state) {
      _prevState = state;
    });
    _requestsController.stream.forEach((EditEvent event) {
      event.execute(this);
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
  StreamSink<EditEvent> get sink => _requestsController.sink;

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
        //TODO not sure if below reinitialization is necessary...test later
        _searchSink.add(ReinitializeForSearchingEvents());
        _favoriteSink.add(FetchFavorites());
      }
    } catch (error) {
      _alertFormSubmitErrorCustom(error);
    }
  }

  void dispose() {
    _formController.close();
    _requestsController.close();
  }
}

/*EDIT BLOC input EVENTS */
abstract class EditEvent extends Equatable {
  EditEvent([List args = const []]) : super(args);
  void execute(EditEventBloc editBloc);
}

class SetEventToEdit extends EditEvent {
  Event eventToEdit;
  SetEventToEdit(this.eventToEdit) : super([eventToEdit]);
  void execute(EditEventBloc editBloc) {
    editBloc.setEventToEdit(eventToEdit);
  }
}

class SetLocation extends EditEvent {
  String location;
  SetLocation(this.location) : super([location]);
  void execute(EditEventBloc editBloc) {
    editBloc.setLocation(location);
  }
}

class SetTitle extends EditEvent {
  String title;
  SetTitle(this.title) : super([title]);
  void execute(EditEventBloc editBloc) {
    editBloc.setTitle(title);
  }
}

class SetStartTime extends EditEvent {
  DateTime startTime;
  SetStartTime(this.startTime) : super([startTime]);
  void execute(EditEventBloc editBloc) {
    editBloc.setStartTime(startTime);
  }
}

class SetEndTime extends EditEvent {
  DateTime endTime;
  SetEndTime(this.endTime) : super([endTime]);
  void execute(EditEventBloc editBloc) {
    editBloc.setEndTime(endTime);
  }
}

class SetOrganization extends EditEvent {
  String organization;
  SetOrganization(this.organization) : super([organization]);
  void execute(EditEventBloc editBloc) {
    editBloc.setOrganization(organization);
  }
}

class SetDescription extends EditEvent {
  String description;
  SetDescription(this.description) : super([description]);
  void execute(EditEventBloc editBloc) {
    editBloc.setDescription(description);
  }
}

class SetCategory extends EditEvent {
  String category;
  SetCategory(this.category) : super([category]);
  void execute(EditEventBloc editBloc) {
    editBloc.setCategory(category);
  }
}

class SubmitForm extends EditEvent {
  void execute(EditEventBloc editBloc) {
    editBloc.submitForm();
  }
}

/* EDIT BLOC output STATES */
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
