import 'dart:async';
import 'dart:math' show pi;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../blocs/organization_bloc.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/favorite_bloc.dart';
import '../../blocs/edit_bloc.dart';

import '../../models/organization.dart';
import '../../models/event.dart';

import './change_eboard_members.dart';
import './add_or_remove_members.dart';
import './modify_description.dart';
import './inactivate_organization_reason.dart';

import '../detail/event_detail.dart';

class OrganizationDetailPage extends StatefulWidget {
  final OrganizationBloc _organizationBloc;
  final FavoriteBloc _favoriteBloc;
  final EventBloc _eventBloc;
  final EditEventBloc _editBloc;
  final Organization _organization;
  final bool _isEboardMember;

  OrganizationDetailPage(
      {@required OrganizationBloc organizationBloc,
      @required FavoriteBloc favoriteBloc,
      @required EventBloc eventBloc,
      @required EditEventBloc editBloc,
      @required Organization organization,
      @required bool isEboardMember})
      : _organizationBloc = organizationBloc,
        _favoriteBloc = favoriteBloc,
        _editBloc = editBloc,
        _eventBloc = eventBloc,
        _organization = organization,
        _isEboardMember = isEboardMember;

  @override
  State<StatefulWidget> createState() {
    return _OrganizationDetailPageState();
  }
}

class _OrganizationDetailPageState extends State<OrganizationDetailPage> {
  StreamSubscription<FavoriteState> _favoriteErrorSubscription;
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
                              return InactivateOrganizationReasonPage(
                                organizationBloc: widget._organizationBloc,
                                organizationToInactivate: widget._organization,
                              );
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

  ListTile _buildEventTile(Event event) {
    return ListTile(
      title: Text(
        _cutShort(event.title, 35),
      ),
      subtitle: Text(_eventTimeText(event)),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                event.favorited ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: () {
                if (event.favorited) {
                  widget._favoriteBloc.sink
                      .add(RemoveFavorite(eventToUnfavorite: event));
                } else {
                  widget._favoriteBloc.sink
                      .add(AddFavorite(eventToFavorite: event));
                }
                setState(() {});
              },
            ),
            IconButton(
              icon: Icon(
                Icons.info,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => EventDetailPage(
                        event: event,
                        canEdit: widget._organizationBloc.canEdit,
                        editBloc: widget._editBloc),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildUpcomingEventsSection(EventListState state) {
    List<Widget> tiles = List<Widget>();
    tiles.add(
      ListTile(
        title: Text(
          'Upcoming Events',
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ),
    );
    if (state is EventListError) {
      tiles.add(
          ListTile(title: Text('There\'s been an error, please try again!')));
    } else if (state is EventListLoading) {
      tiles.add(Center(child: CircularProgressIndicator()));
    } else if (state is RecentEventsLoaded) {
      List<Event> upcomingEvents = state.recentEvents.upcomingEvents;
      if (upcomingEvents == null || upcomingEvents.length == 0) {
        tiles.add(ListTile(
            title: Text('No upcoming events within the next 2 weeks. 😌')));
      } else {
        for (Event event in upcomingEvents) {
          tiles.add(_buildEventTile(event));
        }
      }
    } else {
      //should never get here
      tiles.add(ListTile(
          title:
              Text('There\'s been a REAL 😕 error, please restart your app!')));
    }

    return tiles;
  }

  List<Widget> _buildPastEventsSection(EventListState state) {
    List<Widget> tiles = List<Widget>();
    tiles.add(
      ListTile(
        title: Text(
          'Past Events',
          style: TextStyle(fontSize: 18, color: Colors.blue),
        ),
      ),
    );
    if (state is EventListError) {
      tiles.add(
          ListTile(title: Text('There\'s been an error, please try again!')));
    } else if (state is EventListLoading) {
      tiles.add(Center(child: CircularProgressIndicator()));
    } else if (state is RecentEventsLoaded) {
      List<Event> pastEvents = state.recentEvents.pastEvents;
      if (pastEvents == null || pastEvents.length == 0) {
        tiles.add(
            ListTile(title: Text('No past events within the last week. 😌')));
      } else {
        for (Event event in pastEvents) {
          tiles.add(_buildEventTile(event));
        }
      }
    } else {
      //should never get here
      tiles.add(ListTile(
          title:
              Text('There\'s been a REAL 😕 error, please restart your app!')));
    }
    return tiles;
  }

  List<Widget> _buildRecentEventsSection(EventListState state) {
    List<Widget> widgets = List<Widget>();
    widgets.addAll(_buildUpcomingEventsSection(state));
    widgets.addAll(_buildPastEventsSection(state));
    return widgets;
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
          text: '👑 ' + eBoardMember.ucid + ' - ' + eBoardMember.role + ' ',
          style: TextStyle(color: Color(0xff800000))));
    }
    for (OrganizationMember regularMember in regularMembers) {
      children.add(TextSpan(
          text: '⚬ ' + regularMember.ucid + ' ',
          style: TextStyle(color: Colors.blue)));
    }
    return RichText(text: TextSpan(children: children));
  }

  List<Widget> _buildChildren(EventListState state) {
    List<Widget> children = List<Widget>();
    children.addAll([
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
      SizedBox(height: 10),
      Text(widget._organization.description),
      SizedBox(height: 10),
    ]);
    children.addAll(_buildRecentEventsSection(state));
    return children;
  }

  Widget _buildBody() {
    return StreamBuilder<EventListState>(
      initialData: widget._eventBloc.recentEventsInitialState,
      stream: widget._eventBloc.recentEvents,
      builder: (BuildContext context, AsyncSnapshot<EventListState> snapshot) {
        return SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(10),
            child: Column(
              children: _buildChildren(snapshot.data),
            ),
          ),
        );
      },
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
    widget._eventBloc.sink
        .add(FetchRecentEvents(organization: widget._organization));
    _favoriteErrorSubscription =
        widget._favoriteBloc.favoriteSettingErrors.listen((dynamic state) {
      //recieve any favorite setting errors? rollback favorite status by setting state
      setState(() {});
    });
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

  @override
  void dispose() {
    _favoriteErrorSubscription.cancel();
    super.dispose();
  }
}
