import 'package:flutter/material.dart';

import './organization_widgets.dart';
import './register_org.dart';
import './inactive_organizations.dart';

import '../../blocs/organization_bloc.dart';
import '../../blocs/event_bloc.dart';
import '../../blocs/edit_bloc.dart';
import '../../blocs/favorite_rsvp_bloc.dart';
import '../../models/organization.dart';

class OrganizationPage extends StatefulWidget {
  final OrganizationBloc _organizationBloc;
  final FavoriteAndRSVPBloc _favoriteAndRSVPBloc;
  final EditEventBloc _editBloc;
  final EventBloc _eventBloc;
  final String _ucid;

  OrganizationPage(
      {@required FavoriteAndRSVPBloc favoriteAndRSVPBloc,
      @required OrganizationBloc organizationBloc,
      @required EditEventBloc editBloc,
      @required EventBloc eventBloc,
      @required String ucid})
      : _organizationBloc = organizationBloc,
        _editBloc = editBloc,
        _favoriteAndRSVPBloc = favoriteAndRSVPBloc,
        _eventBloc = eventBloc,
        _ucid = ucid;

  @override
  State<StatefulWidget> createState() {
    return _OrganizationPageState();
  }
}

class _OrganizationPageState extends State<OrganizationPage> {
  List<int> _colors;
  int _colorIdx;

  StreamBuilder _buildOrganizationCards() {
    return StreamBuilder<OrganizationState>(
      stream: widget._organizationBloc.viewableOrganizations,
      initialData: widget._organizationBloc.viewableOrgsInitialState,
      builder:
          (BuildContext context, AsyncSnapshot<OrganizationState> snapshot) {
        OrganizationState state = snapshot.data;
        if (state is OrganizationsLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is OrganizationsLoaded) {
          List<Organization> orgs = state.organizations;
          if (orgs.length == 0)
            return Center(child: Text('No active organizations currently!'));

          List<OrganizationCard> cards = List<OrganizationCard>();
          for (Organization org in orgs) {
            cards.add(
              OrganizationCard(
                favoriteAndRSVPBloc: widget._favoriteAndRSVPBloc,
                editBloc: widget._editBloc,
                eventBloc: widget._eventBloc,
                organizationBloc: widget._organizationBloc,
                organization: org,
                ucid: widget._ucid,
                color: Color(_colors[_colorIdx++%_colors.length]),
              ),
            );
          }

          return Container(
            height: 500,
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (BuildContext context, int index) {
                return cards[index];
              },
            ),
          );
        } else if (state is OrganizationError) {
          print("org error: " + state.errorMsg);
          return Text('An error occurred!');
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _colors = [
      0xffffdde2,
      0xffFFFFCC,
      0xffdcf9ec,
      0xffFFFFFF,
      0xffF0F0F0,
    ];
    _colorIdx = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text('Organizations'),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.black87,
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Text('Don\'t see yours?'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            RegisterOrganizationPage(
                              organizationBloc: widget._organizationBloc,
                            ),
                      ),
                    );
                  },
                ),
                Text('or'),
                FlatButton(
                  child: Text(
                    'Reactivate',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            InactiveOrganizationsPage(
                                organizationBloc: widget._organizationBloc),
                      ),
                    );
                  },
                ),
                Text('an organization'),
              ],
            ),
            SizedBox(height: 10),
            _buildOrganizationCards(),
          ],
        ),
      ),
    );
  }
}
