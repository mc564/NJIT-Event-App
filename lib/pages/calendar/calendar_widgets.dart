import 'package:flutter/material.dart';

class EventMarkIcon extends StatelessWidget {
  final int _iconNumber;
  EventMarkIcon({@required int iconNumber}) : _iconNumber = iconNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(1000)),
          border: Border.all(color: Colors.blue, width: 2.0)),
      child: Text(_iconNumber.toString()),
    );
  }
}
