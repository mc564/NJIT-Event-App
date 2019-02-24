import 'package:flutter/material.dart';
import '../models/event.dart';
import './success_dialog.dart';

//similar event suggestions dialog
class SuggestionDialog extends StatelessWidget {
  Event _event;
  List<Event> _similarEvents;
  String _continuePrompt;
  Function _callback;

  SuggestionDialog(
      {@required Event event,
      @required List<Event> similarEvents,
      @required String continuePrompt,
      @required Function callback}) {
    _event = event;
    _similarEvents = similarEvents;
    _continuePrompt = continuePrompt;
    _callback = callback;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text('There are similar events logged in the system!\nDid you mean:'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: _similarEvents.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(_similarEvents[index].title),
            );
          },
        ),
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            //Navigator.of(context).pop();
            _callback(_event);
          },
          child: Text(_continuePrompt),
        )
      ],
    );
  }
}
