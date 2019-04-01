import 'package:flutter/material.dart';

class AuthenticationResults {
  final bool authenticated;
  final bool banned;

  AuthenticationResults({@required this.authenticated, @required this.banned});
}
