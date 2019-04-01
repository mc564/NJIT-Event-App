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
            onRejection: (String reason) {},
            onApproval: () {
              widget._organizationBloc.approveEboardChanges(updatedOrg);
              print('approving now...');
              Navigator.of(context).pop();
            },
          );
        });
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
          onRejection: (String reason) =>
              widget._organizationBloc.rejectOrganization(reason, org),
          onApproval: () {
            widget._organizationBloc.approveOrganization(org);
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

  Widget _buildNewOrRevivedRequestsSection() {
    return StreamBuilder<OrganizationState>(
      initialData: widget._organizationBloc.orgsAwaitingApprovalInitialState,
      stream: widget._organizationBloc.organizationsAwaitingApproval,
      builder:
          (BuildContext context, AsyncSnapshot<OrganizationState> snapshot) {
        OrganizationState state = snapshot.data;
        if (state is OrganizationError) {
          return Text('Oh my, there was an error! Please try again!');
        } else if (state is OrganizationsLoading) {
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
        } else if (state is OrganizationsLoading) {
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

  Widget _buildBody() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(
            'New/Revived Organization Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '(For Approval/Rejection)',
            style: TextStyle(color: Colors.blue),
          ),
          _buildNewOrRevivedRequestsSection(),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organization - Actions Pending'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }
}
