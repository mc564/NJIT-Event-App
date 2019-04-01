import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../edit/edit.dart';
import '../../models/category.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatefulWidget {
  final Event _event;
  final Function _canEdit;

  EventDetailPage({@required Event event, @required Function canEdit})
      : _canEdit = canEdit,
        _event = event;

  @override
  State<StatefulWidget> createState() {
    return _EventDetailPageState();
  }
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _canEdit;
  DateFormat dateFormatter;

  //if _canEdit is true
  Widget _buildEditPencilIcon(BuildContext context) {
    if (!_canEdit)
      return Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Text(
          '🐿️',
          style: TextStyle(fontSize: 25),
        ),
      );
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => EditPage(widget._event),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _canEdit = false;

    widget._canEdit(widget._event).then((bool canEdit) {
      if (canEdit) {
        if (mounted) {
          setState(() {
            _canEdit = true;
          });
        }
      }
    });
    dateFormatter = DateFormat("EEE, MMM d, ").add_jm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Event Details'),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text(
              widget._event.title,
              style: TextStyle(fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('by ' + widget._event.organization),
                SizedBox(width: 10),
                _buildEditPencilIcon(context),
              ],
            ),
            SizedBox(height: 10),
            Text(
                'Start Time: ' + dateFormatter.format(widget._event.startTime)),
            Text('End Time: ' + dateFormatter.format(widget._event.endTime)),
            SizedBox(height: 10),
            Text(widget._event.location),
            SizedBox(height: 10),
            Text(CategoryHelper.getString(widget._event.category)),
            SizedBox(height: 10),
            Text(widget._event.description),
          ],
        ),
      ),
    );
  }
}
