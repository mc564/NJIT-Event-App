import 'package:flutter/material.dart';
import 'dart:async';

import '../../common/date_range_picker.dart';
import '../../common/drop_down_button_form_field.dart';
import '../../common/error_dialog.dart';
import '../../common/success_dialog.dart';

import '../../models/event.dart';
import '../../models/category.dart';

import '../../blocs/edit_bloc.dart';

class EditPage extends StatefulWidget {
  final Event _event;
  EditPage(this._event);

  @override
  State<StatefulWidget> createState() {
    return _EditPageState();
  }
}

class _EditPageState extends State<EditPage> {
  EditEventBloc _editEventBloc;
  StreamSubscription<EditFormState> _navigationListener;
  GlobalKey<FormState> _formKey;
  List<DropdownMenuItem<String>> _categoryDropdownItems;
  Event _currentlyEditing;

  TextFormField _buildTitleField() {
    return TextFormField(
        decoration: InputDecoration(
          labelText: 'Event Title',
          labelStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.pink[50],
          border: InputBorder.none,
        ),
        initialValue: _currentlyEditing.title,
        validator: _editEventBloc.titleValidator,
        onSaved: (String value) {
          _editEventBloc.setTitle(value);
        });
  }

  TextFormField _buildOrganizationField() {
    return TextFormField(
        style: TextStyle(color: Colors.black),
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Event Organization (Cannot be edited)',
          labelStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.pink[100],
          border: InputBorder.none,
        ),
        initialValue: _currentlyEditing.organization,
        validator: _editEventBloc.organizationValidator,
        onSaved: (String value) {
          _editEventBloc.setOrganization(value);
        });
  }

  DropDownButtonFormField _buildCategoryField() {
    return DropDownButtonFormField(
      hint: 'Event Category',
      items: _categoryDropdownItems,
      color: Colors.pink[200],
      textColor: Colors.black,
      initialValue: CategoryHelper.getString(_currentlyEditing.category),
      validator: _editEventBloc.categoryValidator,
      onSaved: (String value) {
        _editEventBloc.setCategory(value);
      },
    );
  }

  TextFormField _buildLocationField() {
    return TextFormField(
        decoration: InputDecoration(
          labelText: 'Event Location',
          labelStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.pink[50],
          border: InputBorder.none,
        ),
        initialValue: _currentlyEditing.location,
        validator: _editEventBloc.locationValidator,
        onSaved: (String value) {
          _editEventBloc.setLocation(value);
        });
  }

  TextFormField _buildDescriptionField() {
    return TextFormField(
        maxLines: 5,
        decoration: InputDecoration(
          labelText: 'Event Description',
          labelStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.pink[100],
          border: InputBorder.none,
        ),
        validator: _editEventBloc.descriptionValidator,
        initialValue: _currentlyEditing.description,
        onSaved: (String value) {
          _editEventBloc.setDescription(value);
        });
  }

  DateRangePicker _buildDateRangeField() {
    DateTime startTime = _currentlyEditing.startTime;
    DateTime endTime = _currentlyEditing.endTime;

    return DateRangePicker(
      initialStartTime: startTime,
      initialEndTime: endTime,
      onStartChanged: (DateTime start) {
        print('start time changed to: ' + start.toString());
        _editEventBloc.setStartTime(start);
      },
      onEndChanged: (DateTime end) {
        print('end time changed to :' + end.toString());
        _editEventBloc.setEndTime(end);
      },
    );
  }

  void _editEvent() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _editEventBloc.submitForm();
  }

  StreamBuilder _buildEditButton() {
    return StreamBuilder<EditFormState>(
      stream: _editEventBloc.formSubmissions,
      initialData: _editEventBloc.initialState,
      builder: (BuildContext context, AsyncSnapshot<EditFormState> snapshot) {
        EditFormState state = snapshot.data;
        if (state is FormSubmitting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return RaisedButton(
            child: Text('Edit Event'),
            color: Colors.pink[200],
            splashColor: Colors.pink[200],
            onPressed: () {
              _editEvent();
            },
          );
        }
      },
    );
  }

  GestureDetector _buildEditForm(BuildContext context) {
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
              _buildEditButton(),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(FormSubmitError errorObject) {
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
        return SuccessDialog("Event successfully edited! Updated event: \n" +
            addedEvent.toString());
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _currentlyEditing = widget._event;
    _formKey = GlobalKey<FormState>();
    _editEventBloc = EditEventBloc(initialEventToEdit: widget._event);
    _categoryDropdownItems = List<DropdownMenuItem<String>>();
    _editEventBloc.allSelectableCategories.forEach((String category) {
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

    _navigationListener =
        _editEventBloc.formSubmissions.listen((dynamic state) {
      if (state is FormSubmitError) {
        _showErrorDialog(state);
      } else if (state is FormSubmitted) {
        Event editedEvent = state.submittedEvent;
        _currentlyEditing = editedEvent;
        _showSuccessDialog(editedEvent);
        _editEventBloc.setEventToEdit(editedEvent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Page'),
        backgroundColor: Colors.pink[200],
      ),
      body: _buildEditForm(context),
    );
  }

  @override
  void dispose() {
    _editEventBloc.dispose();
    _navigationListener.cancel();
    super.dispose();
  }
}
