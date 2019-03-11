import 'package:flutter/material.dart';
import '../models/event.dart';

//similar event suggestions dialog
class SuggestionDialog extends StatelessWidget {
  final List<Event> _similarEvents;
  final String _continuePrompt;
  final Function _onSuggestionIgnored;

  SuggestionDialog(
      {@required List<Event> similarEvents,
      @required String continuePrompt,
      @required Function onSuggestionIgnored})
      : _similarEvents = similarEvents,
        _continuePrompt = continuePrompt,
        _onSuggestionIgnored = onSuggestionIgnored;
//^initializer list

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
            _onSuggestionIgnored();
          },
          child: Text(_continuePrompt),
        )
      ],
    );
  }
}
