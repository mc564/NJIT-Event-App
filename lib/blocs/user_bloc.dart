import 'dart:async';
import '../providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../models/user.dart';
import '../models/authentication_results.dart';

//manages user and authentication
class UserBloc {
  final StreamController<UserState> _userAuthController;
  final StreamController<UserState> _bannedUsersController;
  final UserProvider _userProvider;
  UserState _prevAuthState;
  UserState _prevBannedState;

  UserBloc()
      : _userProvider = UserProvider(),
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
  }
}

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
