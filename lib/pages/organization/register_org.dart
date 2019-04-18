import 'dart:async';
import 'package:flutter/material.dart';
import './organization_widgets.dart';
import '../../blocs/organization_bloc.dart';
import '../../models/organization.dart';
import '../../common/success_dialog.dart';
import '../../common/error_dialog.dart';

//register or reactivate an organization
class RegisterOrganizationPage extends StatefulWidget {
  final OrganizationBloc _organizationBloc;
  final bool _reactivate;
  final Organization _orgToReactivate;

  RegisterOrganizationPage(
      {@required organizationBloc,
      bool reactivate = false,
      Organization orgToReactivate})
      : _organizationBloc = organizationBloc,
        _reactivate = reactivate,
        _orgToReactivate = orgToReactivate;

  @override
  State<StatefulWidget> createState() {
    return _RegisterOrganizationPageState();
  }
}

class _RegisterOrganizationPageState extends State<RegisterOrganizationPage> {
  GlobalKey<FormState> _formKey;
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  StreamSubscription<OrganizationState> _navigationListener;
  bool _initializedName;
  bool _initializedDescription;
  bool _built;
  bool _reactivate;
  List<int> _colors;
  int _colorIdx;

  @override
  void initState() {
    super.initState();
    _initializedName = false;
    _initializedDescription = false;
    _built = false;
    _reactivate = widget._reactivate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _built = true;
      if (_reactivate) {
        widget._organizationBloc.sink
            .add(SetOrganizationToEdit(organization: widget._orgToReactivate));
      } else {
        widget._organizationBloc.sink.add(ClearStorage());
      }
    });

    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _navigationListener = widget._organizationBloc.organizationUpdateRequests
        .listen((dynamic state) {
      if (state is OrganizationUpdated) {
        setState(() {
          _initializedName = false;
          _initializedDescription = false;
          _reactivate = false;
          widget._organizationBloc.sink.add(ClearStorage());
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              String successMsg;
              if (_reactivate) {
                successMsg =
                    'Your organization reactivation request has been submitted! Keep an eye out for an incoming message regarding the reactivation status!';
              } else {
                successMsg =
                    'Your organization registration has been submitted! Keep an eye out for an incoming message regarding the registration status!';
              }
              return SuccessDialog(successMsg);
            });
      } else if (state is OrganizationError) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return ErrorDialog(errorMsg: state.errorMsg);
            });
      }
    });
    _colors = [
      0xffffdde2,
      0xffFFFFCC,
      0xffdcf9ec,
      0xffFFFFFF,
      0xffF0F0F0,
    ];
    _colorIdx = 0;
  }

  Column _buildRegularMemberChips(List<OrganizationMember> regularMembers) {
    List<Chip> regularMemberChips = List<Chip>();
    for (OrganizationMember regularMember in regularMembers) {
      regularMemberChips.add(
        Chip(
          label: Text(
            regularMember.ucid + ' - Member',
          ),
          onDeleted: () {
            widget._organizationBloc.sink
                .add(RemoveRegularMember(ucid: regularMember.ucid));
          },
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: regularMemberChips,
    );
  }

  Column _buildRegularMemberSection(OrganizationState state) {
    List<OrganizationMember> regularMembers = List<OrganizationMember>();
    if (state is OrganizationUpdating) {
      regularMembers = state.organization.regularMembers;
    } else if (state is OrganizationBeforeUpdates) {
      regularMembers = state.organization.regularMembers;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Regular Members',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
            '(This is optional! You can include some members here if you would like!)'),
        UCIDAndRoleFormField(
          includeRole: false,
          colorUCID: Color(_colors[_colorIdx++ % _colors.length]),
          backgroundColor: Color(_colors[_colorIdx++ % _colors.length]),
          onSubmitted: (String ucid) {
            widget._organizationBloc.sink.add(AddRegularMember(ucid: ucid));
          },
          validator: widget._organizationBloc.regularMemberValidator,
        ),
        _buildRegularMemberChips(regularMembers),
      ],
    );
  }

  Column _buildEboardMemberChips(List<OrganizationMember> eBoardMembers) {
    List<Chip> eBoardMemberChips = List<Chip>();
    for (OrganizationMember eBoardMember in eBoardMembers) {
      eBoardMemberChips.add(
        Chip(
          label: Text(
            eBoardMember.ucid + ' - ' + eBoardMember.role,
          ),
          onDeleted: () {
            widget._organizationBloc.sink.add(RemoveEboardMember(
                ucid: eBoardMember.ucid, role: eBoardMember.role));
          },
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: eBoardMemberChips,
    );
  }

  Column _buildEBoardSection(OrganizationState state) {
    List<OrganizationMember> eBoardMembers = List<OrganizationMember>();
    if (state is OrganizationUpdating) {
      eBoardMembers = state.organization.eBoardMembers;
    } else if (state is OrganizationBeforeUpdates) {
      eBoardMembers = state.organization.eBoardMembers;
    }
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
        UCIDAndRoleFormField(
          colorRole: Color(_colors[_colorIdx++ % _colors.length]),
          colorUCID: Color(_colors[_colorIdx++ % _colors.length]),
          backgroundColor: Color(_colors[_colorIdx++ % _colors.length]),
          onSubmitted: (String ucid, String role) {
            print('submitted: ' + ucid + " " + role);
            widget._organizationBloc.sink
                .add(AddEboardMember(ucid: ucid, role: role));
          },
          validator: widget._organizationBloc.eBoardMemberValidator,
        ),
        _buildEboardMemberChips(eBoardMembers),
      ],
    );
  }

  Column _buildDescriptionField(OrganizationState state) {
    if (_built &&
        !_initializedDescription &&
        state is OrganizationBeforeUpdates) {
      String desc = state.organization.description;
      _descriptionController.text = desc;
      if (desc != null)
        _descriptionController.text = desc;
      else
        _descriptionController.text = '';
      _initializedDescription = true;
    }
    Color color = Color(_colors[_colorIdx++ % _colors.length]);
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
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: color,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 0),
            ),
          ),
          validator: widget._organizationBloc.descriptionValidator,
          onSaved: (String value) {
            widget._organizationBloc.sink
                .add(SetDescription(description: value));
          },
        ),
      ],
    );
  }

  Column _buildNameField(OrganizationState state) {
    if (_built && !_initializedName && state is OrganizationBeforeUpdates) {
      String name = state.organization.name;
      if (name != null)
        _nameController.text = name;
      else
        _nameController.text = '';
      _initializedName = true;
    }

    Color color = Color(_colors[_colorIdx++ % _colors.length]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          _reactivate ? 'Organization Name (fixed)' : 'Organization Name',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: _nameController,
          enabled: _reactivate ? false : true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 0),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: color, width: 0),
            ),
            filled: true,
            fillColor: color,
          ),
          validator: widget._organizationBloc.nameValidator,
          onSaved: (String value) {
            widget._organizationBloc.sink.add(SetName(name: value));
          },
        ),
      ],
    );
  }

  void _alertErrorsWithRegistration() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text('There are errors with your registration!'),
            content: Text('Please go back and try again!'),
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

  Widget _buildSubmitButton(OrganizationState state) {
    if (state is OrganizationUpdating) {
      return Center(child: CircularProgressIndicator());
    }
    return Center(
      child: FlatButton(
        color: Colors.blue,
        textColor: Colors.white,
        child: Text(
            _reactivate ? 'REACTIVATE ORGANIZATION' : 'REGISTER ORGANIZATION'),
        onPressed: () {
          if (!_formKey.currentState.validate()) {
            _alertErrorsWithRegistration();
            return;
          } else if (!widget._organizationBloc.enoughEBoardMembers) {
            showDialog(
                context: context,
                builder: (BuildContext context) => ErrorDialog(
                    errorMsg:
                        'Not enough eBoard members! (Need 3 at minimum)'));
            return;
          }
          _formKey.currentState.save();

          if (_reactivate) {
            widget._organizationBloc.sink.add(SubmitRequestForReactivation());
          } else {
            widget._organizationBloc.sink.add(SubmitOrganizationRegistration());
          }
          _formKey.currentState.reset();
        },
      ),
    );
  }

  StreamBuilder _buildForm() {
    return StreamBuilder<OrganizationState>(
      stream: widget._organizationBloc.organizationUpdateRequests,
      initialData: widget._organizationBloc.updatingOrgInitialState,
      builder:
          (BuildContext context, AsyncSnapshot<OrganizationState> snapshot) {
        OrganizationState state = snapshot.data;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 10),
              _buildNameField(state),
              SizedBox(height: 10),
              _buildDescriptionField(state),
              SizedBox(height: 10),
              _buildEBoardSection(state),
              SizedBox(height: 10),
              _buildRegularMemberSection(state),
              SizedBox(height: 10),
              _buildSubmitButton(state),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(_colors[_colorIdx++ % _colors.length]),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          _reactivate
              ? 'Reactivate An Organization'
              : 'Register An Organization',
          style: TextStyle(color: Colors.black),
        ),
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

  @override
  void dispose() {
    _navigationListener.cancel();
    super.dispose();
  }
}
