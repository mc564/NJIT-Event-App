import 'package:flutter/material.dart';
import 'dart:async';

import '../../models/event.dart';

import '../../common/success_dialog.dart';
import '../../common/error_dialog.dart';
import '../../common/date_range_picker.dart';
import '../../common/drop_down_button_form_field.dart';

import '../../blocs/add_bloc.dart' as AddBloc;
import '../../blocs/edit_bloc.dart';

import '../../providers/event_list_provider.dart';
import '../../providers/organization/organization_provider.dart';

import './add_widgets.dart';

class AddPage extends StatefulWidget {
  final EditEventBloc _editBloc;
  final EventListProvider _eventListProvider;
  final OrganizationProvider _orgProvider;
  final String _ucid;
  final bool _isAdmin;

  AddPage(
      {@required EditEventBloc editBloc,
      @required EventListProvider eventListProvider,
      @required OrganizationProvider orgProvider,
      @required bool isAdmin,
      @required ucid})
      : _editBloc = editBloc,
        _eventListProvider = eventListProvider,
        _orgProvider = orgProvider,
        _isAdmin = isAdmin,
        _ucid = ucid;

  @override
  State<StatefulWidget> createState() {
    return _AddPageState();
  }
}

class _AddPageState extends State<AddPage> {
  GlobalKey<DateRangePickerState> _dateRangePickerKey;
  StreamSubscription _navigationListener;
  AddBloc.AddEventBloc _addEventBloc;
  GlobalKey<FormState> _formKey;
  List<DropdownMenuItem<String>> _categoryDropdownItems;
  List<DropdownMenuItem<String>> _organizationDropdownItems;

  TextFormField _buildTitleField() {
    String initVal = '';

    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Event Title',
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Color(0xffffdde2),
        border: InputBorder.none,
      ),
      validator: _addEventBloc.titleValidator,
      initialValue: initVal,
      onSaved: (String value) {
        print('title saved');
        _addEventBloc.sink.add(AddBloc.SetTitle(value));
      },
    );
  }

  Theme _buildOrganizationField() {
    return Theme(
      data: ThemeData(
        canvasColor: Color(0xffffffcc),
      ),
      child: DropDownButtonFormField(
        hint: 'Event Organization',
        items: _organizationDropdownItems,
        color: Color(0xffffffcc),
        textColor: Colors.black,
        onChanged: (String value) {},
        onSaved: (String value) {
          _addEventBloc.sink.add(AddBloc.SetOrganization(value));
        },
        validator: _addEventBloc.organizationValidator,
      ),
    );
  }

  TextFormField _buildLocationField() {
    String initVal = '';

    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Event Location',
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Color(0xffffffff),
        border: InputBorder.none,
      ),
      initialValue: initVal,
      validator: _addEventBloc.locationValidator,
      onSaved: (String value) {
        _addEventBloc.sink.add(AddBloc.SetLocation(value));
      },
    );
  }

  DateRangePicker _buildDateRangeField() {
    DateTime now = DateTime.now();
    DateTime startTime = now;
    DateTime endTime = now;

    return DateRangePicker(
      key: _dateRangePickerKey,
      initialStartTime: startTime,
      initialEndTime: endTime,
      onStartChanged: (DateTime start) {
        print('start time changed to: ' + start.toString());
        _addEventBloc.sink.add(AddBloc.SetStartTime(start));
      },
      onEndChanged: (DateTime end) {
        print('end time changed to :' + end.toString());
        _addEventBloc.sink.add(AddBloc.SetEndTime(end));
      },
    );
  }

  TextFormField _buildDescriptionField() {
    String initVal = '';
    return TextFormField(
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Event Description',
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Color(0xfff0f0f0),
        border: InputBorder.none,
      ),
      initialValue: initVal,
      validator: _addEventBloc.descriptionValidator,
      onSaved: (String value) {
        _addEventBloc.sink.add(AddBloc.SetDescription(value));
      },
    );
  }

  void _showErrorDialog(AddBloc.FormSubmitError errorObject) {
    String error = errorObject.error;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(errorMsg: error);
      },
    );
  }

  void _showSuccessDialog(Event addedEvent) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
            "Event successfully added!\n" + addedEvent.toString());
      },
    );
  }

  void _suggestEditingSimilarEvents(
      Event eventToAdd, List<Event> similarEvents) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuggestionDialog(
            editBloc: widget._editBloc,
            similarEvents: similarEvents,
            continuePrompt: "No, continue to add event",
            onSuggestionIgnored: () {
              _addEventBloc.sink.add(AddBloc.SubmitDespiteSuggestions(eventToAdd));
              Navigator.pop(context);
            });
      },
    );
  }

  Theme _buildCategoryField() {
    return Theme(
      data: ThemeData(
        canvasColor: Color(0xffdcf9ec),
      ),
      child: DropDownButtonFormField(
        hint: 'Event Category',
        items: _categoryDropdownItems,
        color: Color(0xffdcf9ec),
        textColor: Colors.black,
        onChanged: (String value) {},
        onSaved: (String value) {
          _addEventBloc.sink.add(AddBloc.SetCategory(value));
        },
        validator: _addEventBloc.categoryValidator,
      ),
    );
  }

  void _addEvent() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _addEventBloc.sink.add(AddBloc.SubmitForm());
    _formKey.currentState.reset();
    DateTime now = DateTime.now();
    _dateRangePickerKey.currentState.setStartAndEndTime(now, now);
  }

  Widget _buildSubmitButton() {
    return StreamBuilder<AddBloc.AddFormState>(
      stream: _addEventBloc.formSubmissions,
      initialData: _addEventBloc.initialState,
      builder: (BuildContext context, AsyncSnapshot<AddBloc.AddFormState> snapshot) {
        AddBloc.AddFormState state = snapshot.data;
        if (state is AddBloc.FormSubmitting) {
          return Center(child: CircularProgressIndicator());
        } else
          return RaisedButton(
              color: Color(0xffffdde2),
              splashColor: Color(0xffffdde2),
              child: Text('Add Event'),
              onPressed: () {
                _addEvent();
              });
      },
    );
  }

  GestureDetector _buildAddForm(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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

  String _cutShort(String s, int length) {
    if (s.length <= length)
      return s;
    else
      return s.substring(0, length + 1) + "...";
  }

  @override
  void initState() {
    super.initState();
    _dateRangePickerKey = GlobalKey<DateRangePickerState>();
    _addEventBloc = AddBloc.AddEventBloc(
        eventListProvider: widget._eventListProvider,
        orgProvider: widget._orgProvider,
        ucid: widget._ucid,
        isAdmin: widget._isAdmin,
        onInitialized: () {
          if (mounted) {
            setState(() {
              _organizationDropdownItems = List<DropdownMenuItem<String>>();
              _addEventBloc.allSelectableOrganizations
                  .forEach((String organization) {
                _organizationDropdownItems.add(
                  DropdownMenuItem(
                    value: organization,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        _cutShort(organization, 80),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              });
            });
          }
        });
    _formKey = GlobalKey<FormState>();
    _categoryDropdownItems = List<DropdownMenuItem<String>>();

    _addEventBloc.allSelectableCategories.forEach((String category) {
      _categoryDropdownItems.add(
        DropdownMenuItem(
          value: category,
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              category,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    });

    _organizationDropdownItems = List<DropdownMenuItem<String>>();

    _navigationListener = _addEventBloc.formSubmissions.listen((dynamic state) {
      if (state is AddBloc.FormSubmitAlternative) {
        _suggestEditingSimilarEvents(
            state.eventToAdd, state.editableSimilarEvents);
      } else if (state is AddBloc.FormSubmitError) {
        _showErrorDialog(state);
      } else if (state is AddBloc.FormSubmitted) {
        _showSuccessDialog(state.submittedEvent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.lightBlue[50],
        title: Text(
          'Add An Event',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _buildAddForm(context),
    );
  }

  @override
  void dispose() {
    _navigationListener.cancel();
    _addEventBloc.dispose();
    super.dispose();
  }
}