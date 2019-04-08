import 'dart:math' show pi;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../blocs/organization_bloc.dart';
import '../../blocs/event_bloc.dart';

import '../../models/organization.dart';
import '../../models/event.dart';

import '../../common/single_input_field.dart';

import './change_eboard_members.dart';
import './add_or_remove_members.dart';
import './modify_description.dart';

class OrganizationDetailPage extends StatefulWidget {
  final OrganizationBloc _organizationBloc;
  final EventBloc _eventBloc;
  final Organization _organization;
  final bool _isEboardMember;

  OrganizationDetailPage(
      {@required OrganizationBloc organizationBloc,
      @required EventBloc eventBloc,
      @required Organization organization,
      @required bool isEboardMember})
      : _organizationBloc = organizationBloc,
        _eventBloc = eventBloc,
        _organization = organization,
        _isEboardMember = isEboardMember;

  @override
  State<StatefulWidget> createState() {
    return _OrganizationDetailPageState();
  }
}

class _OrganizationDetailPageState extends State<OrganizationDetailPage> {
  void _showRequestsInProgressDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text('Sorry, there are requests in progress already!'),
              content: Text(
                  'Please wait for admin responses before submitting further requests. ☺'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  void _showEboardActionDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Dialog(
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Organization Settings',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.settings),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.black),
                    Text(
                      'E-Board Members',
                      style: TextStyle(fontSize: 18),
                    ),
                    FlatButton(
                      child: Text(
                        'Send A Change Of E-Board Members Request',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        if (widget._organizationBloc
                            .canSendOrganizationRequest(widget._organization)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ChangeOfEboardMembersPage(
                                    organization: widget._organization,
                                    organizationBloc: widget._organizationBloc,
                                  ),
                            ),
                          );
                        } else {
                          _showRequestsInProgressDialog();
                        }
                      },
                    ),
                    Divider(color: Colors.black),
                    Text(
                      'Regular Members',
                      style: TextStyle(fontSize: 20),
                    ),
                    FlatButton(
                      child: Text(
                        'Add/Remove Members',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  AddOrRemoveMembersPage(
                                      organizationBloc:
                                          widget._organizationBloc,
                                      organization: widget._organization)),
                        );
                      },
                    ),
                    Divider(color: Colors.black),
                    Text(
                      'General Settings',
                      style: TextStyle(fontSize: 18),
                    ),
                    FlatButton(
                      child: Text(
                        'Modify Description',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ModifyDescriptionPage(
                                    organizationBloc: widget._organizationBloc,
                                    organization: widget._organization),
                          ),
                        );
                      },
                    ),
                    FlatButton(
                      child: Text(
                        'Send A Request To Inactivate Group',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        if (widget._organizationBloc
                            .canSendOrganizationRequest(widget._organization)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (BuildContext context) {
//TODO change to actual page - I need to know if this actually succeeded or not
//so I can change the organization status and prevent sending a request again once
//an inactivation request has been sent
                              return SingleInputFieldPage(
                                  title: 'Send An Inactivation Request',
                                  subtitle:
                                      'Please provide a reason for this organization\'s inactivation.',
                                  onSubmit: (String reason) {
                                    widget._organizationBloc.sink.add(
                                        RequestOrganizationInactivation(
                                            organization: widget._organization,
                                            reason: reason));
                                  });
                            }),
                          );
                        } else {
                          _showRequestsInProgressDialog();
                        }
                      },
                    ),
                    Divider(color: Colors.black),
                    FlatButton(
                      child: Text(
                        'Return',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildEboardButton(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: Color(0xff990000),
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
        ),
        Positioned(
          top: 3,
          child: IconButton(
            iconSize: 25,
            icon: Icon(Icons.person),
            color: Colors.grey,
            onPressed: () {
              print('pressed!');
              _showEboardActionDialog(context);
            },
          ),
        ),
        Positioned(
          bottom: 15,
          right: 12,
          child: Transform.rotate(
            angle: -pi / 3,
            child: Icon(
              Icons.vpn_key,
              size: 14,
              color: Color(0xffFFD700),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    widget._eventBloc.sink
        .add(RefreshRecentEvents(organization: widget._organization));
  }

  String _eventTimeText(Event event) {
    DateFormat timeFormatter = DateFormat.jm();
    DateFormat dateFormatter = DateFormat('MMM d');
    DateTime now = DateTime.now();
    DateTime time = event.startTime;
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      //same day
      return timeFormatter.format(time);
    }
    return dateFormatter.format(time);
  }

  Widget _buildUpcomingEventsSection(EventListState state) {
    List<Widget> tiles = List<Widget>();
    if (state is EventListError) {
      tiles.add(
          ListTile(title: Text('There\'s been an error, please try again!')));
    } else if (state is EventListLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is RecentEventsLoaded) {
      List<Event> upcomingEvents = state.recentEvents.upcomingEvents;
      if (upcomingEvents == null || upcomingEvents.length == 0) {
        tiles.add(ListTile(
            title: Text('No upcoming events within the next 2 weeks. 😌')));
      } else {
        for (Event event in upcomingEvents) {
          tiles.add(
            ListTile(
              title: Text(event.title),
              subtitle: Text(_eventTimeText(event)),
              // trailing: Row(),
            ),
          );
        }
      }
    } else {
      //should never get here
      tiles.add(ListTile(
          title:
              Text('There\'s been a REAL 😕 error, please restart your app!')));
    }

    return Container(
      height: 300,
      child: ListView.builder(
        itemCount: tiles.length,
        itemBuilder: (BuildContext context, int index) {
          return tiles[index];
        },
      ),
    );
  }

  Widget _buildPastEventsSection(EventListState state) {
    List<Widget> tiles = List<Widget>();
    if (state is EventListError) {
      tiles.add(
          ListTile(title: Text('There\'s been an error, please try again!')));
    } else if (state is EventListLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is RecentEventsLoaded) {
      List<Event> pastEvents = state.recentEvents.pastEvents;
      if (pastEvents == null || pastEvents.length == 0) {
        tiles.add(
            ListTile(title: Text('No past events within the last week. 😌')));
      } else {
        for (Event event in pastEvents) {
          tiles.add(
            ListTile(
              title: Text(event.title),
              subtitle: Text(_eventTimeText(event)),
              // trailing: Row(),
            ),
          );
        }
      }
    } else {
      //should never get here
      tiles.add(ListTile(
          title:
              Text('There\'s been a REAL 😕 error, please restart your app!')));
    }
    return Container(
      height: 300,
      child: ListView.builder(
        itemCount: tiles.length,
        itemBuilder: (BuildContext context, int index) {
          return tiles[index];
        },
      ),
    );
  }

  StreamBuilder _buildRecentEventsSection() {
    return StreamBuilder<EventListState>(
      initialData: widget._eventBloc.recentEventsInitialState,
      stream: widget._eventBloc.recentEvents,
      builder: (BuildContext context, AsyncSnapshot<EventListState> snapshot) {
        EventListState state = snapshot.data;
        print(state.runtimeType.toString());
        return Column(
          children: <Widget>[
            Text('Upcoming Events', style: TextStyle(fontSize: 20)),
            _buildUpcomingEventsSection(state),
            Text('Past Events',
                style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
            _buildPastEventsSection(state),
          ],
        );
      },
    );
  }

  RichText _buildMembersSection() {
    List<OrganizationMember> eBoardMembers = widget._organization.eBoardMembers;
    List<OrganizationMember> regularMembers =
        widget._organization.regularMembers;
    List<TextSpan> children = List<TextSpan>();
    children
        .add(TextSpan(text: 'Members ', style: TextStyle(color: Colors.blue)));
    for (OrganizationMember eBoardMember in eBoardMembers) {
      children.add(TextSpan(
          text: '👑 ' + eBoardMember.ucid + ' ',
          style: TextStyle(color: Color(0xff800000))));
    }
    for (OrganizationMember regularMember in regularMembers) {
      children.add(TextSpan(
          text: '⚬ ' + regularMember.ucid + ' ',
          style: TextStyle(color: Colors.blue)));
    }
    return RichText(text: TextSpan(children: children));
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget._organization.name,
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  color: Colors.lightBlue,
                  icon: Icon(Icons.refresh),
                  onPressed: _refresh,
                ),
              ],
            ),
            _buildMembersSection(),
            /*
            SizedBox(height: 10),
            Text('E-Board Members:'),
            Container(
                height: 100,
                child: ListView.builder(
                  shrinkWrap: false,
                  itemCount: widget._organization.eBoardMembers.length,
                  itemBuilder: (BuildContext content, int index) {
                    return Text(
                      widget._organization.eBoardMembers[index].ucid,
                      textAlign: TextAlign.center,
                    );
                    //);
                  },
                )),
            SizedBox(height: 10),
            Text('Regular Members:'),
            Container(
                height: 100,
                child: ListView.builder(
                  shrinkWrap: false,
                  itemCount: widget._organization.regularMembers.length,
                  itemBuilder: (BuildContext content, int index) {
                    return Text(
                      widget._organization.regularMembers[index].ucid,
                      textAlign: TextAlign.center,
                    );
                  },
                )),
                */
            SizedBox(height: 10),
            Text(widget._organization.description),
            SizedBox(height: 10),
            _buildRecentEventsSection(),
          ],
        ),
      ),
    );
  }

  String _cutShort(String s, int length) {
    if (s.length <= length)
      return s;
    else
      return s.substring(0, length + 1) + "...";
  }

  @override
  void initState() {
    super.initState();
    widget._eventBloc.sink.add(FetchRecentEvents(organization: widget._organization));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_cutShort(widget._organization.name, 20)),
        actions: <Widget>[
          widget._isEboardMember ? _buildEboardButton(context) : Container(),
        ],
      ),
      body: _buildBody(),
    );
  }
}
