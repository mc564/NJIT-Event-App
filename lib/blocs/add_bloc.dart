import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../providers/event_list_provider.dart';
import '../providers/add_event_provider.dart';
import '../providers/organization_provider.dart';

import '../models/event.dart';
import '../models/organization.dart';

//helps implement add event form logic
class AddEventBloc {
  final StreamController<AddFormState> _formController;
  final EventListProvider _eventListProvider;
  final OrganizationProvider _orgProvider;
  final AddEventProvider _addEventProvider;
  FormReady _initialState;
  final bool _isAdmin;
  final String _ucid;
  List<String> _editableOrganizations;

  AddEventBloc(
      {@required String ucid,
      @required EventListProvider eventListProvider,
      @required OrganizationProvider orgProvider,
      @required bool isAdmin,
      @required Function onInitialized})
      : _eventListProvider = eventListProvider,
        _orgProvider = orgProvider,
        _isAdmin = isAdmin,
        _ucid = ucid,
        _addEventProvider = AddEventProvider(),
        _formController = StreamController.broadcast() {
    _initialState = FormReady(
      description: _addEventProvider.description,
      title: _addEventProvider.title,
      organization: _addEventProvider.organization,
      category: _addEventProvider.category,
      endDateTime: _addEventProvider.endTime,
      startDateTime: _addEventProvider.startTime,
      location: _addEventProvider.location,
    );
    //on initialized to let the page know it can get the editable organizations now
    getEditableOrganizations().then((List<String> editableOrgs) {
      _editableOrganizations = editableOrgs;
      onInitialized();
    });
  }

  FormReady get initialState => _initialState;
  Function get titleValidator => _addEventProvider.titleValidator;
  Function get locationValidator => _addEventProvider.locationValidator;
  Function get descriptionValidator => _addEventProvider.descriptionValidator;
  Function get organizationValidator => _addEventProvider.orgValidator;
  Function get categoryValidator => _addEventProvider.categoryValidator;
  List<String> get allSelectableCategories =>
      _addEventProvider.allSelectableCategories;
  List<String> get allSelectableOrganizations => _editableOrganizations;

  Stream get formSubmissions => _formController.stream;

  //for events they can actually EDIT: only the ones that have orgs. that are signed up & active on the app
  //and also (if not admin) only the ones with orgs. they are on the eboard for
  Future<List<String>> getEditableOrganizations() async {
    List<String> editableOrgs = List<String>();
    List<Organization> viewableOrgs = await _orgProvider.allViewableOrganizations();
    if (_isAdmin) {
      for (Organization org in viewableOrgs) {
        editableOrgs.add(org.name);
      }
      return editableOrgs;
    }
    //remove all the ones that the user doesn't have e-board or event editing rights for
    viewableOrgs.removeWhere((Organization org) {
      for (OrganizationMember member in org.eBoardMembers) {
        if (member.ucid == _ucid) {
          return false;
        }
      }
      return true;
    });
    for (Organization org in viewableOrgs) {
      editableOrgs.add(org.name);
    }
    return editableOrgs;
  }

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
      _addEventProvider.clear();
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

  //filter for events that are made by the 'editableOrganizations'
  void _filterUserEditableSimilarEvents(List<Event> similarEvents) {
    similarEvents.removeWhere((Event event) {
      //remove if event's org is not in editableOrgs
      if (!_editableOrganizations.contains(event.organization)) return true;
      return false;
    });
  }

  void submitForm() async {
    try {
      Event eventToAdd = _addEventProvider.getEventFromFormData();
      _addEventProvider.clear();
      _alertFormSubmitting();
      List<Event> similarEvents =
          await _eventListProvider.getSimilarEvents(eventToAdd);
      _filterUserEditableSimilarEvents(similarEvents);
      if (similarEvents.length > 0) {
        _alertUserCanEditSimilarEvents(similarEvents, eventToAdd);
      } else {
        bool successfullyAdded = await _eventListProvider.addEvent(eventToAdd);
        if (!successfullyAdded) {
          _alertFormSubmitError();
        } else {
          _alertFormSubmitted(eventToAdd);
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
