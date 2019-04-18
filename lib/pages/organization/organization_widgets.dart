import 'package:flutter/material.dart';
import '../../blocs/organization_bloc.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/edit_bloc.dart';
import '../../blocs/favorite_rsvp_bloc.dart';
import '../../models/organization.dart';
import './organization_detail.dart';

class OrganizationCard extends StatelessWidget {
  final EditEventBloc _editBloc;
  final FavoriteAndRSVPBloc _favoriteAndRSVPBloc;
  final OrganizationBloc _organizationBloc;
  final EventBloc _eventBloc;
  final Organization _organization;
  final String _ucid;
  final Color _color;

  OrganizationCard(
      {@required ucid,
      @required FavoriteAndRSVPBloc favoriteAndRSVPBloc,
      @required OrganizationBloc organizationBloc,
      @required EditEventBloc editBloc,
      @required EventBloc eventBloc,
      @required Organization organization,
      @required Color color})
      : _organization = organization,
        _organizationBloc = organizationBloc,
        _editBloc = editBloc,
        _favoriteAndRSVPBloc = favoriteAndRSVPBloc,
        _eventBloc = eventBloc,
        _ucid = ucid,
        _color = color;

  String _organizationRole() {
    for (OrganizationMember eboardMember in _organization.eBoardMembers) {
      if (eboardMember.ucid == _ucid) return eboardMember.role;
    }
    for (OrganizationMember regularMember in _organization.regularMembers) {
      if (regularMember.ucid == _ucid) return regularMember.role;
    }
    return null;
  }

  String _cutShort(String s, int length) {
    if (s.length <= length)
      return s;
    else
      return s.substring(0, length + 1) + "...";
  }

  @override
  Widget build(BuildContext context) {
    String role = _organizationRole();
    bool isEboardMember = role != 'Member' && role != null;
    return Card(
      color: _color,
      child: Container(
        padding: EdgeInsets.only(left: 10),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(_cutShort(_organization.name, 20)),
                SizedBox(width: 10),
                role != null
                    ? Chip(
                        label: Text(_cutShort(role, 20)),
                        labelStyle: TextStyle(color: Colors.white),
                        backgroundColor:
                            isEboardMember ? Colors.orange : Colors.green,
                      )
                    : Container(),
              ],
            ),
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => OrganizationDetailPage(
                          editBloc: _editBloc,
                          organizationBloc: _organizationBloc,
                          eventBloc: _eventBloc,
                          favoriteAndRSVPBloc: _favoriteAndRSVPBloc,
                          organization: _organization,
                          ucid: _ucid,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UCIDAndRoleFormField extends StatefulWidget {
  final Function _onSubmit;
  final Function _validate;
  final bool _includeRole;
  final Color _colorUCID;
  final Color _colorRole;
  final Color _backgroundColor;

  //used to be grey[200] for background color, error about how its not constant
  UCIDAndRoleFormField({
    @required Function onSubmitted,
    @required Function validator,
    bool includeRole = true,
    Color colorUCID = Colors.white,
    Color colorRole = Colors.white,
    Color backgroundColor = Colors.grey,
  })  : _onSubmit = onSubmitted,
        _validate = validator,
        _includeRole = includeRole,
        _colorRole = colorRole,
        _colorUCID = colorUCID,
        _backgroundColor = backgroundColor;

  @override
  State<StatefulWidget> createState() {
    return _UCIDAndRoleFormFieldState();
  }
}

class _UCIDAndRoleFormFieldState extends State<UCIDAndRoleFormField> {
  TextEditingController _ucidFieldController;
  TextEditingController _roleFieldController;

  @override
  void initState() {
    super.initState();
    _ucidFieldController = new TextEditingController();
    _roleFieldController = new TextEditingController();
  }

  void _alertInvalidInputs(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text(message),
            content: Text('Please try again!'),
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

  IconButton _buildAddButton() {
    return IconButton(
      icon: Icon(Icons.add_circle, size: 30),
      onPressed: () {
        String role = _roleFieldController.text;
        String ucid = _ucidFieldController.text;
        String validatorMsg = widget._includeRole
            ? widget._validate(ucid, role)
            : widget._validate(ucid);
        if (validatorMsg != null) {
          _alertInvalidInputs(validatorMsg);
        } else {
          widget._includeRole
              ? widget._onSubmit(ucid, role)
              : widget._onSubmit(ucid);
          _ucidFieldController.clear();
          _roleFieldController.clear();
        }
      },
    );
  }

  Flexible _buildRoleField() {
    return Flexible(
      child: Container(
        margin: EdgeInsets.only(right: 10),
        child: TextField(
          controller: _roleFieldController,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Role',
            filled: true,
            fillColor: widget._colorRole,
            contentPadding: EdgeInsets.all(10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget._colorRole, width: 0),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: widget._colorRole, width: 0),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Flexible _buildUCIDField() {
    return Flexible(
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: TextField(
          controller: _ucidFieldController,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'UCID',
            filled: true,
            fillColor: widget._colorUCID,
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 0, color: widget._colorUCID),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0, color: widget._colorUCID),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget._backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
      ),
      child: Row(
        children: <Widget>[
          _buildUCIDField(),
          widget._includeRole ? _buildRoleField() : Container(),
          _buildAddButton(),
        ],
      ),
    );
  }
}
