import 'package:flutter/material.dart';
import '../../common/single_input_field.dart';
import '../../common/error_dialog.dart';
import '../../blocs/user_bloc.dart';
import '../../models/user.dart';
import 'dart:async';

class UserPermissionsPage extends StatefulWidget {
  final UserBloc _userBloc;
  UserPermissionsPage({@required UserBloc userBloc}) : _userBloc = userBloc;
  @override
  State<StatefulWidget> createState() {
    return _UserPermissionPageState();
  }
}

class _UserPermissionPageState extends State<UserPermissionsPage> {
  StreamSubscription<UserState> _errorListener;

  void _goToBanNewUserPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => SingleInputFieldPage(
              title: 'Ban New User',
              subtitle:
                  'Please enter the ucid of the user you would like to ban.',
              onSubmit: (String ucid) {
                widget._userBloc.sink.add(BanUser(ucid: ucid));
              },
              maxLines: 1,
            ),
      ),
    );
  }

  void _openRemoveBanDialog(String bannedUserUCID) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text(
                'Would you like to remove [' + bannedUserUCID + ']\'s ban?'),
            content: Text('Make a careful decision!'),
            actions: <Widget>[
              FlatButton(
                child: Text('Return'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  widget._userBloc.sink.add(UnbanUser(ucid: bannedUserUCID));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  Widget _buildBannedUsersList() {
    return StreamBuilder<UserState>(
      initialData: widget._userBloc.initialBannedState,
      stream: widget._userBloc.bannedUsers,
      builder: (BuildContext context, AsyncSnapshot<UserState> snapshot) {
        UserState state = snapshot.data;
        if (state is BannedUsersError) {
          return Center(child: Text('There was an error! Whoopsy-daisy!'));
        } else if (state is BannedUsersLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is BannedUsersLoaded) {
          List<User> bannedUsers = state.bannedUsers;
          if (bannedUsers.length == 0) {
            return Center(child: Text('No banned users currently!'));
          }

          return ListView.builder(
            itemCount: bannedUsers.length,
            itemBuilder: (BuildContext context, int index) {
              User bannedUser = bannedUsers[index];
              return ListTile(
                title: Text(bannedUser.ucid),
                trailing: IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _openRemoveBanDialog(bannedUser.ucid);
                  },
                ),
              );
            },
          );
        } else {
          return Center(child: Text('How\'d you get here? Mysterious...!'));
        }
      },
    );
  }

  Widget _buildBody() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text('Admins'),
          //TODO build admin section
          //_buildAdminsSection();
          Divider(color: Colors.black),
          Row(
            children: <Widget>[
              Text('Banned Users'),
              IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                  _goToBanNewUserPage();
                },
              ),
            ],
          ),
          SingleChildScrollView(
            child: Container(
              height: 200,
              child: _buildBannedUsersList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _errorListener = widget._userBloc.bannedUsers.listen((dynamic state) {
      if (state is BannedUsersError) {
        showDialog(
          context: context,
          builder: (BuildContext context) => ErrorDialog(
              errorMsg: 'An error occurred when banning or unbanning user.'),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.lightBlue[50],
        centerTitle: true,
        title: Text('User Permissions', style: TextStyle(color: Colors.black)),
      ),
      body: _buildBody(),
    );
  }

  @override
  void dispose() {
    _errorListener.cancel();
    super.dispose();
  }
}
