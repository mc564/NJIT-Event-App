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
  List<int> _colors;
  int _colorIdx;

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
    _colors = [
      0xffffdde2,
      0xffFFFFCC,
      0xffdcf9ec,
      0xffFFFFFF,
      0xffF0F0F0,
    ];
    _colorIdx = 0;
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
          color: Color(_colors[_colorIdx++ % _colors.length]),
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
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(_colors[_colorIdx++ % _colors.length]),
              ),
              controller: textController,
              maxLines: widget._maxLines,
            ),
            SizedBox(height: 10),
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
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color(_colors[_colorIdx++ % _colors.length]),
        centerTitle: true,
        title: Text(
          'Send An Inactivation Request',
          style: TextStyle(color: Colors.black),
        ),
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
