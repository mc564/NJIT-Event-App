import 'dart:async';
import 'package:flutter/material.dart';
import '../../blocs/organization_bloc.dart';
import '../../models/organization.dart';
import '../../common/success_dialog.dart';
import '../../common/error_dialog.dart';
import './organization_widgets.dart';

enum TileType { UCID, Role, X }

class AddOrRemoveMembersPage extends StatefulWidget {
  final OrganizationBloc _organizationBloc;
  final Organization _organization;

  AddOrRemoveMembersPage(
      {@required Organization organization,
      @required OrganizationBloc organizationBloc})
      : _organization = organization,
        _organizationBloc = organizationBloc;

  @override
  State<StatefulWidget> createState() {
    return _AddOrRemoveMembersPageState();
  }
}

class _AddOrRemoveMembersPageState extends State<AddOrRemoveMembersPage> {
  StreamSubscription _navigationListener;
  List<int> _colors;
  int _colorIdx;

  RaisedButton _buildTileButton(Widget child, Function onPressed) {
    return RaisedButton(
      padding: EdgeInsets.all(0),
      child: child,
      onPressed: onPressed,
      elevation: 5,
    );
  }

  Container _buildColumnTitleTile(String content) {
    return Container(
      alignment: Alignment.center,
      color: Color(_colors[_colorIdx++ % _colors.length]),
      child: Text(
        content,
        style: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container _buildTile(OrganizationMember member, TileType tileType) {
    Widget child;
    if (tileType == TileType.UCID) {
      child = Text(
        member.ucid,
        textAlign: TextAlign.center,
      );
    } else if (tileType == TileType.Role) {
      child = Text(
        member.role,
        textAlign: TextAlign.center,
      );
    } else {
      child = IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          widget._organizationBloc.sink
              .add(RemoveRegularMember(ucid: member.ucid));
        },
      );
    }
    return Container(
      color: Color(_colors[_colorIdx++ % _colors.length]),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildBody() {
    return StreamBuilder<OrganizationState>(
      initialData: widget._organizationBloc.updatingOrgInitialState,
      stream: widget._organizationBloc.organizationUpdateRequests,
      builder:
          (BuildContext context, AsyncSnapshot<OrganizationState> snapshot) {
        OrganizationState state = snapshot.data;
        List<OrganizationMember> regularMembers = List<OrganizationMember>();
        if (state is OrganizationBeforeUpdates) {
          regularMembers = state.organization.regularMembers;
        } else if (state is OrganizationUpdated) {
          regularMembers = state.updatedOrganization.regularMembers;
        } else if (state is OrganizationUpdating) {
          return Center(child: CircularProgressIndicator());
        } else if (state is OrganizationError) {
          return Center(child: Text('Whoops there was an error! 😵'));
        }
        if (regularMembers == null || regularMembers.length == 0) {
          return Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child: UCIDAndRoleFormField(
                  includeRole: false,
                  colorUCID: Color(_colors[_colorIdx++ % _colors.length]),
                  backgroundColor: Color(_colors[_colorIdx++ % _colors.length]),
                  onSubmitted: (String ucid) {
                    widget._organizationBloc.sink
                        .add(AddRegularMember(ucid: ucid));
                  },
                  validator: widget._organizationBloc.regularMemberValidator,
                ),
              ),
              Expanded(
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, childAspectRatio: 4),
                  children: <Widget>[
                    _buildColumnTitleTile('~'),
                    _buildColumnTitleTile('No members!'),
                    _buildColumnTitleTile('~'),
                  ],
                ),
              ),
            ],
          );
        }
        return Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              child: UCIDAndRoleFormField(
                includeRole: false,
                colorUCID: Color(_colors[_colorIdx++ % _colors.length]),
                backgroundColor: Color(_colors[_colorIdx++ % _colors.length]),
                onSubmitted: (String ucid) {
                  widget._organizationBloc.sink
                      .add(AddRegularMember(ucid: ucid));
                },
                validator: widget._organizationBloc.regularMemberValidator,
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 4),
                itemCount: (regularMembers.length + 1) * 3,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0)
                    return _buildColumnTitleTile('UCID');
                  else if (index == 1)
                    return _buildColumnTitleTile('Role');
                  else if (index == 2)
                    //change this to become a button
                    return _buildTileButton(_buildColumnTitleTile('SUBMIT'),
                        () {
                      widget._organizationBloc.sink
                          .add(SubmitOrganizationUpdates());
                    });
                  else {
                    int memberListIndex = ((index / 3) - 1).floor();
                    TileType tileType = TileType.UCID;
                    if (((memberListIndex + 1) * 3) + 1 == index) {
                      tileType = TileType.Role;
                    } else if (((memberListIndex + 1) * 3) + 2 == index) {
                      tileType = TileType.X;
                    }
                    return _buildTile(
                        regularMembers[memberListIndex], tileType);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    print('in init state of add or remove members');
    widget._organizationBloc.sink.add(ClearStorage());
    WidgetsBinding.instance.addPostFrameCallback((_) => widget
        ._organizationBloc.sink
        .add(SetOrganizationToEdit(organization: widget._organization)));
    _navigationListener = widget._organizationBloc.organizationUpdateRequests
        .listen((dynamic state) {
      if (state is OrganizationUpdated) {
        widget._organization
            .setMembers(state.updatedOrganization.regularMembers);
        widget._organizationBloc.sink.add(
            SetOrganizationToEdit(organization: state.updatedOrganization));
        String members = '';
        for (OrganizationMember member in widget._organization.regularMembers) {
          members += "UCID: " + member.ucid + " Role: " + member.role + "\n";
        }
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                  'Your organization\'s members have been updated! Changed members: [\n' +
                      members +
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
    _colors = [
      0xffffdde2,
      0xffFFFFCC,
      0xffdcf9ec,
      0xffFFFFFF,
      0xffF0F0F0,
    ];
    _colorIdx = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text('Add Or Remove Members',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Color(_colors[_colorIdx++ % _colors.length]),
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
