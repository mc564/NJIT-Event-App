import 'dart:async';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../providers/organization/organization_provider.dart';
import '../providers/organization/update_organization_provider.dart';
import '../providers/organization/organization_message_provider.dart';

import '../providers/message_provider.dart';
import '../providers/user_provider.dart';

import '../models/organization.dart';
import '../models/event.dart';
import '../models/user.dart';

//manages the organizations
class OrganizationBloc {
  final StreamController<OrganizationEvent> _requestsController;
  //stream for org editing (change description, edit members etc.) and registration requests
  final StreamController<OrganizationState> _orgUpdatingController;
  //stream for active organizations
  final StreamController<OrganizationState> _viewableOrgsController;

  final StreamController<OrganizationState> _inactiveOrgsController;

  final StreamController<OrganizationState> _awaitingApprovalOrgsController;

  final StreamController<OrganizationState> _awaitingReactivationOrgsController;

  final StreamController<OrganizationState> _awaitingEboardChangeOrgsController;

  final StreamController<OrganizationState> _awaitingInactivationOrgsController;

  //general organization related functions in this provider
  final OrganizationProvider _orgProvider;
  //the below provider does everything from registering to editing eboard members, all form stuff, etc.
  final UpdateOrganizationProvider _updateOrgProvider;
  //these 2 are used to send messages
  final OrganizationMessageProvider _organizationMessageProvider;

  final String _ucid;
  final bool _isAdmin;

  OrganizationState _prevUpdatedOrgState;
  OrganizationState _prevViewableOrgsState;
  OrganizationState _prevInactiveOrgsState;
  OrganizationState _prevAwaitingApprovalOrgsState;
  OrganizationState _prevAwaitingEboardChangeOrgsState;
  OrganizationState _prevAwaitingInactivationOrgsState;
  OrganizationState _prevAwaitingReactivationOrgsState;

  OrganizationBloc(
      {@required MessageProvider messageProvider,
      @required UserProvider userProvider})
      : _organizationMessageProvider = OrganizationMessageProvider(
            messageProvider: messageProvider, ucid: userProvider.ucid),
        _orgProvider = OrganizationProvider(),
        _updateOrgProvider = UpdateOrganizationProvider(),
        _requestsController = StreamController<OrganizationEvent>.broadcast(),
        _orgUpdatingController =
            StreamController<OrganizationState>.broadcast(),
        _viewableOrgsController =
            StreamController<OrganizationState>.broadcast(),
        _inactiveOrgsController =
            StreamController<OrganizationState>.broadcast(),
        _awaitingApprovalOrgsController =
            StreamController<OrganizationState>.broadcast(),
        _awaitingEboardChangeOrgsController =
            StreamController<OrganizationState>.broadcast(),
        _awaitingInactivationOrgsController =
            StreamController<OrganizationState>.broadcast(),
        _awaitingReactivationOrgsController =
            StreamController<OrganizationState>.broadcast(),
        _ucid = userProvider.ucid,
        _isAdmin = userProvider.userTypes.contains(UserTypes.Admin) {
    _prevUpdatedOrgState = OrganizationBeforeUpdates(
        organization: _updateOrgProvider.organization);
    fetchInactiveOrgs();
    fetchViewableOrgs();
    fetchOrgsAwaitingApproval();
    fetchOrgsAwaitingEboardChange();
    fetchOrgsAwaitingInactivation();
    fetchOrgsAwaitingReactivation();
    _orgUpdatingController.stream.listen((OrganizationState state) {
      _prevUpdatedOrgState = state;
    });
    _viewableOrgsController.stream.listen((OrganizationState state) {
      _prevViewableOrgsState = state;
    });
    _inactiveOrgsController.stream.listen((OrganizationState state) {
      _prevInactiveOrgsState = state;
    });
    _awaitingApprovalOrgsController.stream.listen((OrganizationState state) {
      _prevAwaitingApprovalOrgsState = state;
    });
    _awaitingEboardChangeOrgsController.stream
        .listen((OrganizationState state) {
      _prevAwaitingEboardChangeOrgsState = state;
    });
    _awaitingInactivationOrgsController.stream
        .listen((OrganizationState state) {
      _prevAwaitingInactivationOrgsState = state;
    });
    _awaitingReactivationOrgsController.stream
        .listen((OrganizationState state) {
      _prevAwaitingReactivationOrgsState = state;
    });
    _requestsController.stream.forEach((OrganizationEvent event) {
      event.execute(this);
    });
  }

  OrganizationState get updatingOrgInitialState => _prevUpdatedOrgState;
  OrganizationState get viewableOrgsInitialState => _prevViewableOrgsState;
  OrganizationState get inactiveOrgsInitialState => _prevInactiveOrgsState;
  OrganizationState get orgsAwaitingApprovalInitialState =>
      _prevAwaitingApprovalOrgsState;
  OrganizationState get orgsAwaitingEboardChangeInitialState =>
      _prevAwaitingEboardChangeOrgsState;
  OrganizationState get orgsAwaitingInactivationInitialState =>
      _prevAwaitingInactivationOrgsState;
  OrganizationState get orgsAwaitingReactivationInitialState =>
      _prevAwaitingReactivationOrgsState;

  Function get reasonValidator => _updateOrgProvider.reasonValidator;
  Function get nameValidator => _updateOrgProvider.nameValidator;
  Function get descriptionValidator => _updateOrgProvider.descriptionValidator;
  Function get eBoardMemberValidator =>
      _updateOrgProvider.eBoardMemberValidator;
  Function get regularMemberValidator =>
      _updateOrgProvider.regularMemberValidator;
  bool get enoughEBoardMembers => _updateOrgProvider.enoughEBoardMembers();

  StreamSink<OrganizationEvent> get sink => _requestsController.sink;
  Stream get organizationUpdateRequests => _orgUpdatingController.stream;
  Stream get viewableOrganizations => _viewableOrgsController.stream;
  Stream get inactiveOrganizations => _inactiveOrgsController.stream;
  Stream get organizationsAwaitingApproval =>
      _awaitingApprovalOrgsController.stream;
  Stream get organizationsAwaitingEboardChange =>
      _awaitingEboardChangeOrgsController.stream;
  Stream get organizationsAwaitingInactivation =>
      _awaitingInactivationOrgsController.stream;
  Stream get organizationsAwaitingReactivation =>
      _awaitingReactivationOrgsController.stream;

  OrganizationProvider get organizationProvider => _orgProvider;

  Future<bool> canEdit(Event event) async {
    return _orgProvider.canEdit(_ucid, _isAdmin, event);
  }

  //can't send a request if one is in progress
  bool canSendOrganizationRequest(Organization organization) {
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

  void fetchInactiveOrgs() async {
    try {
      _inactiveOrgsController.sink.add(OrganizationsLoading());
      List<Organization> inactiveOrgs =
          await _orgProvider.allInactiveOrganizations();
      _inactiveOrgsController.sink
          .add(OrganizationsLoaded(organizations: inactiveOrgs));
    } catch (error) {
      _inactiveOrgsController.sink.add(OrganizationError(
          errorMsg: 'Error in organization BLOC fetchInactiveOrgs method: ' +
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

  void fetchOrgsAwaitingInactivation() async {
    try {
      _awaitingInactivationOrgsController.sink.add(OrganizationsLoading());
      List<Organization> awaitingInactivation =
          await _orgProvider.allOrganizationsAwaitingInactivation();
      _awaitingInactivationOrgsController.sink
          .add(OrganizationsLoaded(organizations: awaitingInactivation));
    } catch (error) {
      _awaitingInactivationOrgsController.sink.add(OrganizationError(
          errorMsg:
              'Error in organization BLOC fetchOrgsAwaitingInactivation method: ' +
                  error.toString()));
    }
  }

  void fetchOrgsAwaitingReactivation() async {
    try {
      _awaitingReactivationOrgsController.sink.add(OrganizationsLoading());
      List<Organization> awaitingReactivation =
          await _orgProvider.allOrganizationsAwaitingReactivation();
      _awaitingReactivationOrgsController.sink
          .add(OrganizationsLoaded(organizations: awaitingReactivation));
    } catch (error) {
      _awaitingReactivationOrgsController.sink.add(OrganizationError(
          errorMsg:
              'Error in organization BLOC fetchOrgsAwaitingReactivation method: ' +
                  error.toString()));
    }
  }

  /* ORGANIZATION REGISTRATION AND EDITING FORM SETTERS */

  //basically clears the provider (used in initState by ui)
  //so that every form can start from a clear slate
  void clearStorage() {
    _updateOrgProvider.clear();
    _alertOrganizationChanged();
  }

  void _alertOrganizationChanged() {
    _orgUpdatingController.sink.add(OrganizationBeforeUpdates(
        organization: _updateOrgProvider.organization));
  }

  void setOrgToEdit(Organization org) {
    _updateOrgProvider.setOrganizationToEdit(org);
    _alertOrganizationChanged();
  }

  void setReasonForUpdate(String reason) {
    _updateOrgProvider.setReason(reason);
    _alertOrganizationChanged();
  }

  void setName(String name) {
    _updateOrgProvider.setName(name);
    _alertOrganizationChanged();
  }

  void setDescription(String description) {
    _updateOrgProvider.setDescription(description);
    _alertOrganizationChanged();
  }

  void addEboardMember(String ucid, String role) {
    _updateOrgProvider.addEboardMember(ucid, role);
    _alertOrganizationChanged();
  }

  void removeEboardMember(String ucid, String role) {
    _updateOrgProvider.removeEboardMember(ucid, role);
    _alertOrganizationChanged();
  }

  void addRegularMember(String ucid) {
    _updateOrgProvider.addRegularMember(ucid);
    _alertOrganizationChanged();
  }

  void removeRegularMember(String ucid) {
    _updateOrgProvider.removeRegularMember(ucid);
    _alertOrganizationChanged();
  }

  /* ALERT DIFFERENT TYPES OF ERROR FUNCTIONS */

  void _alertUpdateError(String errorMsg) {
    _orgUpdatingController.sink.add(OrganizationError(errorMsg: errorMsg));
  }

  void _alertEboardChangeError(String errorMsg) {
    _awaitingEboardChangeOrgsController.sink
        .add(OrganizationError(errorMsg: errorMsg));
  }

  void _alertInactivationError(String errorMsg) {
    _awaitingInactivationOrgsController
        .add(OrganizationError(errorMsg: errorMsg));
  }

  void _alertReactivationError(String errorMsg) {
    _awaitingReactivationOrgsController
        .add(OrganizationError(errorMsg: errorMsg));
  }

  void _alertAwaitApprovalError(String errorMsg) {
    _awaitingApprovalOrgsController.sink
        .add(OrganizationError(errorMsg: errorMsg));
  }

  /* ORGANIZATION REGISTRATION FUNCTIONS */

  void submitOrganizationRegistration() async {
    try {
      Organization orgToRegister = _updateOrgProvider.organization;
      _orgUpdatingController.sink
          .add(OrganizationUpdating(organization: orgToRegister));
      bool successfullyAdded = await _updateOrgProvider.registerOrganization();
      if (successfullyAdded) {
        bool successfullySentAdminAlerts = await _organizationMessageProvider
            .sendMessageToAdminsAboutRegistration(orgToRegister);
        if (!successfullySentAdminAlerts) {
          _alertUpdateError(
              'Failed to send admins messages about registration, please try again!');
        } else {
          _orgUpdatingController.sink
              .add(OrganizationUpdated(updatedOrganization: orgToRegister));
          _updateOrgProvider.clear();
          fetchOrgsAwaitingApproval();
        }
      } else {
        _alertUpdateError(
            'Submitting organization registration failed, please try again!');
      }
    } catch (error) {
      _alertUpdateError(
          'Submitting organization registration failed: ' + error.toString());
    }
  }

  void approveOrganization(Organization org) async {
    try {
      _awaitingApprovalOrgsController
          .add(OrganizationUpdating(organization: org));
      bool success = await _orgProvider.approveOrganization(org);
      if (!success) {
        _alertAwaitApprovalError(
            'Error in approveOrganization function of organization BLOC');
      } else {
        bool messagedSuccessfully = await _organizationMessageProvider
            .messageEBoardMembersAboutApproval(org);
        if (!messagedSuccessfully) {
          _alertAwaitApprovalError(
              'Error in approveOrganization function of organization BLOC, failed to send messages alerting eBoardMembers of approval.');
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
      _awaitingApprovalOrgsController
          .add(OrganizationUpdating(organization: org));
      bool success = await _orgProvider.removeOrganization(org);
      if (!success) {
        _alertAwaitApprovalError(
            'Error in rejectOrganization function of organization BLOC');
      } else {
        bool messagedSuccessfully = await _organizationMessageProvider
            .messageEBoardMembersAboutRejection(reasonForRejection, org);
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

  /* ORG REACTIVATION functions */

  void submitRequestForReactivation() async {
    try {
      Organization orgToReactivate = _updateOrgProvider.organization;
      _orgUpdatingController.sink
          .add(OrganizationUpdating(organization: orgToReactivate));
      bool successfullyRequested =
          await _updateOrgProvider.requestReactivation();
      if (successfullyRequested) {
        bool successfullySentAdminAlerts = await _organizationMessageProvider
            .sendMessageToAdminsAboutReactivationRequest(orgToReactivate);
        if (!successfullySentAdminAlerts) {
          _alertUpdateError(
              'Failed to send admins messages about reactivation, please try again!');
        } else {
          _orgUpdatingController.sink
              .add(OrganizationUpdated(updatedOrganization: orgToReactivate));
          _updateOrgProvider.clear();
          fetchOrgsAwaitingReactivation();
          fetchInactiveOrgs();
        }
      } else {
        _alertUpdateError(
            'Submitting organization reactivation request failed, please try again!');
      }
    } catch (error) {
      _alertUpdateError(
          'Submitting organization reactivation request failed: ' +
              error.toString());
    }
  }

  void rejectOrganizationRevival(Organization org, String reason) async {
    try {
      _awaitingReactivationOrgsController.sink
          .add(OrganizationUpdating(organization: org));
      bool success = await _orgProvider.rejectRevival(org);
      if (!success) {
        _alertReactivationError(
            'Error in rejectOrganizationRevival function of organization BLOC');
      } else {
        bool messagedSuccessfully = await _organizationMessageProvider
            .messageEboardMembersAboutRejectedRevival(reason, org);
        if (!messagedSuccessfully) {
          _alertReactivationError(
              'Error in rejectOrganizationRevival function of organization BLOC, failed to send messages alerting eBoardMembers of rejection.');
        }
        fetchInactiveOrgs();
        fetchOrgsAwaitingReactivation();
      }
    } catch (error) {
      _alertReactivationError(
          'Error in rejectOrganizationRevival function of organization BLOC: ' +
              error.toString());
    }
  }

  void approveOrganizationRevival(Organization org) async {
    try {
      _awaitingReactivationOrgsController.sink
          .add(OrganizationUpdating(organization: org));
      bool success = await _orgProvider.approveRevival(org);
      if (!success) {
        _alertReactivationError(
            'Error in approveOrganizationRevival function of organization BLOC');
      } else {
        bool messagedSuccessfully = await _organizationMessageProvider
            .messageMembersAboutApprovedRevival(org);
        if (!messagedSuccessfully) {
          _alertReactivationError(
              'Error in approveOrganizationRevival function of organization BLOC, failed to send messages alerting members of approval.');
        }
        fetchViewableOrgs();
        fetchOrgsAwaitingReactivation();
      }
    } catch (error) {
      _alertReactivationError(
          'Error in approveOrganizationRevival function of organization BLOC: ' +
              error.toString());
    }
  }

  /* GENERAL UPDATE FUNCTION */

  void submitOrganizationUpdates() async {
    try {
      Organization orgWithUpdates = _updateOrgProvider.organization;
      _orgUpdatingController.sink
          .add(OrganizationUpdating(organization: orgWithUpdates));
      bool successfullyUpdated = await _updateOrgProvider.updateOrganization();
      if (successfullyUpdated) {
        _orgUpdatingController.sink
            .add(OrganizationUpdated(updatedOrganization: orgWithUpdates));
        //can probably just change in ui upon success
        //unoptimistic updating apparently
      } else {
        _alertUpdateError(
            'Submitting organization updates failed, please try again!');
      }
    } catch (error) {
      _alertUpdateError(
          'Submitting organization updates failed:' + error.toString());
    }
  }

/*EBOARD CHANGES FUNCTIONS */

  void requestEboardChanges() async {
    try {
      Organization orgWithUpdates = _updateOrgProvider.organization;
      String reason = _updateOrgProvider.reason;
      _orgUpdatingController.sink
          .add(OrganizationUpdating(organization: orgWithUpdates));
      bool successfullyUpdated = await _updateOrgProvider.requestEboardChange();
      if (successfullyUpdated) {
        bool successfullyMessaged = await _organizationMessageProvider
            .sendMessageToAdminsAboutEboardChangeRequest(
                orgWithUpdates, reason);
        if (successfullyMessaged) {
          orgWithUpdates.setStatus(OrganizationStatus.AWAITING_EBOARD_CHANGE);
          _orgUpdatingController.sink
              .add(OrganizationUpdated(updatedOrganization: orgWithUpdates));
          _updateOrgProvider.clear();
          fetchOrgsAwaitingEboardChange();
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

  void approveEboardChanges(OrganizationUpdateRequestData orgData) async {
    try {
      _awaitingEboardChangeOrgsController.sink
          .add(OrganizationUpdating(organization: orgData.updated));
      bool success = await _orgProvider.approveEboardChange(orgData.updated);
      if (!success) {
        _alertEboardChangeError(
            'Error in approveEboardChanges function of organization BLOC');
      } else {
        bool messagedSuccessfully = await _organizationMessageProvider
            .messageEboardMembersAboutApprovedEboardChangeRequest(orgData);
        if (!messagedSuccessfully) {
          _alertEboardChangeError(
              'Error in approveEboardChanges function of organization BLOC, failed to send messages alerting eBoardMembers of approval.');
        }

        print('SUCCESS!');
        fetchViewableOrgs();
        fetchOrgsAwaitingEboardChange();
      }
    } catch (error) {
      _alertEboardChangeError(
          'Error in approveEboardChanges function of organization BLOC: ' +
              error.toString());
    }
  }

  void rejectEboardChanges(
      OrganizationUpdateRequestData orgData, String reason) async {
    try {
      _awaitingEboardChangeOrgsController.sink
          .add(OrganizationUpdating(organization: orgData.updated));
      bool success = await _orgProvider.rejectEboardChanges(orgData.updated);
      if (!success) {
        _alertEboardChangeError(
            'Error in rejectEboardChanges function of organization BLOC');
      } else {
        bool messagedSuccessfully = await _organizationMessageProvider
            .messageEboardMembersAboutRejectedEboardChangeRequest(
                orgData, reason);
        if (!messagedSuccessfully) {
          _alertEboardChangeError(
              'Error in rejectEboardChanges function of organization BLOC, failed to send messages alerting eBoardMembers of rejection.');
        }

        fetchViewableOrgs();
        fetchOrgsAwaitingEboardChange();
      }
    } catch (error) {
      _alertEboardChangeError(
          'Error in rejectEboardChanges function of organization BLOC: ' +
              error.toString());
    }
  }

  /* INACTIVATION FUNCTIONS */
  void requestOrganizationInactivation(
      Organization organization, String reason) async {
    print('requesting org inactivation');
    try {
      _orgUpdatingController.sink
          .add(OrganizationUpdating(organization: organization));
      bool successfullyRequested = await _orgProvider.setOrganizationStatus(
          OrganizationStatus.AWAITING_INACTIVATION, organization);

      if (successfullyRequested) {
        print('SUCCESSfully requested inactivation');
        bool successfullyMessaged = await _organizationMessageProvider
            .sendMessageToAdminsAboutInactivationRequest(organization, reason);
        if (successfullyMessaged) {
          organization.setStatus(OrganizationStatus.AWAITING_INACTIVATION);
          _orgUpdatingController.sink
              .add(OrganizationUpdated(updatedOrganization: organization));
          _updateOrgProvider.clear();
          fetchOrgsAwaitingInactivation();
        } else {
          _alertUpdateError(
              'Sending messages alerting admins of this organization inactivation request failed.');
        }
      } else {
        _alertUpdateError(
            'Requesting organization inactivation failed, please try again!');
      }
    } catch (error) {
      _alertUpdateError(
          'Requesting organization inactivation failed:' + error.toString());
    }
  }

  void refuseOrganizationInactivation(Organization org, String reason) async {
    try {
      _awaitingInactivationOrgsController.sink
          .add(OrganizationUpdating(organization: org));
      bool success = await _orgProvider.setOrganizationStatus(
          OrganizationStatus.ACTIVE, org);
      if (!success) {
        _alertInactivationError(
            'Error in refuseOrganizationInactivation function of organization BLOC');
      } else {
        bool messagedSuccessfully = await _organizationMessageProvider
            .messageEboardMembersAboutRefusedInactivationRequest(org, reason);
        if (!messagedSuccessfully) {
          _alertInactivationError(
              'Error in refuseOrganizationInactivation function of organization BLOC, failed to send messages alerting eBoardMembers of refusal.');
        }
        fetchViewableOrgs();
        fetchOrgsAwaitingInactivation();
      }
    } catch (error) {
      _alertInactivationError(
          'Error in refuseOrganizationInactivation function of organization BLOC: ' +
              error.toString());
    }
  }

  void inactivateOrganization(Organization org) async {
    try {
      _awaitingInactivationOrgsController.sink
          .add(OrganizationUpdating(organization: org));
      bool success = await _orgProvider.inactivateOrganization(org);
      if (!success) {
        _alertInactivationError(
            'Error in inactivateOrganization function of organization BLOC');
      } else {
        bool messagedSuccessfully = await _organizationMessageProvider
            .messageMembersAboutInactivation(org);
        if (!messagedSuccessfully) {
          _alertInactivationError(
              'Error in inactivateOrganization function of organization BLOC, failed to send messages alerting members of inactivation.');
        }
        fetchViewableOrgs();
        fetchInactiveOrgs();
        fetchOrgsAwaitingInactivation();
      }
    } catch (error) {
      _alertInactivationError(
          'Error in inactivateOrganization function of organization BLOC: ' +
              error.toString());
    }
  }

  void dispose() {
    _orgUpdatingController.close();
    _viewableOrgsController.close();
    _inactiveOrgsController.close();
    _awaitingApprovalOrgsController.close();
    _awaitingEboardChangeOrgsController.close();
    _awaitingInactivationOrgsController.close();
    _awaitingReactivationOrgsController.close();
    _requestsController.close();
  }
}

/*ORGANIZATION BLOC input EVENTS */
abstract class OrganizationEvent extends Equatable {
  OrganizationEvent([List args = const []]) : super(args);
  void execute(OrganizationBloc organizationBloc);
}

class FetchViewableOrganizations extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.fetchViewableOrgs();
  }
}

class FetchInactiveOrganizations extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.fetchInactiveOrgs();
  }
}

class FetchOrganizationsAwaitingApproval extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.fetchOrgsAwaitingApproval();
  }
}

class FetchOrganizationsAwaitingEboardChange extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.fetchOrgsAwaitingEboardChange();
  }
}

class FetchOrganizationsAwaitingInactivation extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.fetchOrgsAwaitingInactivation();
  }
}

class FetchOrganizationsAwaitingReactivation extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.fetchOrgsAwaitingReactivation();
  }
}

class ClearStorage extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.clearStorage();
  }
}

class SetOrganizationToEdit extends OrganizationEvent {
  final Organization organization;
  SetOrganizationToEdit({@required Organization organization})
      : organization = organization,
        super([organization]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.setOrgToEdit(organization);
  }
}

class SetReasonForUpdate extends OrganizationEvent {
  final String reason;
  SetReasonForUpdate({@required String reason})
      : reason = reason,
        super([reason]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.setReasonForUpdate(reason);
  }
}

class SetName extends OrganizationEvent {
  final String name;
  SetName({@required String name})
      : name = name,
        super([name]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.setName(name);
  }
}

class SetDescription extends OrganizationEvent {
  final String description;
  SetDescription({@required String description})
      : description = description,
        super([description]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.setDescription(description);
  }
}

class AddEboardMember extends OrganizationEvent {
  final String ucid;
  final String role;
  AddEboardMember({@required String ucid, @required String role})
      : ucid = ucid,
        role = role,
        super([ucid, role]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.addEboardMember(ucid, role);
  }
}

class RemoveEboardMember extends OrganizationEvent {
  final String ucid;
  final String role;
  RemoveEboardMember({@required String ucid, @required String role})
      : ucid = ucid,
        role = role,
        super([ucid, role]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.removeEboardMember(ucid, role);
  }
}

class AddRegularMember extends OrganizationEvent {
  final String ucid;
  AddRegularMember({@required String ucid})
      : ucid = ucid,
        super([ucid]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.addRegularMember(ucid);
  }
}

class RemoveRegularMember extends OrganizationEvent {
  final String ucid;
  RemoveRegularMember({@required String ucid})
      : ucid = ucid,
        super([ucid]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.removeRegularMember(ucid);
  }
}

class SubmitOrganizationRegistration extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.submitOrganizationRegistration();
  }
}

class ApproveOrganizationRegistration extends OrganizationEvent {
  final Organization organization;
  ApproveOrganizationRegistration({@required Organization organization})
      : organization = organization,
        super([organization]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.approveOrganization(organization);
  }
}

class RejectOrganizationRegistration extends OrganizationEvent {
  final Organization organization;
  final String reason;
  RejectOrganizationRegistration(
      {@required Organization organization, @required String reason})
      : organization = organization,
        reason = reason,
        super([organization, reason]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.rejectOrganization(reason, organization);
  }
}

class SubmitRequestForReactivation extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.submitRequestForReactivation();
  }
}

class RejectOrganizationRevival extends OrganizationEvent {
  final Organization organization;
  final String reason;
  RejectOrganizationRevival(
      {@required Organization organization, @required String reason})
      : organization = organization,
        reason = reason,
        super([organization, reason]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.rejectOrganizationRevival(organization, reason);
  }
}

class ApproveOrganizationRevival extends OrganizationEvent {
  final Organization organization;
  ApproveOrganizationRevival({@required Organization organization})
      : organization = organization,
        super([organization]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.approveOrganizationRevival(organization);
  }
}

class SubmitOrganizationUpdates extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.submitOrganizationUpdates();
  }
}

class RequestEboardChanges extends OrganizationEvent {
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.requestEboardChanges();
  }
}

class ApproveEboardChanges extends OrganizationEvent {
  final OrganizationUpdateRequestData requestData;
  ApproveEboardChanges({@required OrganizationUpdateRequestData requestData})
      : requestData = requestData,
        super([requestData]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.approveEboardChanges(requestData);
  }
}

class RejectEboardChanges extends OrganizationEvent {
  final OrganizationUpdateRequestData requestData;
  final String reason;
  RejectEboardChanges(
      {@required OrganizationUpdateRequestData requestData,
      @required String reason})
      : requestData = requestData,
        reason = reason,
        super([requestData, reason]);
  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.rejectEboardChanges(requestData, reason);
  }
}

class RequestOrganizationInactivation extends OrganizationEvent {
  final Organization organization;
  final String reason;
  RequestOrganizationInactivation(
      {@required Organization organization, @required String reason})
      : organization = organization,
        reason = reason,
        super([organization, reason]);

  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.requestOrganizationInactivation(organization, reason);
  }
}

class RefuseOrganizationInactivation extends OrganizationEvent {
  final Organization organization;
  final String reason;
  RefuseOrganizationInactivation(
      {@required Organization organization, @required String reason})
      : organization = organization,
        reason = reason,
        super([organization, reason]);

  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.refuseOrganizationInactivation(organization, reason);
  }
}

class InactivateOrganization extends OrganizationEvent {
  final Organization organization;
  InactivateOrganization({@required Organization organization})
      : organization = organization,
        super([organization]);

  void execute(OrganizationBloc organizationBloc) {
    organizationBloc.inactivateOrganization(organization);
  }
}

/* ORGANIZATION BLOC output STATES */
abstract class OrganizationState extends Equatable {
  OrganizationState([List args = const []]) : super(args);
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

//keeps track of organization variables before clicking the register button
class OrganizationBeforeUpdates extends OrganizationState {
  final Organization organization;
  OrganizationBeforeUpdates({@required this.organization})
      : super([organization]);
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
