import 'package:flutter/material.dart';
import '../../blocs/organization_bloc.dart';
import '../../models/organization.dart';
import '../../common/single_input_field.dart';

class OrganizationActionsPendingPage extends StatefulWidget {
  final OrganizationBloc _organizationBloc;

  OrganizationActionsPendingPage({@required OrganizationBloc organizationBloc})
      : _organizationBloc = organizationBloc;
  @override
  State<StatefulWidget> createState() {
    return _OrganizationActionsPendingPageState();
  }
}

class _OrganizationActionsPendingPageState
    extends State<OrganizationActionsPendingPage> {
  List<Widget> _getWidgetListFromOrgMembers(List<OrganizationMember> members) {
    List<Widget> list = List<Widget>();

    for (OrganizationMember member in members) {
      String str = "UCID: " + member.ucid + " Role: " + member.role;
      list.add(Text(str));
    }
    return list;
  }

  AlertDialog _buildApprovalDialog(
      {@required List<Widget> children,
      @required String title,
      @required String rejectionPageTitle,
      @required String rejectionPageSubtitle,
      @required Function onRejection,
      @required Function onApproval}) {
    return AlertDialog(
      title: Text(title, style: TextStyle(color: Colors.blue)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: children,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Return'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          color: Colors.red,
          textColor: Colors.white,
          child: Text('Reject'),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => SingleInputFieldPage(
                      title: rejectionPageTitle,
                      subtitle: rejectionPageSubtitle,
                      onSubmit: (String reason) {
                        onRejection(reason);
                      },
                    ),
              ),
            );
          },
        ),
        FlatButton(
          color: Colors.green,
          textColor: Colors.white,
          child: Text('Approve'),
          onPressed: () {
            onApproval();
          },
        ),
      ],
    );
  }

  void _showInactivationApprovalDialog(Organization orgRequestingInactivation) {
    List<Widget> children = List<Widget>();
    children.addAll(
      [
        Text('Organization Name',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(orgRequestingInactivation.name),
        SizedBox(height: 10),
        Text('Organization Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(orgRequestingInactivation.description),
        SizedBox(height: 10),
        Text('Current E-Board Members',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
      ],
    );
    List<Widget> eboardMemberWidgets =
        _getWidgetListFromOrgMembers(orgRequestingInactivation.eBoardMembers);
    if (eboardMemberWidgets.length == 0)
      children.add(Text('No current E-Board members in this organization.'));
    else
      children.addAll(eboardMemberWidgets);
    children.addAll([
      SizedBox(height: 10),
      Text('Current Regular Members',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
    ]);
    List<Widget> regularMemberWidgets =
        _getWidgetListFromOrgMembers(orgRequestingInactivation.regularMembers);
    if (regularMemberWidgets.length == 0)
      children.add(Text('No current regular members in this organization.'));
    else
      children.addAll(regularMemberWidgets);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _buildApprovalDialog(
            title:
                'Organization Inactivation Details For Approval\n(Please check your messages for the reason this request was submitted.)',
            children: children,
            rejectionPageTitle: 'Reason for Inactivation Refusal',
            rejectionPageSubtitle:
                '(What is the reason for refusing this organization\'s inactivation? Please type in an answer below.)',
            onRejection: (String reason) => widget._organizationBloc.sink.add(
                RefuseOrganizationInactivation(
                    organization: orgRequestingInactivation, reason: reason)),
            onApproval: () {
              widget._organizationBloc.sink.add(InactivateOrganization(
                  organization: orgRequestingInactivation));
              Navigator.of(context).pop();
            },
          );
        });
  }

  void _showEboardChangeApprovalDialog(
      OrganizationUpdateRequestData orgUpdateRequest) {
    Organization originalOrg = orgUpdateRequest.original;
    Organization updatedOrg = orgUpdateRequest.updated;
    List<Widget> children = List<Widget>();
    children.addAll(
      [
        Text('Organization Name',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(originalOrg.name),
        SizedBox(height: 10),
        Text('Organization Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(originalOrg.description),
        SizedBox(height: 10),
        Text('Current E-Board Members',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
      ],
    );
    List<Widget> originalEboardMemberWidgets =
        _getWidgetListFromOrgMembers(originalOrg.eBoardMembers);
    if (originalEboardMemberWidgets.length == 0)
      children.add(Text('No current E-Board members in this organization.'));
    else
      children.addAll(originalEboardMemberWidgets);
    children.addAll([
      SizedBox(height: 10),
      Text('Requested (Changed) E-Board Members',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
    ]);
    List<Widget> requestedEboardMemberWidgets =
        _getWidgetListFromOrgMembers(updatedOrg.eBoardMembers);
    if (requestedEboardMemberWidgets.length == 0)
      children.add(Text('No requested E-Board members for this organization.'));
    else
      children.addAll(requestedEboardMemberWidgets);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _buildApprovalDialog(
            title:
                'E-Board Change Details For Approval\n(Please check your messages for the reason this request was submitted.)',
            children: children,
            rejectionPageTitle: 'Reason for Rejection',
            rejectionPageSubtitle:
                '(What is the reason for this organization\'s E-Board change request rejection? Please type in an answer below.)',
            onRejection: (String reason) => widget._organizationBloc.sink.add(
                RejectEboardChanges(
                    requestData: orgUpdateRequest, reason: reason)),
            onApproval: () {
              widget._organizationBloc.sink
                  .add(ApproveEboardChanges(requestData: orgUpdateRequest));
              Navigator.of(context).pop();
            },
          );
        });
  }

  void _showRevivalDialog(Organization org) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<Widget> children = List<Widget>();
        children.addAll(
          [
            Text('Organization Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(org.name),
            SizedBox(height: 10),
            Text('Organization Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(org.description),
            SizedBox(height: 10),
            Text('Submitted E-Board Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
          ],
        );
        List<Widget> eBoardMemberWidgets =
            _getWidgetListFromOrgMembers(org.eBoardMembers);
        if (eBoardMemberWidgets.length == 0)
          children
              .add(Text('No E-Board members submitted for this organization.'));
        else
          children.addAll(eBoardMemberWidgets);
        children.addAll([
          SizedBox(height: 10),
          Text('Submitted Regular Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
        ]);
        List<Widget> regularMemberWidgets =
            _getWidgetListFromOrgMembers(org.regularMembers);
        if (regularMemberWidgets.length == 0)
          children
              .add(Text('No regular members submitted for this organization.'));
        else
          children.addAll(regularMemberWidgets);
        return _buildApprovalDialog(
          title: 'Organization Details For Revival:',
          children: children,
          rejectionPageTitle: 'Reason for Rejection',
          rejectionPageSubtitle:
              '(What is the reason for this organization revival rejection? Please type in an answer below.)',
          onRejection: (String reason) => widget._organizationBloc.sink.add(
              RejectOrganizationRevival(organization: org, reason: reason)),
          onApproval: () {
            widget._organizationBloc.sink
                .add(ApproveOrganizationRevival(organization: org));
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showOrgApprovalDialog(Organization org) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<Widget> children = List<Widget>();
        children.addAll(
          [
            Text('Organization Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(org.name),
            SizedBox(height: 10),
            Text('Organization Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(org.description),
            SizedBox(height: 10),
            Text('Submitted E-Board Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
          ],
        );
        List<Widget> eBoardMemberWidgets =
            _getWidgetListFromOrgMembers(org.eBoardMembers);
        if (eBoardMemberWidgets.length == 0)
          children
              .add(Text('No E-Board members submitted for this organization.'));
        else
          children.addAll(eBoardMemberWidgets);
        children.addAll([
          SizedBox(height: 10),
          Text('Submitted Regular Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
        ]);
        List<Widget> regularMemberWidgets =
            _getWidgetListFromOrgMembers(org.regularMembers);
        if (regularMemberWidgets.length == 0)
          children
              .add(Text('No regular members submitted for this organization.'));
        else
          children.addAll(regularMemberWidgets);
        return _buildApprovalDialog(
          title: 'Organization Details For Approval:',
          children: children,
          rejectionPageTitle: 'Reason for Rejection',
          rejectionPageSubtitle:
              '(What is the reason for this organization registration rejection? Please type in an answer below.)',
          onRejection: (String reason) => widget._organizationBloc.sink.add(
              RejectOrganizationRegistration(
                  reason: reason, organization: org)),
          onApproval: () {
            widget._organizationBloc.sink
                .add(ApproveOrganizationRegistration(organization: org));
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  ListTile _buildAwaitingApprovalListTile(Organization org) {
    return ListTile(
      title: Text(org.name),
      trailing: IconButton(
        icon: Icon(Icons.more),
        onPressed: () {
          //show a dialog that has org info and options to approve or reject
          _showOrgApprovalDialog(org);
        },
      ),
    );
  }

  Widget _buildRegistrationRequestsSection() {
    return StreamBuilder<OrganizationState>(
      initialData: widget._organizationBloc.orgsAwaitingApprovalInitialState,
      stream: widget._organizationBloc.organizationsAwaitingApproval,
      builder:
          (BuildContext context, AsyncSnapshot<OrganizationState> snapshot) {
        OrganizationState state = snapshot.data;
        if (state is OrganizationError) {
          print('error:' + state.errorMsg);
          return Text('Oh my, there was an error! Please try again!');
        } else if (state is OrganizationsLoading ||
            state is OrganizationUpdating) {
          return CircularProgressIndicator();
        } else if (state is OrganizationsLoaded) {
          List<Organization> orgs = state.organizations;
          if (orgs == null || orgs.length == 0)
            return Text('✔️ No organizations requiring approval right now!');
          return Container(
            height: 200,
            child: ListView.builder(
              itemCount: orgs.length,
              itemBuilder: (BuildContext context, int index) {
                Organization org = orgs[index];
                return _buildAwaitingApprovalListTile(org);
              },
            ),
          );
        }
      },
    );
  }

  ListTile _buildChangeEboardListTile(
      OrganizationUpdateRequestData orgUpdateRequest) {
    return ListTile(
      title: Text(orgUpdateRequest.original.name),
      trailing: IconButton(
        icon: Icon(Icons.more),
        onPressed: () {
          _showEboardChangeApprovalDialog(orgUpdateRequest);
        },
      ),
    );
  }

  Widget _buildChangeOfEboardRequestsSection() {
    return StreamBuilder<OrganizationState>(
      initialData:
          widget._organizationBloc.orgsAwaitingEboardChangeInitialState,
      stream: widget._organizationBloc.organizationsAwaitingEboardChange,
      builder:
          (BuildContext context, AsyncSnapshot<OrganizationState> snapshot) {
        OrganizationState state = snapshot.data;
        if (state is OrganizationError) {
          print(state.errorMsg);
          return Text('Oh my, there was an error! Please try again!');
        } else if (state is OrganizationsLoading ||
            state is OrganizationUpdating) {
          return CircularProgressIndicator();
        } else if (state is OrganizationUpdateRequestsLoaded) {
          List<OrganizationUpdateRequestData> requests = state.requestData;
          if (requests == null || requests.length == 0)
            return Text(
                '✔️ No organizations requesting E-Board changes right now!');
          return Container(
            height: 200,
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (BuildContext context, int index) {
                OrganizationUpdateRequestData request = requests[index];
                return _buildChangeEboardListTile(request);
              },
            ),
          );
        }
      },
    );
  }

  ListTile _buildInactivationListTile(Organization orgRequestingInactivation) {
    return ListTile(
      title: Text(orgRequestingInactivation.name),
      trailing: IconButton(
        icon: Icon(Icons.more),
        onPressed: () {
          _showInactivationApprovalDialog(orgRequestingInactivation);
        },
      ),
    );
  }

  Widget _buildInactivationRequestsSection() {
    return StreamBuilder<OrganizationState>(
      initialData:
          widget._organizationBloc.orgsAwaitingInactivationInitialState,
      stream: widget._organizationBloc.organizationsAwaitingInactivation,
      builder:
          (BuildContext context, AsyncSnapshot<OrganizationState> snapshot) {
        OrganizationState state = snapshot.data;
        if (state is OrganizationError) {
          print(state.errorMsg);
          return Text('Oh my, there was an error! Please try again!');
        } else if (state is OrganizationsLoading ||
            state is OrganizationUpdating) {
          return CircularProgressIndicator();
        } else if (state is OrganizationsLoaded) {
          List<Organization> organizationsRequestedInactivation =
              state.organizations;
          if (organizationsRequestedInactivation == null ||
              organizationsRequestedInactivation.length == 0)
            return Text(
                '✔️ No organizations requesting inactivation right now!');
          return Container(
            height: 200,
            child: ListView.builder(
              itemCount: organizationsRequestedInactivation.length,
              itemBuilder: (BuildContext context, int index) {
                Organization org = organizationsRequestedInactivation[index];
                return _buildInactivationListTile(org);
              },
            ),
          );
        }
      },
    );
  }

  ListTile _buildRevivalListTile(Organization org) {
    return ListTile(
      title: Text(org.name),
      trailing: IconButton(
        icon: Icon(Icons.more),
        onPressed: () {
          //show a dialog that has org info and options to approve or reject
          _showRevivalDialog(org);
        },
      ),
    );
  }

  Widget _buildRevivalRequestsSection() {
    return StreamBuilder<OrganizationState>(
      initialData:
          widget._organizationBloc.orgsAwaitingReactivationInitialState,
      stream: widget._organizationBloc.organizationsAwaitingReactivation,
      builder:
          (BuildContext context, AsyncSnapshot<OrganizationState> snapshot) {
        OrganizationState state = snapshot.data;
        if (state is OrganizationError) {
          print('error:' + state.errorMsg);
          return Text('Oh my, there was an error! Please try again!');
        } else if (state is OrganizationsLoading ||
            state is OrganizationUpdating) {
          return CircularProgressIndicator();
        } else if (state is OrganizationsLoaded) {
          List<Organization> orgs = state.organizations;
          if (orgs == null || orgs.length == 0)
            return Text(
                '✔️ No organizations requiring reactivation right now!');
          return Container(
            height: 200,
            child: ListView.builder(
              itemCount: orgs.length,
              itemBuilder: (BuildContext context, int index) {
                Organization org = orgs[index];
                return _buildRevivalListTile(org);
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text(
              'New Organization Registration Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '(For Approval/Rejection)',
              style: TextStyle(color: Colors.blue),
            ),
            _buildRegistrationRequestsSection(),
            SizedBox(height: 10),
            Text(
              'Organization Revival Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '(Revived From Inactive Organizations)',
              style: TextStyle(color: Colors.blue),
            ),
            Text(
              '(For Approval/Rejection)',
              style: TextStyle(color: Colors.blue),
            ),
            _buildRevivalRequestsSection(),
            SizedBox(height: 10),
            Text(
              'Change of Eboard Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '(For Approval/Rejection)',
              style: TextStyle(color: Colors.blue),
            ),
            _buildChangeOfEboardRequestsSection(),
            SizedBox(height: 10),
            Text(
              'Organization Inactivation Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '(For Approval/Rejection)',
              style: TextStyle(color: Colors.blue),
            ),
            _buildInactivationRequestsSection(),
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
        backgroundColor: Colors.lightBlue[50],
        title: Text('Organization - Actions Pending',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }
}
