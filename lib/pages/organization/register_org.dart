import 'package:flutter/material.dart';
import './organization_widgets.dart';

class RegisterOrganizationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterOrganizationPageState();
  }
}

class _RegisterOrganizationPageState extends State<RegisterOrganizationPage> {
  GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
  }

  Column _buildEBoardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'E-Board Members',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text('(Must have at least 3 for consideration!)'),
        UCIDAndRoleFormField(),
      ],
    );
  }

  Column _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Organization Description',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
        TextFormField(
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          onSaved: (String value) {
            // widget._userBloc.setPassword(value);
          },
        ),
      ],
    );
  }

  Column _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Organization Name',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          onSaved: (String value) {
            // widget._userBloc.setPassword(value);
          },
        ),
      ],
    );
  }

  Form _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          _buildNameField(),
          SizedBox(height: 10),
          _buildDescriptionField(),
          SizedBox(height: 10),
          _buildEBoardSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Register An Organization'),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            margin: EdgeInsets.all(10),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }
}
