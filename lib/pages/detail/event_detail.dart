import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../blocs/edit_bloc.dart';
import '../../blocs/rsvp_bloc.dart';

import '../../models/category.dart';
import '../../models/event.dart';

import '../edit/edit.dart';

class EventDetailPage extends StatefulWidget {
  final RSVPBloc _rsvpBloc;
  final EditEventBloc _editBloc;
  final Event _event;
  final Function _canEdit;

  EventDetailPage({
    @required Event event,
    @required Function canEdit,
    @required EditEventBloc editBloc,
    @required RSVPBloc rsvpBloc,
  })  : _canEdit = canEdit,
        _event = event,
        _editBloc = editBloc,
        _rsvpBloc = rsvpBloc;

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
            builder: (BuildContext context) =>
                EditPage(event: widget._event, editBloc: widget._editBloc),
          ),
        );
      },
    );
  }

  Widget _buildRSVPButton() {
    List<Widget> rowWidgets = List<Widget>();
    bool rsvpd = widget._event.rsvpd;
    if (!rsvpd) {
      rowWidgets = [
        Icon(
          Icons.add,
          color: Colors.white,
        ),
        Text(
          'RSVP',
          style: TextStyle(color: Colors.white),
        ),
      ];
    } else {
      rowWidgets = [
        Icon(
          Icons.remove,
          color: Colors.white,
        ),
        Text(
          'Remove RSVP',
          style: TextStyle(color: Colors.white),
        ),
      ];
    }
    return FlatButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: rowWidgets,
      ),
      color: rsvpd ? Colors.red : Colors.green,
      onPressed: () {
        if (rsvpd) {
          setState(() {
            widget._rsvpBloc.sink.add(RemoveRSVP(eventToUnRSVP: widget._event));
          });
        } else {
          setState(() {
            widget._rsvpBloc.sink.add(AddRSVP(eventToRSVP: widget._event));
          });
        }
      },
    );
  }

  void _showWhosGoingDialog(List<String> ucids) {
    List<Widget> whosGoingWidgets = List<Widget>();
    int i = 0;
    for (String ucid in ucids) {
      whosGoingWidgets.add(Text(
        (++i).toString() + ") " + ucid,
        textAlign: TextAlign.left,
      ));
    }
    if (ucids == null || ucids.length == 0) {
      whosGoingWidgets.add(Text('No one 😞'));
    }

    if (!_canEdit) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Permission denied, sorry! (◕‿◕✿)'),
              content: Text(
                  'You have to be an E-Board member of the organization [' +
                      widget._event.organization +
                      '] to see who is going to this event! '),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Who\'s going?'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: whosGoingWidgets,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('RETURN'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      );
    }
  }

  Widget _buildRSVPSection() {
    return StreamBuilder<RSVPState>(
        initialData: widget._rsvpBloc.eventRSVPInitialState,
        stream: widget._rsvpBloc.eventRSVPRequests,
        builder: (BuildContext context, AsyncSnapshot<RSVPState> snapshot) {
          RSVPState state = snapshot.data;
          List<String> ucids = List<String>();
          List<TextSpan> numPeopleRSVPdText = List<TextSpan>();
          numPeopleRSVPdText.add(TextSpan(
              text: 'So far, ', style: TextStyle(color: Colors.black)));
          numPeopleRSVPdText
              .add(TextSpan(text: '(', style: TextStyle(color: Colors.red)));
          if (state is EventRSVPsUpdating) {
            return Center(child: CircularProgressIndicator());
          } else if (state is EventRSVPsUpdated) {
            ucids = state.ucids;
            int numUCIDs = ucids == null ? 0 : ucids.length;
            numPeopleRSVPdText.add(TextSpan(
                text: numUCIDs.toString(),
                style: TextStyle(color: Colors.blue)));
            numPeopleRSVPdText
                .add(TextSpan(text: ') ', style: TextStyle(color: Colors.red)));
            numPeopleRSVPdText.add(TextSpan(
                text: (numUCIDs == 1 ? 'person' : 'people') + ' RSVP\'d! ☺️',
                style: TextStyle(color: Colors.black)));
          } else {
            numPeopleRSVPdText
                .add(TextSpan(text: '0', style: TextStyle(color: Colors.blue)));
            numPeopleRSVPdText
                .add(TextSpan(text: ') ', style: TextStyle(color: Colors.red)));
            numPeopleRSVPdText.add(TextSpan(
                text: 'people RSVP\'d! ☺️',
                style: TextStyle(color: Colors.black)));
          }

          return FlatButton(
            child: RichText(text: TextSpan(children: numPeopleRSVPdText)),
            onPressed: () {
              _showWhosGoingDialog(ucids);
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _canEdit = false;
    widget._rsvpBloc.sink.add(FetchEventRSVPs(event: widget._event));

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
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            _buildRSVPSection(),
            SizedBox(height: 10),
            _buildRSVPButton(),
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
            Text(
              widget._event.location,
              textAlign: TextAlign.center,
            ),
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
