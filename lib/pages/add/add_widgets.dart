import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../pages/edit/edit.dart';

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

  void _showEditInsteadOfAddDialog(BuildContext context, Event similarEvent) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text('Edit Instead Of Adding An Event?'),
            content: Text(
                'Please confirm you would like to edit this event instead of adding a new one'),
            actions: <Widget>[
              FlatButton(
                child: Text('Return'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              EditPage(similarEvent)));
                },
              ),
            ],
          ),
    );
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
            Event similarEvent = _similarEvents[index];
            return ListTile(
              title: Text(similarEvent.title),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showEditInsteadOfAddDialog(context, similarEvent);
                },
              ),
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
