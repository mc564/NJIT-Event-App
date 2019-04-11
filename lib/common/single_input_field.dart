import 'package:flutter/material.dart';
import './error_dialog.dart';

class SingleInputFieldPage extends StatefulWidget {
  final String _title;
  final String _subtitle;
  final Function _onSubmit;
  final int _maxLines;

  SingleInputFieldPage({
    @required String title,
    @required String subtitle,
    @required Function onSubmit,
    int maxLines = 5,
  })  : _title = title,
        _subtitle = subtitle,
        _onSubmit = onSubmit,
        _maxLines = maxLines;

  @override
  State<StatefulWidget> createState() {
    return _SingleInputFieldPageState();
  }
}

class _SingleInputFieldPageState extends State<SingleInputFieldPage> {
  TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget._title),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Text(widget._subtitle),
              TextField(
                controller: textController,
                maxLines: widget._maxLines,
              ),
              Row(
                children: <Widget>[
                  FlatButton(
                    child: Text('Return'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  FlatButton(
                    child: Text('Continue'),
                    onPressed: () {
                      String paragraph = textController.text;
                      if (paragraph == null || paragraph.length == 0) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              ErrorDialog(errorMsg: 'A response is required.'),
                        );
                        return;
                      }

                      widget._onSubmit(paragraph);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
