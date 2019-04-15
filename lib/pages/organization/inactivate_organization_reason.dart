import 'dart:async';
import 'package:flutter/material.dart';
import '../../common/error_dialog.dart';
import '../../common/success_dialog.dart';
import '../../blocs/organization_bloc.dart';
import '../../models/organization.dart';

class InactivateOrganizationReasonPage extends StatefulWidget {
  final Organization _organizationToInactivate;
  final OrganizationBloc _organizationBloc;
  final int _maxLines;

  InactivateOrganizationReasonPage({
    @required Organization organizationToInactivate,
    @required OrganizationBloc organizationBloc,
    int maxLines = 5,
  })  : _organizationBloc = organizationBloc,
        _organizationToInactivate = organizationToInactivate,
        _maxLines = maxLines;

  @override
  State<StatefulWidget> createState() {
    return _InactivateOrganizationReasonPageState();
  }
}

class _InactivateOrganizationReasonPageState
    extends State<InactivateOrganizationReasonPage> {
  TextEditingController textController;
  StreamSubscription<OrganizationState> _navigationListener;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    _navigationListener = widget._organizationBloc.organizationUpdateRequests
        .listen((dynamic state) {
      if (state is OrganizationUpdated) {
        if (mounted) {
          setState(() {
            widget._organizationToInactivate
                .setStatus(state.updatedOrganization.status);
          });
        }
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                  'Your organization inactivation request has been submitted! Keep an eye out for an incoming message regarding the status of your request!');
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

  Widget _buildSubmitButton() {
    return StreamBuilder<OrganizationState>(
      initialData: widget._organizationBloc.updatingOrgInitialState,
      stream: widget._organizationBloc.organizationUpdateRequests,
      builder: (BuildContext context, AsyncSnapshot<OrganizationState> state) {
        if (state is OrganizationUpdating) {
          return Center(child: CircularProgressIndicator());
        }
        return FlatButton(
          child: Text('Continue'),
          onPressed: () {
            String paragraph = textController.text;
            if (paragraph == null || paragraph.length == 0) {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    ErrorDialog(errorMsg: 'A response is required.'),
              );
              return;
            }

            widget._organizationBloc.sink.add(RequestOrganizationInactivation(
                organization: widget._organizationToInactivate,
                reason: paragraph));
          },
        );
      },
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text(
                'Please provide a reason for this organization\'s inactivation.'),
            TextField(
              controller: textController,
              maxLines: widget._maxLines,
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Send An Inactivation Request'),
      ),
      body: !widget._organizationBloc
              .canSendOrganizationRequest(widget._organizationToInactivate)
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
