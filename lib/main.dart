import 'package:flutter/material.dart';
import './pages/home/home.dart';
import './pages/login/login.dart';
import './blocs/user_bloc.dart';
import 'dart:async';
import './models/authentication_results.dart';
import './common/loading_squirrel.dart';

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

  void _navigate(BuildContext context, AuthenticationResults user) {
    _navigationListener.cancel();
    if (user.authenticated && !user.banned) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _initializeNavigationListener(BuildContext buildContext) {
    _navigationListener = _userBloc.userAuthRequests.listen((dynamic state) {
      if (state is UserAuthInitial) {
        _navigate(buildContext, state.authResults);
      } else if (state is UserAuthDone) {
        _navigate(buildContext, state.authResults);
      }
    });
  }

  @override
  void initState() {
    print('in main initstate');
    _userBloc = UserBloc();
    _userBloc.autoAuthenticate();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
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
                  body: LoadingSquirrel(),
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
