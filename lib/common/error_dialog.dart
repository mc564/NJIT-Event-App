import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {

  final String errorMsg;

  ErrorDialog({@required this.errorMsg});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
            title: Text('Something went wrong, please try again!'),
            content: Text('Error msg: '+errorMsg),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Okay'),
              )
            ],
          );
  }
}
