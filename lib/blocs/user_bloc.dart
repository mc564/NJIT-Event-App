import 'dart:async';
import '../providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../models/user.dart';

//manages user and authentication
class UserBloc {
  final StreamController<UserState> _userController;
  final UserProvider _userProvider;
  UserState _prevState;

  UserBloc()
      : _userProvider = UserProvider(),
        _userController = StreamController.broadcast(),
        _prevState = UserAuthInitial(authenticated: false) {
    _userController.stream.listen((UserState state) {
      _prevState = state;
    });
  }

  String get name => _userProvider.name;
  String get ucid => _userProvider.ucid;

  //just for use upon logging in - changes to the modeled items (favorites, users, organizations etc.) are handled in their respective blocs
  List<UserTypes> get initialUserTypes => _userProvider.initialUserTypes;
  List<String> get initialFavoriteIds => _userProvider.initialFavoriteIds;
  Map<String, String> get initialOrgRoles => _userProvider.initialOrgRoles;

  UserState get initialState => _prevState;

  Stream get userRequests => _userController.stream;

  void setUCID(String ucid) {
    _userProvider.setAuthUCID(ucid);
  }

  void setPassword(String password) {
    _userProvider.setAuthPassword(password);
  }

  //runs once every time the program is reopened
  void autoAuthenticate() async {
    try {
      _userController.sink.add(UserAuthLoading());
      bool authenticated = await _userProvider.autoAuthenticate();
      if (authenticated) {
        _userController.sink.add(UserAuthInitial(authenticated: true));
      } else {
        _userController.sink.add(UserAuthInitial(authenticated: false));
      }
      print('finished autoauthenticating! result is: ' +
          authenticated.toString());
    } catch (error) {
      _userController.sink.add(UserAuthError(error: error.toString()));
    }
  }

  void authenticate() async {
    try {
      _userController.sink.add(UserAuthLoading());
      bool authenticated = await _userProvider.authenticate();
      if (authenticated) {
        _userController.sink.add(UserAuthDone(authenticated: true));
      } else {
        _userController.sink.add(UserAuthDone(authenticated: false));
      }
      print('finished authenticating! result is: ' + authenticated.toString());
    } catch (error) {
      _userController.sink.add(UserAuthError(error: error.toString()));
    }
  }

  void logout() async {
    try {
      _userProvider.logout();
      _userController.sink.add(UserAuthInitial(authenticated: false));
    } catch (error) {
      _userController.sink.add(UserAuthError(error: error.toString()));
    }
  }

  void dispose() {
    _userController.close();
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
  final bool authenticated;
  UserAuthInitial({@required bool authenticated})
      : authenticated = authenticated,
        super([authenticated]);
}

class UserAuthLoading extends UserState {}

class UserAuthDone extends UserState {
  final bool authenticated;
  UserAuthDone({@required bool authenticated})
      : authenticated = authenticated,
        super([authenticated]);
}
