import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AdminPageState();
  }
}

class _AdminPageState extends State<AdminPage> {
  List<Widget> _buildSectionChildren(String title, List<String> linkedOptions) {
    List<Widget> children = List<Widget>();
    children.add(Text(title));
    for (String option in linkedOptions) {
      children.add(Text(option, style: TextStyle(color: Colors.blue)));
    }
    return children;
  }

  Widget _buildSection(String title, List<String> linkedOptions) {
    return Container(
      margin: EdgeInsets.all(10),
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildSectionChildren(title, linkedOptions),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Task Panel'),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Card(
                child: Column(
                  children: <Widget>[
                    _buildSection('Users', ['Review User Permissions']),
                    _buildSection('Events', ['Edit Events']),
                    _buildSection('Organizations', [
                      'Actions Pending Approval/Rejection',
                      'Review Organizations'
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
