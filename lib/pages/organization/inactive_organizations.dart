import 'package:flutter/material.dart';
import '../../blocs/organization_bloc.dart';
import '../../models/organization.dart';
import './register_org.dart';

class InactiveOrganizationsPage extends StatefulWidget {
  final OrganizationBloc _organizationBloc;

  InactiveOrganizationsPage({@required OrganizationBloc organizationBloc})
      : _organizationBloc = organizationBloc;

  @override
  State<StatefulWidget> createState() {
    return _InactiveOrganizationsPageState();
  }
}

class _InactiveOrganizationsPageState extends State<InactiveOrganizationsPage> {
  Widget _buildBody() {
    return StreamBuilder<OrganizationState>(
      initialData: widget._organizationBloc.inactiveOrgsInitialState,
      stream: widget._organizationBloc.inactiveOrganizations,
      builder:
          (BuildContext context, AsyncSnapshot<OrganizationState> snapshot) {
        OrganizationState state = snapshot.data;
        if (state is OrganizationsLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is OrganizationsLoaded) {
          List<Organization> orgs = state.organizations;
          if (orgs.length == 0)
            return Center(child: Text('No inactive organizations currently!'));

          List<ListTile> listTiles = List<ListTile>();
          for (Organization org in orgs) {
            listTiles.add(
              ListTile(
                  title: Text(org.name),
                  trailing: IconButton(
                    icon: Icon(Icons.open_in_new),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              RegisterOrganizationPage(
                                organizationBloc: widget._organizationBloc,
                                reactivate: true,
                                orgToReactivate: org,
                              ),
                        ),
                      );
                    },
                  )),
            );
          }

          return Container(
            height: 500,
            child: ListView.builder(
              itemCount: listTiles.length,
              itemBuilder: (BuildContext context, int index) {
                return listTiles[index];
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inactive Organizations'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }
}
