import 'dart:async';
import 'package:flutter/material.dart';
import './organization_widgets.dart';
import '../../blocs/organization_bloc.dart';
import '../../models/organization.dart';
import '../../common/success_dialog.dart';
import '../../common/error_dialog.dart';

class RegisterOrganizationPage extends StatefulWidget {
  final OrganizationBloc _organizationBloc;

  RegisterOrganizationPage({@required organizationBloc})
      : _organizationBloc = organizationBloc;
  @override
  State<StatefulWidget> createState() {
    return _RegisterOrganizationPageState();
  }
}

class _RegisterOrganizationPageState extends State<RegisterOrganizationPage> {
  GlobalKey<FormState> _formKey;
  StreamSubscription<OrganizationState> _navigationListener;

  @override
  void initState() {
    super.initState();
    widget._organizationBloc.clearStorage();
    _formKey = GlobalKey<FormState>();
    _navigationListener = widget._organizationBloc.organizationUpdateRequests
        .listen((dynamic state) {
      if (state is OrganizationRegistered) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                  'Your organization registration has been submitted! Keep an eye out for an incoming message regarding the registration status!');
            });
      } else if (state is OrganizationError) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(errorMsg: state.errorMsg);
            });
      }
    });
  }

  Column _buildRegularMemberChips(List<OrganizationMember> regularMembers) {
    List<Chip> regularMemberChips = List<Chip>();
    for (OrganizationMember regularMember in regularMembers) {
      regularMemberChips.add(
        Chip(
          label: Text(
            regularMember.ucid + ' - Member',
          ),
          onDeleted: () {
            widget._organizationBloc.removeRegularMember(regularMember.ucid);
          },
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: regularMemberChips,
    );
  }

  Column _buildRegularMemberSection(OrganizationState state) {
    List<OrganizationMember> regularMembers = List<OrganizationMember>();
    if (state is OrganizationRegistering) {
      regularMembers = state.organization.regularMembers;
    } else if (state is OrganizationBeforeUpdates) {
      regularMembers = state.organization.regularMembers;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Regular Members',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
            '(This is optional! You can include some members here if you would like!)'),
        UCIDAndRoleFormField(
          includeRole: false,
          onSubmitted: (String ucid) {
            widget._organizationBloc.addRegularMember(ucid);
          },
          validator: widget._organizationBloc.regularMemberValidator,
        ),
        _buildRegularMemberChips(regularMembers),
      ],
    );
  }

  Column _buildEboardMemberChips(List<OrganizationMember> eBoardMembers) {
    List<Chip> eBoardMemberChips = List<Chip>();
    for (OrganizationMember eBoardMember in eBoardMembers) {
      eBoardMemberChips.add(
        Chip(
          label: Text(
            eBoardMember.ucid + ' - ' + eBoardMember.role,
          ),
          onDeleted: () {
            widget._organizationBloc
                .removeEboardMember(eBoardMember.ucid, eBoardMember.role);
          },
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: eBoardMemberChips,
    );
  }

  Column _buildEBoardSection(OrganizationState state) {
    List<OrganizationMember> eBoardMembers = List<OrganizationMember>();
    if (state is OrganizationRegistering) {
      eBoardMembers = state.organization.eBoardMembers;
    } else if (state is OrganizationBeforeUpdates) {
      eBoardMembers = state.organization.eBoardMembers;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'E-Board Members',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text('(Must have at least 3 for consideration!)'),
        UCIDAndRoleFormField(
          onSubmitted: (String ucid, String role) {
            print('submitted: ' + ucid + " " + role);
            widget._organizationBloc.addEboardMember(ucid, role);
          },
          validator: widget._organizationBloc.eBoardMemberValidator,
        ),
        _buildEboardMemberChips(eBoardMembers),
      ],
    );
  }

  Column _buildDescriptionField(OrganizationState state) {
    String initVal = '';
    if (state is OrganizationRegistering) {
      initVal = state.organization.description;
    } else if (state is OrganizationBeforeUpdates) {
      initVal = state.organization.description;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Organization Description',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
        TextFormField(
          initialValue: initVal,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          validator: widget._organizationBloc.descriptionValidator,
          onSaved: (String value) {
            widget._organizationBloc.setDescription(value);
          },
        ),
      ],
    );
  }

  Column _buildNameField(OrganizationState state) {
    String initVal = '';
    if (state is OrganizationRegistering) {
      initVal = state.organization.name;
    } else if (state is OrganizationBeforeUpdates) {
      initVal = state.organization.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Organization Name',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
        TextFormField(
          initialValue: initVal,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          validator: widget._organizationBloc.nameValidator,
          onSaved: (String value) {
            widget._organizationBloc.setName(value);
          },
        ),
      ],
    );
  }

  void _alertErrorsWithRegistration() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text('There are errors with your registration!'),
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

  Widget _buildSubmitButton(OrganizationState state) {
    if (state is OrganizationRegistering) {
      return Center(child: CircularProgressIndicator());
    }
    return Center(
      child: FlatButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: Text('REGISTER ORGANIZATION'),
        onPressed: () {
          if (!_formKey.currentState.validate()) {
            _alertErrorsWithRegistration();
            return;
          } else if (!widget._organizationBloc.enoughEBoardMembers) {
            showDialog(
                context: context,
                builder: (BuildContext context) => ErrorDialog(
                    errorMsg:
                        'Not enough eBoard members! (Need 3 at minimum)'));
            return;
          }
          _formKey.currentState.save();
          widget._organizationBloc.submitOrganizationRegistration();
          _formKey.currentState.reset();
        },
      ),
    );
  }

  StreamBuilder _buildForm() {
    return StreamBuilder<OrganizationState>(
      stream: widget._organizationBloc.organizationUpdateRequests,
      initialData: widget._organizationBloc.updatingOrgInitialState,
      builder:
          (BuildContext context, AsyncSnapshot<OrganizationState> snapshot) {
        OrganizationState state = snapshot.data;
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              _buildNameField(state),
              SizedBox(height: 10),
              _buildDescriptionField(state),
              SizedBox(height: 10),
              _buildEBoardSection(state),
              SizedBox(height: 10),
              _buildRegularMemberSection(state),
              SizedBox(height: 10),
              _buildSubmitButton(state),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Register An Organization'),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            margin: EdgeInsets.all(10),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _navigationListener.cancel();
    super.dispose();
  }
}
