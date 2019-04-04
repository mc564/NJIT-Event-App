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

  FlatButton _buildTileButton(Widget child, Function onPressed) {
    return FlatButton(child: child, onPressed: onPressed);
  }

  Container _build3DEffectTile(
      String content, double offset, Color backgroundColor) {
    return Container(
      alignment: Alignment.center,
      color: backgroundColor,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: offset,
            child: Text(
              content,
              style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: offset,
            child: Text(
              content,
              style: TextStyle(
                  color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
          widget._organizationBloc.removeRegularMember(member.ucid);
        },
      );
    }
    return Container(
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
                  onSubmitted: (String ucid) {
                    widget._organizationBloc.addRegularMember(ucid);
                  },
                  validator: widget._organizationBloc.regularMemberValidator,
                ),
              ),
              Expanded(
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, childAspectRatio: 4),
                  children: <Widget>[
                    _build3DEffectTile('~', 47, Colors.white),
                    _build3DEffectTile('No members!', 9, Colors.white),
                    _build3DEffectTile('~', 46, Colors.white),
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
                onSubmitted: (String ucid) {
                  widget._organizationBloc.addRegularMember(ucid);
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
                    return _build3DEffectTile('UCID', 47, Colors.white);
                  else if (index == 1)
                    return _build3DEffectTile('Role', 46, Colors.white);
                  else if (index == 2)
                    //change this to become a button
                    return _buildTileButton(
                        _build3DEffectTile('SUBMIT', 17, Colors.orange), () {
                      widget._organizationBloc.submitOrganizationUpdates();
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
    widget._organizationBloc.clearStorage();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget._organizationBloc.setOrgToEdit(widget._organization));
    _navigationListener = widget._organizationBloc.organizationUpdateRequests
        .listen((dynamic state) {
      if (state is OrganizationUpdated) {
        widget._organization.setMembers(state.updatedOrganization.regularMembers);
        widget._organizationBloc.setOrgToEdit(state.updatedOrganization);
        String members = '';
        for(OrganizationMember member in widget._organization.regularMembers){
          members+= "UCID: "+member.ucid +" Role: "+ member.role + "\n";
        }
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return SuccessDialog(
                  'Your organization\'s members have been updated! Changed members: [\n'+members+'\n]'
                      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Or Remove Members'),
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
