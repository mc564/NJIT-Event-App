import 'package:flutter/material.dart';
import './organization_widgets.dart';
import './register_org.dart';

class OrganizationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrganizationPageState();
  }
}

class _OrganizationPageState extends State<OrganizationPage> {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Don\'t see yours?'),
                FlatButton(
                  child: Text(
                    'Register an organization',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            RegisterOrganizationPage(),
                      ),
                    );
                    print('clicked');
                  },
                ),
              ],
            ),
            OrganizationCard(),
            OrganizationCard(),
            OrganizationCard(),
            OrganizationCard(),
          ],
        ),
      ),
    );
  }
}
