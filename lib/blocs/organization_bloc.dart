import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../providers/organization_provider.dart';
import '../providers/update_organization_provider.dart';

import '../providers/message_provider.dart';
import '../providers/user_provider.dart';

import '../models/organization.dart';
import '../models/event.dart';
import '../models/user.dart';

//manages the organizations
class OrganizationBloc {
  //stream for org editing (change description, edit members etc.) and registration requests
  final StreamController<OrganizationState> _orgUpdatingController;
  //stream for active organizations
  final StreamController<OrganizationState> _viewableOrgsController;
  //stream for organizations awaiting approval
  final StreamController<OrganizationState> _awaitingApprovalOrgsController;

  final StreamController<OrganizationState> _awaitingEboardChangeOrgsController;

  //general organization related functions in this provider
  final OrganizationProvider _orgProvider;
  //the below provider does everything from registering to editing eboard members, all form stuff, etc.
  final UpdateOrganizationProvider _updateOrgProvider;
  //these 2 are used to send messages
  final MessageProvider _messageProvider;
  final UserProvider _userProvider;
  final String _ucid;
  final bool _isAdmin;

  OrganizationState _prevUpdatedOrgState;
  OrganizationState _prevViewableOrgsState;
  OrganizationState _prevAwaitingApprovalOrgsState;
  OrganizationState _prevAwaitingEboardChangeOrgsState;

  OrganizationBloc(
      {@required MessageProvider messageProvider,
      @required UserProvider userProvider})
      : _messageProvider = messageProvider,
        _userProvider = userProvider,
        _orgProvider = OrganizationProvider(),
        _updateOrgProvider = UpdateOrganizationProvider(),
        _orgUpdatingController =
            StreamController<OrganizationState>.broadcast(),
        _viewableOrgsController =
            StreamController<OrganizationState>.broadcast(),
        _awaitingApprovalOrgsController =
            StreamController<OrganizationState>.broadcast(),
        _awaitingEboardChangeOrgsController =
            StreamController<OrganizationState>.broadcast(),
        _ucid = userProvider.ucid,
        _isAdmin = userProvider.userTypes.contains(UserTypes.Admin) {
    _prevUpdatedOrgState = OrganizationBeforeUpdates(
        organization: _updateOrgProvider.organization);
    fetchViewableOrgs();
    fetchOrgsAwaitingApproval();
    fetchOrgsAwaitingEboardChange();
    _orgUpdatingController.stream.listen((OrganizationState state) {
      _prevUpdatedOrgState = state;
    });
    _viewableOrgsController.stream.listen((OrganizationState state) {
      _prevViewableOrgsState = state;
    });
    _awaitingApprovalOrgsController.stream.listen((OrganizationState state) {
      _prevAwaitingApprovalOrgsState = state;
    });
    _awaitingEboardChangeOrgsController.stream
        .listen((OrganizationState state) {
      _prevAwaitingEboardChangeOrgsState = state;
    });
  }

  OrganizationState get updatingOrgInitialState => _prevUpdatedOrgState;
  OrganizationState get viewableOrgsInitialState => _prevViewableOrgsState;
  OrganizationState get orgsAwaitingApprovalInitialState =>
      _prevAwaitingApprovalOrgsState;
  OrganizationState get orgsAwaitingEboardChangeInitialState =>
      _prevAwaitingEboardChangeOrgsState;

  Function get reasonValidator => _updateOrgProvider.reasonValidator;
  Function get nameValidator => _updateOrgProvider.nameValidator;
  Function get descriptionValidator => _updateOrgProvider.descriptionValidator;
  Function get eBoardMemberValidator =>
      _updateOrgProvider.eBoardMemberValidator;
  Function get regularMemberValidator =>
      _updateOrgProvider.regularMemberValidator;
  bool get enoughEBoardMembers => _updateOrgProvider.enoughEBoardMembers();

  Stream get organizationUpdateRequests => _orgUpdatingController.stream;
  Stream get viewableOrganizations => _viewableOrgsController.stream;
  Stream get organizationsAwaitingApproval =>
      _awaitingApprovalOrgsController.stream;
  Stream get organizationsAwaitingEboardChange =>
      _awaitingEboardChangeOrgsController.stream;

  OrganizationProvider get organizationProvider => _orgProvider;

  Future<bool> canEdit(Event event) async {
    return _orgProvider.canEdit(_ucid, _isAdmin, event);
  }

  //can't send a request if one is in progress
  Future<bool> canSendOrganizationRequest(Organization organization) async {
    return _orgProvider.canSendOrganizationRequest(organization);
  }

  /* FETCH METHODS FOR DIFFERENT TYPES OF ORGS - CAN BE USED BY USERS TO REFRESH BLOC DATA */

  void fetchViewableOrgs() async {
    try {
      _viewableOrgsController.sink.add(OrganizationsLoading());
      List<Organization> activeOrgs =
          await _orgProvider.allViewableOrganizations();
      _viewableOrgsController.sink
          .add(OrganizationsLoaded(organizations: activeOrgs));
    } catch (error) {
      _viewableOrgsController.sink.add(OrganizationError(
          errorMsg: 'Error in organization BLOC fetchViewableOrgs method: ' +
              error.toString()));
    }
  }

  void fetchOrgsAwaitingApproval() async {
    try {
      _awaitingApprovalOrgsController.sink.add(OrganizationsLoading());
      List<Organization> awaitingApproval =
          await _orgProvider.allOrganizationsAwaitingApproval();
      _awaitingApprovalOrgsController.sink
          .add(OrganizationsLoaded(organizations: awaitingApproval));
    } catch (error) {
      _awaitingApprovalOrgsController.sink.add(OrganizationError(
          errorMsg:
              'Error in organization BLOC fetchOrgsAwaitingApproval method: ' +
                  error.toString()));
    }
  }

  void fetchOrgsAwaitingEboardChange() async {
    try {
      _awaitingEboardChangeOrgsController.sink.add(OrganizationsLoading());
      List<OrganizationUpdateRequestData> awaitingEboardChange =
          await _orgProvider.allOrganizationsAwaitingEboardChange();
      _awaitingEboardChangeOrgsController.sink.add(
          OrganizationUpdateRequestsLoaded(requestData: awaitingEboardChange));
    } catch (error) {
      _awaitingEboardChangeOrgsController.sink.add(OrganizationError(
          errorMsg:
              'Error in organization BLOC fetchOrgsAwaitingEboardChange method: ' +
                  error.toString()));
    }
  }

  /* ORGANIZATION REGISTRATION AND EDITING FORM SETTERS */

  //basically clears the provider (used in initState by ui)
  //so that every form can start from a clear slate
  void clearStorage() {
    _updateOrgProvider.clear();
  }

  void alertOrganizationChanged() {
    _orgUpdatingController.sink.add(OrganizationBeforeUpdates(
        organization: _updateOrgProvider.organization));
  }

  void setOrgToEdit(Organization org) {
    _updateOrgProvider.setOrganizationToEdit(org);
    alertOrganizationChanged();
  }

  void setReasonForUpdate(String reason) {
    _updateOrgProvider.setReason(reason);
    alertOrganizationChanged();
  }

  void setName(String name) {
    _updateOrgProvider.setName(name);
    alertOrganizationChanged();
  }

  void setDescription(String description) {
    _updateOrgProvider.setDescription(description);
    alertOrganizationChanged();
  }

  void addEboardMember(String ucid, String role) {
    _updateOrgProvider.addEboardMember(ucid, role);
    alertOrganizationChanged();
  }

  void removeEboardMember(String ucid, String role) {
    _updateOrgProvider.removeEboardMember(ucid, role);
    alertOrganizationChanged();
  }

  void addRegularMember(String ucid) {
    _updateOrgProvider.addRegularMember(ucid);
    alertOrganizationChanged();
  }

  void removeRegularMember(String ucid) {
    _updateOrgProvider.removeRegularMember(ucid);
    alertOrganizationChanged();
  }

  /* ORGANIZATION REGISTRATION FUNCTIONS */

  Future<bool> _sendMessageToAdminsAboutRegistration(
      Organization orgRegistered) async {
    try {
      String orgName = orgRegistered.name;
      DateFormat expirationFormatter = new DateFormat('yyyy-MM-dd');
      DateFormat registrationDateFormatter = new DateFormat('E, MMMM dd');
      DateTime curr = DateTime.now();
      DateTime expirationDate = curr.add(Duration(days: 14));
      String title = 'Please Approve Or Deny Organization Registration for [' +
          orgName +
          ']';
      String messageBody = 'User ' +
          _ucid +
          " requested registration of their organization " +
          orgName +
          " on " +
          registrationDateFormatter.format(curr) +
          ". Please review the request and respond with the appropriate action on the Administration page. " +
          " This message expires on " +
          expirationFormatter.format(expirationDate) +
          ".";
      bool messagesSent = await _messageProvider.sendMessageToAdmins(
          _ucid, title, messageBody, expirationDate);
      if (messagesSent) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error sending message alerting admins of organization registration: ' +
              error.toString());
    }
  }

  //updates registration stream
  void _alertRegistrationError(String errorMsg) {
    _orgUpdatingController.sink.add(OrganizationError(errorMsg: errorMsg));
  }

  void submitOrganizationRegistration() async {
    try {
      Organization orgToRegister = _updateOrgProvider.organization;
      _orgUpdatingController.sink
          .add(OrganizationRegistering(organization: orgToRegister));
      bool successfullyAdded = await _updateOrgProvider.registerOrganization();
      if (successfullyAdded) {
        bool successfullySentAdminAlerts =
            await _sendMessageToAdminsAboutRegistration(orgToRegister);
        if (!successfullySentAdminAlerts) {
          _alertRegistrationError(
              'Failed to send admins messages about registration, please try again!');
        } else {
          _orgUpdatingController.sink
              .add(OrganizationRegistered(organization: orgToRegister));
          _updateOrgProvider.clear();
        }
      } else {
        _alertRegistrationError(
            'Submitting organization registration failed, please try again!');
      }
    } catch (error) {
      _alertRegistrationError(
          'Submitting organization registration failed: ' + error.toString());
    }
  }

  /* ORGS AWAITING APPROVAL STREAM FUNCTIONS */

  void _alertAwaitApprovalError(String errorMsg) {
    _awaitingApprovalOrgsController.sink
        .add(OrganizationError(errorMsg: errorMsg));
  }

  Future<bool> _messageEBoardMembersAboutApproval(Organization org) async {
    try {
      String orgName = org.name;
      DateFormat dateFormatter = new DateFormat('E yyyy-MM-dd');
      DateTime now = DateTime.now();
      DateTime expiryDate = now.add(Duration(days: 14));
      List<String> recipientUCIDS = List<String>();
      for (OrganizationMember eBoardMember in org.eBoardMembers) {
        recipientUCIDS.add(eBoardMember.ucid);
      }
      String title = 'Your Registration For The Organization [' +
          orgName +
          '] Has Been Approved!';
      String messageBody = 'Congratulations, your organization ' +
          orgName +
          ' has been accepted into the NJIT Event Planner App as of ' +
          dateFormatter.format(now) +
          '! As an E-Board member, ' +
          'we thought you would like to know of this update. Thanks for your continued patronage! This message ' +
          'expires ' +
          dateFormatter.format(expiryDate) +
          '.';

      bool messagesSent = await _messageProvider.sendMessage(
          _ucid, recipientUCIDS, title, messageBody, expiryDate);
      if (messagesSent) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error sending message alerting eboard members of organization registration approval: ' +
              error.toString());
    }
  }

  Future<bool> _messageEBoardMembersAboutRejection(
      String reasonforRejection, Organization org) async {
    try {
      String orgName = org.name;
      DateFormat dateFormatter = new DateFormat('E yyyy-MM-dd');
      DateTime now = DateTime.now();
      DateTime expiryDate = now.add(Duration(days: 14));
      List<String> recipientUCIDS = List<String>();
      for (OrganizationMember eBoardMember in org.eBoardMembers) {
        recipientUCIDS.add(eBoardMember.ucid);
      }
      String title = 'Your Registration For The Organization [' +
          orgName +
          '] Has Been Rejected';
      String messageBody = 'Your organization ' +
          orgName +
          ' has been rejected from the NJIT Event Planner App as of ' +
          dateFormatter.format(now) +
          '. The reason for rejection is as followed: [ ' +
          reasonforRejection +
          ' ] As an E-Board member, ' +
          'we thought you would like to know of this update. Thank you for your attempt and we would be glad' +
          ' to look at any further organization registrations! This message ' +
          'expires ' +
          dateFormatter.format(expiryDate) +
          '.';

      bool messagesSent = await _messageProvider.sendMessage(
          _ucid, recipientUCIDS, title, messageBody, expiryDate);
      if (messagesSent) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error sending message alerting eboard members of organization registration rejection: ' +
              error.toString());
    }
  }

  //must assign eBoarod user types to users after their org has been approved
  Future<bool> _assignEboardMemberUserTypes(
      List<OrganizationMember> eBoardMembers) async {
    for (OrganizationMember eBoardMember in eBoardMembers) {
      bool successfullySetUserType =
          await _userProvider.setEboardUserType(eBoardMember.ucid);
      if (!successfullySetUserType) return false;
    }
    return true;
  }

  void approveOrganization(Organization org) async {
    try {
      bool success = await _orgProvider.approveOrganization(org);
      if (!success) {
        _alertAwaitApprovalError(
            'Error in approveOrganization function of organization BLOC');
      } else {
        bool messagedSuccessfully =
            await _messageEBoardMembersAboutApproval(org);
        if (!messagedSuccessfully) {
          _alertAwaitApprovalError(
              'Error in approveOrganization function of organization BLOC, failed to send messages alerting eBoardMembers of approval.');
        }
        bool assignUserTypes =
            await _assignEboardMemberUserTypes(org.eBoardMembers);
        if (!assignUserTypes) {
          _alertAwaitApprovalError(
              'Error in approveOrganization function of organization BLOC, failed to change eBoardMembers user types.');
        }
        fetchViewableOrgs();
        fetchOrgsAwaitingApproval();
      }
    } catch (error) {
      _alertAwaitApprovalError(
          'Error in approveOrganization function of organization BLOC: ' +
              error.toString());
    }
  }

  void rejectOrganization(String reasonForRejection, Organization org) async {
    try {
      bool success = await _orgProvider.removeOrganization(org);
      if (!success) {
        _alertAwaitApprovalError(
            'Error in rejectOrganization function of organization BLOC');
      } else {
        bool messagedSuccessfully =
            await _messageEBoardMembersAboutRejection(reasonForRejection, org);
        if (!messagedSuccessfully) {
          _alertAwaitApprovalError(
              "Error in rejectOrganization function of organization BLOC, failed to message eboard members about rejection.");
        }

        fetchOrgsAwaitingApproval();
      }
    } catch (error) {
      _alertAwaitApprovalError(
          'Error in rejectOrganization function of organization BLOC: ' +
              error.toString());
    }
  }

  /* ORGANIZATION EDITING FUNCTIONS */

  void _alertUpdateError(String errorMsg) {
    _orgUpdatingController.sink.add(OrganizationError(errorMsg: errorMsg));
  }

  void submitOrganizationUpdates() async {
    try {
      Organization orgWithUpdates = _updateOrgProvider.organization;
      _orgUpdatingController.sink
          .add(OrganizationUpdating(organization: orgWithUpdates));
      bool successfullyUpdated = await _updateOrgProvider.updateOrganization();
      if (successfullyUpdated) {
        _orgUpdatingController.sink
            .add(OrganizationUpdated(updatedOrganization: orgWithUpdates));
        _updateOrgProvider.clear();
      } else {
        _alertUpdateError(
            'Submitting organization updates failed, please try again!');
      }
    } catch (error) {
      _alertUpdateError(
          'Submitting organization updates failed:' + error.toString());
    }
  }

  Future<bool> _sendMessageToAdminsAboutEboardChangeRequest(
      Organization orgChanged, String reason) async {
    try {
      String orgName = orgChanged.name;
      DateFormat expirationFormatter = new DateFormat('yyyy-MM-dd');
      DateFormat requestDateFormatter = new DateFormat('E, MMMM dd');
      DateTime curr = DateTime.now();
      DateTime expirationDate = curr.add(Duration(days: 14));
      String title =
          'Please Approve Or Deny Organization E-Board Change Request for [' +
              orgName +
              ']';
      String messageBody = 'User ' +
          _ucid +
          " requested an E-Board change for their organization " +
          orgName +
          " on " +
          requestDateFormatter.format(curr) +
          ".The reason provided for this change is as followed: [" +
          reason +
          "] Please review the request and respond with the appropriate action on the Administration page. " +
          " This message expires on " +
          expirationFormatter.format(expirationDate) +
          ".";
      bool messagesSent = await _messageProvider.sendMessageToAdmins(
          _ucid, title, messageBody, expirationDate);
      if (messagesSent) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error sending message alerting admins of organization E-Board change request: ' +
              error.toString());
    }
  }

//TODO make a function that bulk sets e-board members?...
  void requestEboardChanges() async {
    try {
      Organization orgWithUpdates = _updateOrgProvider.organization;
      String reason = _updateOrgProvider.reason;
      _orgUpdatingController.sink
          .add(OrganizationUpdating(organization: orgWithUpdates));
      bool successfullyUpdated = await _updateOrgProvider.requestEboardChange();
      if (successfullyUpdated) {
        bool successfullyMessaged =
            await _sendMessageToAdminsAboutEboardChangeRequest(
                orgWithUpdates, reason);
        if (successfullyMessaged) {
          _orgUpdatingController.sink
              .add(OrganizationUpdated(updatedOrganization: orgWithUpdates));
          _updateOrgProvider.clear();
        } else {
          _alertUpdateError(
              'Sending messages alerting admins of this E-Board change request failed.');
        }
      } else {
        _alertUpdateError(
            'Requesting E-Board changes failed, please try again!');
      }
    } catch (error) {
      _alertUpdateError(
          'Requesting E-Board changes failed:' + error.toString());
    }
  }

  void approveEboardChanges(Organization org) async {
    try {
      bool success = await _orgProvider.approveEboardChange(org);
      if (!success) {
        print('error...');
        _alertUpdateError(
            'Error in approveEboardChanges function of organization BLOC');
      } else {
        /*
        bool messagedSuccessfully =
            await _messageEBoardMembersAboutApproval(org);
        if (!messagedSuccessfully) {
          _alertUpdateError(
              'Error in approveEboardChanges function of organization BLOC, failed to send messages alerting eBoardMembers of approval.');
        }
        */
        print('SUCCESS!');
        fetchViewableOrgs();
        fetchOrgsAwaitingEboardChange();
      }
    } catch (error) {
      print('error...'+error.toString());
      _alertUpdateError(
          'Error in approveEboardChanges function of organization BLOC: ' +
              error.toString());
    }
  }

  void dispose() {
    _orgUpdatingController.close();
    _viewableOrgsController.close();
    _awaitingApprovalOrgsController.close();
  }
}

abstract class OrganizationState extends Equatable {
  OrganizationState([List args = const []]) : super(args);
}

//keeps track of organization variables before clicking the register button
class OrganizationBeforeUpdates extends OrganizationState {
  final Organization organization;
  OrganizationBeforeUpdates({@required this.organization})
      : super([organization]);
}

//basically loading state once submit button clicked
class OrganizationRegistering extends OrganizationState {
  final Organization organization;
  OrganizationRegistering({@required this.organization})
      : super([organization]);
}

class OrganizationRegistered extends OrganizationState {
  final Organization organization;
  OrganizationRegistered({@required this.organization}) : super([organization]);
}

class OrganizationError extends OrganizationState {
  final String errorMsg;
  OrganizationError({@required String errorMsg})
      : this.errorMsg = errorMsg,
        super([errorMsg]);
}

class OrganizationsLoading extends OrganizationState {}

class OrganizationsLoaded extends OrganizationState {
  final List<Organization> organizations;
  OrganizationsLoaded({@required List<Organization> organizations})
      : this.organizations = organizations,
        super([organizations]);
}

class OrganizationUpdateRequestsLoaded extends OrganizationState {
  final List<OrganizationUpdateRequestData> requestData;
  OrganizationUpdateRequestsLoaded(
      {@required List<OrganizationUpdateRequestData> requestData})
      : requestData = requestData,
        super([requestData]);
}

class OrganizationUpdating extends OrganizationState {
  final Organization organization;
  OrganizationUpdating({@required this.organization}) : super([organization]);
}

class OrganizationUpdated extends OrganizationState {
  final Organization updatedOrganization;
  OrganizationUpdated({@required Organization updatedOrganization})
      : updatedOrganization = updatedOrganization,
        super([updatedOrganization]);
}
