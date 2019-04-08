import 'package:flutter/material.dart';
import '../../blocs/user_bloc.dart';
import '../../common/error_dialog.dart';
import 'dart:async';
import '../../models/authentication_results.dart';

class LoginPage extends StatefulWidget {
  final UserBloc _userBloc;

  LoginPage({@required UserBloc userBloc}) : _userBloc = userBloc;

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

Widget _buildHeader() {
  return Container(
    width: 400,
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          height: 170,
          alignment: Alignment.topCenter,
          child: Image.asset('images/logo_white.png', width: 130),
        ),
        Container(
          height: 170,
          alignment: Alignment.bottomCenter,
          child: Image.asset('images/flag_garland.png', width: 250),
        ),
      ],
    ),
  );
}

class _LoginPageState extends State<LoginPage> {
  StreamSubscription _navigationListener;
  GlobalKey<FormState> _formKey;
  Widget _body;

  void _showErrorDialog(UserAuthError errorObject) {
    String error = errorObject.error;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(errorMsg: error);
      },
    );
  }

  void _showBannedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(
            errorMsg:
                'Sorry, you have been banned from the NJIT Event Planner App. Please contact one of our admins for further assistance.');
      },
    );
  }

  void _showInvalidLoginDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Credentials are wrong, please try again!'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget _buildLoginButton() {
    return StreamBuilder<UserState>(
      stream: widget._userBloc.userAuthRequests,
      initialData: widget._userBloc.initialAuthState,
      builder: (BuildContext context, AsyncSnapshot<UserState> snapshot) {
        UserState state = snapshot.data;
        print('new state in login is: ' + state.runtimeType.toString());

        if (state is UserAuthLoading) {
          print('in login auth loading so show a circular progress indicator!');
          return CircularProgressIndicator();
        } else if (state is! UserAuthInitial &&
            state is! UserAuthDone &&
            state is! UserAuthError) {
          //no state designated for this..
          return Text('something is really wrong, please reopen the app!');
        }
        return FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          color: Color(0xff0200ff),
          child: Text('LOG IN',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600)),
          onPressed: () {
            if (!_formKey.currentState.validate()) {
              return;
            }
            _formKey.currentState.save();
            widget._userBloc.sink.add(Authenticate());
          },
        );
      },
    );
  }

  Widget _buildUCIDField() {
    return TextFormField(
      style: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: 'UCID',
        labelStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600),
        errorStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF0000), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF0000), width: 1),
        ),
      ),
      validator: (String value) {
        if (value == null || value.isEmpty) {
          return 'UCID cannot be empty.';
        }
      },
      onSaved: (String value) {
        widget._userBloc.sink.add(SetUCID(ucid: value));
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      style: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600),
        errorStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF0000), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF0000), width: 1),
        ),
      ),
      obscureText: true,
      validator: (String value) {
        if (value == null || value.isEmpty) {
          return 'Password cannot be empty.';
        }
      },
      onSaved: (String value) {
        widget._userBloc.sink.add(SetPassword(password: value));
      },
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 20),
            margin: EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFF0000),
                  const Color(0xFF800000),
                ], // red to dark red
                tileMode: TileMode.clamp,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  _buildHeader(),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        _buildUCIDField(),
                        SizedBox(height: 10),
                        _buildPasswordField(),
                        SizedBox(height: 10),
                        _buildLoginButton(),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Image.asset('images/login.png', width: 250),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _navigationListener = widget._userBloc.userAuthRequests.listen((dynamic state) {
      if (state is UserAuthError) {
        _showErrorDialog(state);
      } else if (state is UserAuthDone) {
        UserAuthDone doneState = state;
        AuthenticationResults user = doneState.authResults;
        if (user.authenticated && !user.banned) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (user.authenticated && user.banned) {
          _showBannedDialog();
        } else {
          //rest of cases would not be authenticated
          _showInvalidLoginDialog();
        }
      } else if (state is UserAuthInitial) {
        if (state.authResults.authenticated && !state.authResults.banned) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding login page!');
    if (_body == null) _body = _buildBody();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF0000),
        title: Center(
          child: Text(
            'NJIT Event Planner',
            style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'Libre-Baskerville',
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: _body,
    );
  }

  @override
  void dispose() {
    _navigationListener.cancel();
    super.dispose();
  }
}
