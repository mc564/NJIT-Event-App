import 'package:flutter/material.dart';

import '../../blocs/organization_bloc.dart';
import '../../blocs/user_bloc.dart';
import '../../blocs/edit_bloc.dart';

import '../../providers/event_list_provider.dart';

import './user_permissions.dart';
import './org_actions_pending.dart';
import '../add/add.dart';

class AdminPage extends StatefulWidget {
  final EditEventBloc _editBloc;
  final OrganizationBloc _organizationBloc;
  final UserBloc _userBloc;
  final EventListProvider _eventListProvider;

  AdminPage(
      {@required EditEventBloc editBloc,
      @required OrganizationBloc organizationBloc,
      @required UserBloc userBloc,
      @required EventListProvider eventListProvider})
      : _editBloc = editBloc,
        _organizationBloc = organizationBloc,
        _userBloc = userBloc,
        _eventListProvider = eventListProvider;

  @override
  State<StatefulWidget> createState() {
    return _AdminPageState();
  }
}

class _AdminPageState extends State<AdminPage> {
  List<Widget> _buildSectionChildren(
      String title, Map<String, Function> linkedFunctions) {
    List<Widget> children = List<Widget>();
    children.add(Text(title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
    for (String option in linkedFunctions.keys) {
      children.add(
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              option,
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
          onTap: () {
            linkedFunctions[option]();
          },
        ),
      );
    }
    return children;
  }

  Widget _buildSection(
      String title, Map<String, Function> linkedOptions, Color color) {
    return Container(
      margin: EdgeInsets.all(10),
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Card(
              color: color,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildSectionChildren(title, linkedOptions),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToOrganizationActionsPendingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => OrganizationActionsPendingPage(
              organizationBloc: widget._organizationBloc,
            ),
      ),
    );
  }

  void _goToUserPermissionsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              UserPermissionsPage(userBloc: widget._userBloc)),
    );
  }

  void _goToAdminAddPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AddPage(
            editBloc: widget._editBloc,
            isAdmin: true,
            ucid: widget._userBloc.ucid,
            orgProvider: widget._organizationBloc.organizationProvider,
            eventListProvider: widget._eventListProvider),
      ),
    );
  }

  void _showEditInstructionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text('Editing Events'),
            content: Text(
                'Click into any event\'s detail page and click the pencil icon near the top to edit the event!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Task Panel'),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Card(
                child: Column(
                  children: <Widget>[
                    _buildSection(
                        'Users',
                        {
                          'Review User Permissions': _goToUserPermissionsPage,
                        },
                        Color(0xffffff00)),
                    _buildSection(
                        'Events',
                        {
                          'Add Events': _goToAdminAddPage,
                          'Edit Events': _showEditInstructionsDialog,
                        },
                        Color(0xffffa500)),
                    _buildSection(
                        'Organizations',
                        {
                          'Actions Pending Approval/Rejection':
                              _goToOrganizationActionsPendingPage,
                        },
                        Color(0xff02d100)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
