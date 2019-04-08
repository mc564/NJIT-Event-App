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
  final EditEventBloc _editBloc;
  final Event _event;

  EditPage({@required Event event, @required EditEventBloc editBloc})
      : _event = event,
        _editBloc = editBloc;

  @override
  State<StatefulWidget> createState() {
    return _EditPageState();
  }
}

class _EditPageState extends State<EditPage> {
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
        validator: widget._editBloc.titleValidator,
        onSaved: (String value) {
          widget._editBloc.sink.add(SetTitle(value));
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
        validator: widget._editBloc.organizationValidator,
        onSaved: (String value) {
          widget._editBloc.sink.add(SetOrganization(value));
        });
  }

  DropDownButtonFormField _buildCategoryField() {
    return DropDownButtonFormField(
      hint: 'Event Category',
      items: _categoryDropdownItems,
      color: Colors.pink[200],
      textColor: Colors.black,
      initialValue: CategoryHelper.getString(_currentlyEditing.category),
      validator: widget._editBloc.categoryValidator,
      onSaved: (String value) {
        widget._editBloc.sink.add(SetCategory(value));
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
        validator: widget._editBloc.locationValidator,
        onSaved: (String value) {
          widget._editBloc.sink.add(SetLocation(value));
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
        validator: widget._editBloc.descriptionValidator,
        initialValue: _currentlyEditing.description,
        onSaved: (String value) {
          widget._editBloc.sink.add(SetDescription(value));
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
        widget._editBloc.sink.add(SetStartTime(start));
      },
      onEndChanged: (DateTime end) {
        print('end time changed to :' + end.toString());
        widget._editBloc.sink.add(SetEndTime(end));
      },
    );
  }

  void _editEvent() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    widget._editBloc.sink.add(SubmitForm());
  }

  StreamBuilder _buildEditButton() {
    return StreamBuilder<EditFormState>(
      stream: widget._editBloc.formSubmissions,
      initialData: widget._editBloc.initialState,
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
    _categoryDropdownItems = List<DropdownMenuItem<String>>();
    widget._editBloc.sink.add(SetEventToEdit(_currentlyEditing));
    widget._editBloc.allSelectableCategories.forEach((String category) {
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
        widget._editBloc.formSubmissions.listen((dynamic state) {
      if (state is FormSubmitError) {
        _showErrorDialog(state);
      } else if (state is FormSubmitted) {
        Event editedEvent = state.submittedEvent;
        _currentlyEditing = editedEvent;
        _showSuccessDialog(editedEvent);
        widget._editBloc.sink.add(SetEventToEdit(editedEvent));
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
    _navigationListener.cancel();
    super.dispose();
  }
}
