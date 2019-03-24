import 'package:flutter/material.dart';
import 'dart:async';

import '../../models/event.dart';
import '../../models/category.dart';

import '../../common/suggestion_dialog.dart';
import '../../common/success_dialog.dart';
import '../../common/error_dialog.dart';
import './add_widgets.dart';

import '../../blocs/add_bloc.dart';
import '../../providers/event_list_provider.dart';

class AddPage extends StatefulWidget {
  final EventListProvider _eventListProvider;

  AddPage({@required EventListProvider eventListProvider})
      : _eventListProvider = eventListProvider;

  @override
  State<StatefulWidget> createState() {
    return _AddPageState();
  }
}

class _AddPageState extends State<AddPage> {
  StreamSubscription _navigationListener;
  AddEventBloc _addEventBloc;
  GlobalKey<FormState> _formKey;
  Function _titleValidator;
  Function _organizationValidator;
  Function _categoryValidator;
  Function _locationValidator;
  Function _descriptionValidator;
  List<DropdownMenuItem<String>> _dropdownItems;

  TextFormField _buildTitleField(AddFormState state) {
    String initVal = '';
    if (state is FormInitial) {
      initVal = state.title;
    } else if (state is FormSubmitting) {
      initVal = state.title;
    } else if (state is FormReady) {
      if (state.title == null) print('title is null');
      initVal = state.title;
    }
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Event Title',
        labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Color(0xffffff00),
        border: InputBorder.none,
      ),
      validator: _titleValidator,
      initialValue: initVal,
      onSaved: (String value) {
        _addEventBloc.setTitle(value);
      },
    );
  }

  TextFormField _buildOrganizationField(AddFormState state) {
    String initVal = '';
    if (state is FormInitial) {
      initVal = state.organization;
    } else if (state is FormSubmitting) {
      initVal = state.organization;
    } else if (state is FormReady) {
      initVal = state.organization;
    }
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Event Organization',
        labelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Color(0xff0200ff),
        border: InputBorder.none,
      ),
      initialValue: initVal,
      validator: _organizationValidator,
      onSaved: (String value) {
        _addEventBloc.setOrganization(value);
      },
    );
  }

  TextFormField _buildLocationField(AddFormState state) {
    String initVal = '';
    if (state is FormInitial) {
      initVal = state.location;
    } else if (state is FormSubmitting) {
      initVal = state.location;
    } else if (state is FormReady) {
      initVal = state.location;
    }
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Event Location',
        labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Color(0xff02d100),
        border: InputBorder.none,
      ),
      initialValue: initVal,
      validator: _locationValidator,
      onSaved: (String value) {
        _addEventBloc.setLocation(value);
      },
    );
  }

  DateRangePicker _buildDateRangeField(AddFormState formState) {
    DateTime startTime;
    DateTime endTime;

    if (formState is FormReady) {
      startTime = formState.startDateTime;
      endTime = formState.endDateTime;
    } else if (formState is FormSubmitting) {
      startTime = formState.startDateTime;
      endTime = formState.endDateTime;
    } else if (formState is FormInitial) {
      startTime = formState.startDateTime;
      endTime = formState.endDateTime;
    } else {
      //error, submitted, etc., so just show default date again
      DateTime now = DateTime.now();
      startTime = now;
      endTime = now;
    }

    return DateRangePicker(
      initialStartTime: startTime,
      initialEndTime: endTime,
      onStartChanged: (DateTime start) {
        print('start time changed to: ' + start.toString());
        _addEventBloc.setStartTime(start);
      },
      onEndChanged: (DateTime end) {
        print('end time changed to :' + end.toString());
        _addEventBloc.setEndTime(end);
      },
    );
  }

  TextFormField _buildDescriptionField(AddFormState state) {
    String initVal = '';
    if (state is FormInitial) {
      initVal = state.description;
    } else if (state is FormSubmitting) {
      initVal = state.description;
    } else if (state is FormReady) {
      initVal = state.description;
    }
    return TextFormField(
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Event Description',
        labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600),
        filled: true,
        fillColor: Color(0xffffa500),
        border: InputBorder.none,
      ),
      initialValue: initVal,
      validator: _descriptionValidator,
      onSaved: (String value) {
        _addEventBloc.setDescription(value);
      },
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog("Event successfully added!");
      },
    );
  }

  void _suggestEditingSimilarEvents(
      Event eventToAdd, List<Event> similarEvents) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuggestionDialog(
            similarEvents: similarEvents,
            continuePrompt: "No, continue to add event",
            onSuggestionIgnored: () {
              _addEventBloc.submitDespiteSuggestions(eventToAdd);
              Navigator.pop(context);
            });
      },
    );
  }

  DropDownButtonFormField _buildCategoryField(AddFormState state) {
    String initVal = '';
    if (state is FormInitial) {
      initVal = state.category;
    } else if (state is FormSubmitting) {
      initVal = state.category;
    } else if (state is FormReady) {
      initVal = state.category;
    }

    return DropDownButtonFormField(
      hint: 'Event Category',
      items: _dropdownItems,
      initialValue: initVal,
      onChanged: (String value) {},
      onSaved: (String value) {
        _addEventBloc.setCategory(value);
      },
      validator: _categoryValidator,
    );
  }

  void _addEvent() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    _addEventBloc.submitForm();
  }

  Widget _buildSubmitButton(AddFormState state) {
    if (state is FormSubmitting) {
      return Center(child: CircularProgressIndicator());
    } else
      return RaisedButton(
          child: Text('Add Event'),
          onPressed: () {
            _addEvent();
          });
  }

  StreamBuilder _buildAddForm(BuildContext context) {
    return StreamBuilder<AddFormState>(
      stream: _addEventBloc.formSubmissions,
      initialData: _addEventBloc.initialState,
      builder: (BuildContext context, AsyncSnapshot<AddFormState> snapshot) {
        print('state added to stream: ' + snapshot.data.runtimeType.toString());
        AddFormState state = snapshot.data;

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
                  _buildTitleField(state),
                  SizedBox(height: 10.0),
                  _buildOrganizationField(state),
                  SizedBox(height: 10.0),
                  _buildCategoryField(state),
                  SizedBox(height: 10.0),
                  _buildLocationField(state),
                  SizedBox(height: 10.0),
                  _buildDescriptionField(state),
                  _buildDateRangeField(state),
                  SizedBox(height: 10.0),
                  _buildSubmitButton(state),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _addEventBloc = AddEventBloc(eventListProvider: widget._eventListProvider);
    _formKey = GlobalKey<FormState>();
    FormInitial initialState = _addEventBloc.initialState;
    _categoryValidator = initialState.categoryValidator;
    _locationValidator = initialState.locationValidator;
    _descriptionValidator = initialState.descriptionValidator;
    _titleValidator = initialState.titleValidator;
    _organizationValidator = initialState.organizationValidator;
    _dropdownItems = List<DropdownMenuItem<String>>();
    CategoryHelper.categoryFrom.forEach(
      (String string, Category category) {
        _dropdownItems.add(
          DropdownMenuItem(
            value: string,
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                string,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
    _navigationListener = _addEventBloc.formSubmissions.listen((dynamic state) {
      if (state is FormSubmitAlternative) {
        _suggestEditingSimilarEvents(
            state.eventToAdd, state.editableSimilarEvents);
      } else if (state is FormSubmitError) {
        _showErrorDialog(state);
      } else if (state is FormSubmitted) {
        _showSuccessDialog();
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
        backgroundColor: Colors.white,
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
