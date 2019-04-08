import 'dart:async';
import 'package:flutter/material.dart';
import '../../blocs/organization_bloc.dart';
import '../../models/organization.dart';
import '../../common/success_dialog.dart';
import '../../common/error_dialog.dart';

class ModifyDescriptionPage extends StatefulWidget {
  final OrganizationBloc _organizationBloc;
  final Organization _organization;

  ModifyDescriptionPage(
      {@required OrganizationBloc organizationBloc,
      @required Organization organization})
      : _organizationBloc = organizationBloc,
        _organization = organization;

  @override
  State<StatefulWidget> createState() {
    return _ModifyDescriptionPageState();
  }
}

class _ModifyDescriptionPageState extends State<ModifyDescriptionPage> {
  StreamSubscription _navigationListener;
  GlobalKey<FormState> _formKey;
  TextEditingController _textEditingController;

  void _alertErrorsWithDescription() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text('There are errors with your submission!'),
            content: Text('Please go back and try again!'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _textEditingController,
                  maxLines: null,
                  validator: widget._organizationBloc.descriptionValidator,
                  onSaved: (String value) {
                    widget._organizationBloc.sink.add(SetDescription(description: value));
                  },
                ),
                StreamBuilder<OrganizationState>(
                  initialData: widget._organizationBloc.updatingOrgInitialState,
                  stream: widget._organizationBloc.organizationUpdateRequests,
                  builder: (BuildContext context,
                      AsyncSnapshot<OrganizationState> snapshot) {
                    OrganizationState state = snapshot.data;
                    if (state is OrganizationUpdating) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return FlatButton(
                      color: Colors.black,
                      child: Text('Modify Description',
                          style: TextStyle(color: Color(0xffFFD700))),
                      onPressed: () {
                        if (!_formKey.currentState.validate()) {
                          _alertErrorsWithDescription();
                          return;
                        }
                        _formKey.currentState.save();
                        widget._organizationBloc.sink.add(SubmitOrganizationUpdates());
                        _formKey.currentState.reset();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _textEditingController =
        TextEditingController(text: widget._organization.description);
    widget._organizationBloc.sink.add(ClearStorage());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget._organizationBloc.sink.add(SetOrganizationToEdit(organization: widget._organization)));
    _navigationListener = widget._organizationBloc.organizationUpdateRequests
        .listen((dynamic state) {
      if (state is OrganizationUpdated) {
        widget._organization.setDescription(state.updatedOrganization.description);
        widget._organizationBloc.sink.add(SetOrganizationToEdit(organization: state.updatedOrganization));
        _textEditingController.text = state.updatedOrganization.description;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return SuccessDialog(
                'Your organization description update request has been successfully submitted! The updated description is as followed: [' +
                    state.updatedOrganization.description +
                    "]");
          },
        );
      } else if (state is OrganizationError) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(errorMsg: state.errorMsg);
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: 'Modify Description',
                  style: TextStyle(
                      fontFamily: 'Eutemia',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffFFD700))),
              TextSpan(text: '   Page'),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  @override
  void dispose() {
    _navigationListener.cancel();
    super.dispose();
  }
}
