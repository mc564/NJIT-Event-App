import 'dart:async';
import '../providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

//manages user and authentication
class UserBloc {
  final StreamController<UserState> _userController;
  final AuthProvider _authProvider;
  UserState _prevState;

  UserBloc()
      : _authProvider = AuthProvider(),
        _userController = StreamController.broadcast(),
        _prevState = UserAuthInitial(authenticated: false) {
    _userController.stream.listen((UserState state) {
      _prevState = state;
    });
  }

  UserState get initialState => _prevState;

  Stream get userRequests => _userController.stream;

  void setUCID(String ucid) {
    _authProvider.setUCID(ucid);
  }

  void setPassword(String password) {
    _authProvider.setPassword(password);
  }

  //runs once every time the program is reopened
  void autoAuthenticate() async {
    try {
      _userController.sink.add(UserAuthLoading());
      bool authenticated = await _authProvider.autoAuthenticate();
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
      bool authenticated = await _authProvider.authenticate();
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
      _authProvider.logout();
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
