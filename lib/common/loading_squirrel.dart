import 'package:flutter/material.dart';

class LoadingSquirrel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset('images/squirrel_running.gif'),
          SizedBox(height: 30),
          Text('Loading...please wait!'),
        ],
      ),
    );
  }
}
