import 'package:flutter/material.dart';
import 'dart:async';

import '../../blocs/organization_bloc.dart';

import './organization_widgets.dart';
import '../../common/error_dialog.dart';
import '../../common/success_dialog.dart';

import '../../models/organization.dart';

class ChangeOfEboardMembersPage extends StatefulWidget {
  final OrganizationBloc _organizationBloc;
  final Organization _organization;

  ChangeOfEboardMembersPage(
      {@required Organization organization,
      @required OrganizationBloc organizationBloc})
      : _organization = organization,
        _organizationBloc = organizationBloc;

  @override
  State<StatefulWidget> createState() {
    return _ChangeOfEboardMembersPageState();
  }
}

class _ChangeOfEboardMembersPageState extends State<ChangeOfEboardMembersPage> {
  GlobalKey<FormState> _formKey;
  StreamSubscription<OrganizationState> _navigationListener;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    widget._organizationBloc.sink.add(ClearStorage());
    //this executes on build complete basically
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget._organizationBloc.sink.add(SetOrganizationToEdit(organization: widget._organization)));
    _navigationListener = widget._organizationBloc.organizationUpdateRequests
        .listen((dynamic state) {
      if (state is OrganizationUpdated) {
        if (mounted) {
          setState(() {
            widget._organization
                .setStatus(OrganizationStatus.AWAITING_EBOARD_CHANGE);
          });
        }
        String eBoardMembers = '';
        for (OrganizationMember eBoardMember
            in state.updatedOrganization.eBoardMembers) {
          eBoardMembers += "UCID: " +
              eBoardMember.ucid +
              " Role: " +
              eBoardMember.role +
              "\n";
        }
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                  'Your organization E-Board update request has been submitted! Keep an eye out for an incoming message regarding the status of your request! Requested organization E-Board members: [\n' +
                      eBoardMembers +
                      '\n]');
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

  void _alertErrorsWithEboardMemberChanges() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text(
                'There are errors with your E-Board member change request!'),
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

  Column _buildEboardMemberChips(List<OrganizationMember> eBoardMembers) {
    List<Chip> eBoardMemberChips = List<Chip>();
    for (OrganizationMember eBoardMember in eBoardMembers) {
      eBoardMemberChips.add(
        Chip(
          label: Text(
            eBoardMember.ucid + ' - ' + eBoardMember.role,
          ),
          onDeleted: () {
            widget._organizationBloc.sink.add(RemoveEboardMember(
                ucid: eBoardMember.ucid, role: eBoardMember.role));
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
    if (state is OrganizationUpdating) {
      eBoardMembers = state.organization.eBoardMembers;
    } else if (state is OrganizationBeforeUpdates) {
      eBoardMembers = state.organization.eBoardMembers;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'New E-Board Members',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text('(Must have at least 3 for consideration!)'),
        UCIDAndRoleFormField(
          onSubmitted: (String ucid, String role) {
            widget._organizationBloc.sink
                .add(AddEboardMember(ucid: ucid, role: role));
          },
          validator: widget._organizationBloc.eBoardMemberValidator,
        ),
        _buildEboardMemberChips(eBoardMembers),
      ],
    );
  }

  Widget _buildSubmitButton(OrganizationState state) {
    if (state is OrganizationUpdating) {
      return Center(child: CircularProgressIndicator());
    }
    return Center(
      child: FlatButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: Text('CHANGE EBOARD MEMBERS'),
        onPressed: () {
          if (!_formKey.currentState.validate()) {
            _alertErrorsWithEboardMemberChanges();
            return;
          } else if (!widget._organizationBloc.enoughEBoardMembers) {
            showDialog(
                context: context,
                builder: (BuildContext context) => ErrorDialog(
                    errorMsg:
                        'Not enough E-Board members! (Need 3 at minimum)'));
            return;
          }
          _formKey.currentState.save();
          widget._organizationBloc.sink.add(RequestEboardChanges());
          _formKey.currentState.reset();
        },
      ),
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView(
        child: StreamBuilder<OrganizationState>(
          stream: widget._organizationBloc.organizationUpdateRequests,
          initialData: widget._organizationBloc.updatingOrgInitialState,
          builder: (BuildContext context,
              AsyncSnapshot<OrganizationState> snapshot) {
            OrganizationState state = snapshot.data;
            return Form(
              key: _formKey,
              child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Text(
                      'for ' + widget._organization.name,
                      style: TextStyle(color: Colors.blue),
                    ),
                    SizedBox(height: 10),
                    Text(
                        'Please specify the new members of the E-Board and name a reason for the switch:'),
                    SizedBox(height: 10),
                    TextFormField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Reason For Change In E-Board Members',
                      ),
                      validator: widget._organizationBloc.reasonValidator,
                      onSaved: (String value) {
                        widget._organizationBloc.sink.add(SetReasonForUpdate(reason: value));
                      },
                    ),
                    _buildEBoardSection(state),
                    _buildSubmitButton(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('in build of change eboard members, the status is: ' +
        widget._organization.status.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Change of E-Board Members'),
        centerTitle: true,
      ),
      body: !widget._organizationBloc
              .canSendOrganizationRequest(widget._organization)
          ? Container(
              margin: EdgeInsets.all(10),
              child: Center(
                child: Text(
                    'A request has already been submitted for this organization! Please wait until the admins respond to submit more requests.'),
              ),
            )
          : _buildBody(),
    );
  }

  @override
  void dispose() {
    _navigationListener.cancel();
    super.dispose();
  }
}
