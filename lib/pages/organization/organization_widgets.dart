import 'package:flutter/material.dart';

class OrganizationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          height: 100,
          child: Column(
            children: <Widget>[
              Text('hi im a card'),
            ],
          ),
        ),
      ),
    );
  }
}

class UCIDAndRoleFormField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _UCIDAndRoleFormFieldState();
  }
}

class _UCIDAndRoleFormFieldState extends State<UCIDAndRoleFormField> {
  TextEditingController _ucidFieldController;
  TextEditingController _roleFieldController;

  @override
  void initState() {
    super.initState();
    _ucidFieldController = new TextEditingController();
    _roleFieldController = new TextEditingController();
  }

  void _alertInvalidInputs() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text('UCID or Role not entered!'),
            content: Text('Please try again!'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  IconButton _buildAddButton() {
    return IconButton(
      icon: Icon(Icons.add_circle, size: 30),
      onPressed: () {
        String role = _roleFieldController.text;
        String ucid = _ucidFieldController.text;
        if (role == null ||
            ucid == null ||
            role.length == 0 ||
            ucid.length == 0) {
          _alertInvalidInputs();
        } else {
          //submit
        }
      },
    );
  }

  Container _buildRoleField() {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 10),
      child: TextField(
        controller: _roleFieldController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'Role',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Container _buildUCIDField() {
    return Container(
      width: 100,
      margin: EdgeInsets.only(left: 10, right: 10),
      child: TextField(
        controller: _ucidFieldController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'UCID',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
        ),
        onSubmitted: (String value) {
          print('submitted: ' + _ucidFieldController.text);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
      ),
      child: Row(
        children: <Widget>[
          _buildUCIDField(),
          _buildRoleField(),
          _buildAddButton(),
        ],
      ),
    );
  }
}
