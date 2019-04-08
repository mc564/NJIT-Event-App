import 'dart:async';
import '../providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../models/user.dart';
import '../models/authentication_results.dart';

//manages user and authentication
class UserBloc {
  final StreamController<UserEvent> _requestsController;
  final StreamController<UserState> _userAuthController;
  final StreamController<UserState> _bannedUsersController;
  final UserProvider _userProvider;
  UserState _prevAuthState;
  UserState _prevBannedState;

  UserBloc()
      : _userProvider = UserProvider(),
        _requestsController = StreamController<UserEvent>.broadcast(),
        _userAuthController = StreamController<UserState>.broadcast(),
        _bannedUsersController = StreamController<UserState>.broadcast(),
        _prevAuthState = UserAuthInitial(
            authResults:
                AuthenticationResults(authenticated: false, banned: false)),
        _prevBannedState = BannedUsersLoading() {
    loadBannedUsers();
    _userAuthController.stream.listen((UserState state) {
      _prevAuthState = state;
    });
    _bannedUsersController.stream.listen((UserState state) {
      _prevBannedState = state;
    });
    _requestsController.stream.forEach((UserEvent event) {
      event.execute(this);
    });
  }

  String get name => _userProvider.name;
  String get ucid => _userProvider.ucid;
  UserProvider get userProvider => _userProvider;

  //just for use upon logging in - changes to the modeled items (favorites, users, organizations etc.) are handled in their respective blocs
  List<UserTypes> get userTypes => _userProvider.userTypes;

  UserState get initialAuthState => _prevAuthState;
  UserState get initialBannedState => _prevBannedState;

  Stream get userAuthRequests => _userAuthController.stream;
  Stream get bannedUsers => _bannedUsersController.stream;
  StreamSink<UserEvent> get sink => _requestsController.sink;

  void setUCID(String ucid) {
    _userProvider.setAuthUCID(ucid);
  }

  void setPassword(String password) {
    _userProvider.setAuthPassword(password);
  }

  //runs once every time the program is reopened
  void autoAuthenticate() async {
    try {
      _userAuthController.sink.add(UserAuthLoading());
      AuthenticationResults authResults =
          await _userProvider.autoAuthenticate();
      _userAuthController.sink.add(UserAuthInitial(authResults: authResults));
      print('finished autoauthenticating! result is: ' +
          authResults.authenticated.toString());
    } catch (error) {
      _userAuthController.sink.add(UserAuthError(error: error.toString()));
    }
  }

  void authenticate() async {
    try {
      _userAuthController.sink.add(UserAuthLoading());
      AuthenticationResults authResults = await _userProvider.authenticate();
      _userAuthController.sink.add(UserAuthDone(authResults: authResults));

      print('finished authenticating! result is: ' +
          authResults.authenticated.toString());
    } catch (error) {
      _userAuthController.sink.add(UserAuthError(error: error.toString()));
    }
  }

  void logout() async {
    try {
      _userProvider.logout();
      _userAuthController.sink.add(
        UserAuthInitial(
          authResults:
              AuthenticationResults(authenticated: false, banned: false),
        ),
      );
    } catch (error) {
      _userAuthController.sink.add(UserAuthError(error: error.toString()));
    }
  }

  void banUser(String ucid) async {
    try {
      _bannedUsersController.sink.add(BannedUsersLoading());
      bool successfullyBanned = await _userProvider.banUser(ucid);
      if (!successfullyBanned) {
        _bannedUsersController.sink
            .add(BannedUsersError(error: 'Failed to ban user.'));
        return;
      }
      List<User> bannedUsers = await _userProvider.fetchBannedUsers();
      _bannedUsersController.sink
          .add(BannedUsersLoaded(bannedUsers: bannedUsers));
    } catch (error) {
      _bannedUsersController.sink
          .add(BannedUsersError(error: error.toString()));
    }
  }

  void unbanUser(String ucid) async {
    try {
      _bannedUsersController.sink.add(BannedUsersLoading());
      bool successfullyUnbanned = await _userProvider.unbanUser(ucid);
      if (!successfullyUnbanned) {
        _bannedUsersController.sink
            .add(BannedUsersError(error: 'Failed to unban user.'));
        return;
      }
      List<User> bannedUsers = await _userProvider.fetchBannedUsers();
      _bannedUsersController.sink
          .add(BannedUsersLoaded(bannedUsers: bannedUsers));
    } catch (error) {
      _bannedUsersController.sink
          .add(BannedUsersError(error: error.toString()));
    }
  }

  void loadBannedUsers() async {
    try {
      _bannedUsersController.sink.add(BannedUsersLoading());
      List<User> bannedUsers = await _userProvider.fetchBannedUsers();
      _bannedUsersController.sink
          .add(BannedUsersLoaded(bannedUsers: bannedUsers));
    } catch (error) {
      _bannedUsersController.sink
          .add(BannedUsersError(error: error.toString()));
    }
  }

  void dispose() {
    _userAuthController.close();
    _bannedUsersController.close();
    _requestsController.close();
  }
}

/*USER BLOC input EVENTS */
abstract class UserEvent extends Equatable {
  UserEvent([List args = const []]) : super(args);
  void execute(UserBloc userBloc);
}

class SetUCID extends UserEvent {
  final String ucid;
  SetUCID({@required String ucid})
      : ucid = ucid,
        super([ucid]);
  void execute(UserBloc userBloc) {
    userBloc.setUCID(ucid);
  }
}

class SetPassword extends UserEvent {
  final String password;
  SetPassword({@required String password})
      : password = password,
        super([password]);
  void execute(UserBloc userBloc) {
    userBloc.setPassword(password);
  }
}

class AutoAuthenticate extends UserEvent {
  void execute(UserBloc userBloc) {
    userBloc.autoAuthenticate();
  }
}

class Authenticate extends UserEvent {
  void execute(UserBloc userBloc) {
    userBloc.authenticate();
  }
}

class Logout extends UserEvent {
  void execute(UserBloc userBloc) {
    userBloc.logout();
  }
}

class BanUser extends UserEvent {
  final String ucid;
  BanUser({@required String ucid})
      : ucid = ucid,
        super([ucid]);
  void execute(UserBloc userBloc) {
    userBloc.banUser(ucid);
  }
}

class UnbanUser extends UserEvent {
  final String ucid;
  UnbanUser({@required String ucid})
      : ucid = ucid,
        super([ucid]);
  void execute(UserBloc userBloc) {
    userBloc.unbanUser(ucid);
  }
}

class LoadBannedUsers extends UserEvent {
  void execute(UserBloc userBloc) {
    userBloc.loadBannedUsers();
  }
}

/* USER BLOC output STATES */
abstract class UserState extends Equatable {
  UserState([List args = const []]) : super(args);
}

class UserAuthError extends UserState {
  final String error;
  UserAuthError({@required String error})
      : error = error,
        super([error]);
}

//auth initial is different from authdone because
//auth initial is used for initial runs
//and the ui won't show errors if for example
//auth fails on startup and leads to a log in screen
//instead of autoauthenticating successfully
class UserAuthInitial extends UserState {
  final AuthenticationResults authResults;
  UserAuthInitial({@required AuthenticationResults authResults})
      : authResults = authResults,
        super([authResults]);
}

class UserAuthLoading extends UserState {}

class UserAuthDone extends UserState {
  final AuthenticationResults authResults;
  UserAuthDone({@required AuthenticationResults authResults})
      : authResults = authResults,
        super([authResults]);
}

class BannedUsersLoading extends UserState {}

class BannedUsersLoaded extends UserState {
  final List<User> bannedUsers;
  BannedUsersLoaded({@required List<User> bannedUsers})
      : bannedUsers = bannedUsers,
        super([bannedUsers]);
}

class BannedUsersError extends UserState {
  final String error;
  BannedUsersError({@required String error})
      : error = error,
        super([error]);
}
