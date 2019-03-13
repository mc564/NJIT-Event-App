import 'package:flutter/material.dart';
import './pages/home/home.dart';
import './pages/login/login.dart';
import './blocs/user_bloc.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  UserBloc _userBloc;
  StreamSubscription _navigationListener;

  void _initializeNavigationListener(BuildContext buildContext) {
    _navigationListener = _userBloc.userRequests.listen((dynamic state) {
      if (state is UserAuthInitial) {
        _navigationListener.cancel();
        if (state.authenticated) {
          Navigator.of(buildContext).pushReplacementNamed('/home');
        } else {
          Navigator.of(buildContext).pushReplacementNamed('/login');
        }
      } else if (state is UserAuthDone) {
        _navigationListener.cancel();
        if (state.authenticated) {
          Navigator.of(buildContext).pushReplacementNamed('/home');
        } else {
          Navigator.of(buildContext).pushReplacementNamed('/login');
        }
      }
    });
  }

  @override
  void initState() {
    _userBloc = UserBloc();
    _userBloc.autoAuthenticate();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          //can only use the '/' route on startup...otherwise use either home or login route
          '/': (BuildContext context) =>
              Builder(builder: (BuildContext builderContext) {
                _initializeNavigationListener(builderContext);
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }),
          '/home': (BuildContext context) => HomePage(userBloc: _userBloc),
          '/login': (BuildContext context) => LoginPage(userBloc: _userBloc),
        });
  }

  @override
  void dispose() {
    _navigationListener.cancel();
    _userBloc.dispose();
    super.dispose();
  }
}
