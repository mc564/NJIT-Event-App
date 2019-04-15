import '../../models/organization.dart';
import '../../api/database_event_api.dart';

class UpdateOrganizationProvider {
  Organization _originalOrg;
  Organization _orgWithUpdates;
  //sometimes I need to store a reason someone is requesting an org. update
  String _updateReason;
  int _maxNameLength;
  int _maxDescriptionLength;
  int _maxReasonLength;
  int _maxUCIDLength;
  int _maxRoleLength;

  UpdateOrganizationProvider() {
    clear();
    _maxNameLength = 100;
    _maxDescriptionLength = 5000;
    //TODO below length is arbitrary, but might want to go back and calculate
    //limits later..
    _maxReasonLength = 500;
    _maxUCIDLength = 10;
    _maxRoleLength = 256;
  }

  Organization get organization => Organization(
        name: _orgWithUpdates.name,
        description: _orgWithUpdates.description,
        status: _orgWithUpdates.status,
        eBoardMembers:
            List<OrganizationMember>.from(_orgWithUpdates.eBoardMembers),
        regularMembers:
            List<OrganizationMember>.from(_orgWithUpdates.regularMembers),
      );

  String get reason => _updateReason;

  void clear() {
    _originalOrg = Organization();
    _orgWithUpdates = Organization();
    _updateReason = '';
  }

  bool enoughEBoardMembers() {
    return _orgWithUpdates.eBoardMembers.length >= 3;
  }

  bool _equal(Organization o1, Organization o2) {
    if (o1.name == o2.name &&
        o1.description == o2.description &&
        o1.status == o2.status) {
      if (o1.eBoardMembers.length != o2.eBoardMembers.length) return false;
      if (o1.regularMembers.length != o2.regularMembers.length) return false;
      List<OrganizationMember> eBoardMembers1 = o1.eBoardMembers;
      List<OrganizationMember> eBoardMembers2 = o2.eBoardMembers;
      for (OrganizationMember member1 in eBoardMembers1) {
        if (eBoardMembers2.singleWhere(
                (OrganizationMember member2) =>
                    member2.ucid == member1.ucid &&
                    member2.role == member1.role,
                orElse: () => null) ==
            null) {
          return false;
        }
      }
      List<OrganizationMember> regularMembers1 = o1.regularMembers;
      List<OrganizationMember> regularMembers2 = o2.regularMembers;
      for (OrganizationMember member1 in regularMembers1) {
        if (regularMembers2.singleWhere(
                (OrganizationMember member2) =>
                    member2.ucid == member1.ucid &&
                    member2.role == member1.role,
                orElse: () => null) ==
            null) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  /* ALL ORGANIZATION REGISTRATION AND EDITING FORM FIELD SETTERS */

  bool setOrganizationToEdit(Organization orgToEdit) {
    try {
      _originalOrg = Organization(
        name: orgToEdit.name,
        description: orgToEdit.description,
        status: orgToEdit.status,
        eBoardMembers: List<OrganizationMember>.from(orgToEdit.eBoardMembers),
        regularMembers: List<OrganizationMember>.from(orgToEdit.regularMembers),
      );
      _orgWithUpdates = Organization(
        name: orgToEdit.name,
        description: orgToEdit.description,
        status: orgToEdit.status,
        eBoardMembers: List<OrganizationMember>.from(orgToEdit.eBoardMembers),
        regularMembers: List<OrganizationMember>.from(orgToEdit.regularMembers),
      );
      return true;
    } catch (error) {
      throw Exception(
          'Error in UpdateOrganizationProvider setOrganizationToEdit method: ' +
              error.toString());
    }
  }

  bool setReason(String reason) {
    try {
      _updateReason = reason;
      return true;
    } catch (error) {
      throw Exception('Error in UpdateOrganizationProvider setReason method: ' +
          error.toString());
    }
  }

  bool setName(String name) {
    try {
      _orgWithUpdates.setName(name);
      return true;
    } catch (error) {
      throw Exception('Error in UpdateOrganizationProvider setName method: ' +
          error.toString());
    }
  }

  bool setDescription(String desc) {
    try {
      _orgWithUpdates.setDescription(desc);
      return true;
    } catch (error) {
      throw Exception(
          'Error in UpdateOrganizationProvider setDescription method: ' +
              error.toString());
    }
  }

  bool addEboardMember(String ucid, String role) {
    try {
      _orgWithUpdates
          .addEboardMember(OrganizationMember(ucid: ucid, role: role));
      return true;
    } catch (error) {
      throw Exception(
          'Error in UpdateOrganizationProvider addEboardMember method: ' +
              error.toString());
    }
  }

  bool removeEboardMember(String ucid, String role) {
    try {
      _orgWithUpdates
          .removeEboardMember(OrganizationMember(ucid: ucid, role: role));
      return true;
    } catch (error) {
      throw Exception(
          'Error in UpdateOrganizationProvider removeEboardMember method: ' +
              error.toString());
    }
  }

  bool addRegularMember(String ucid) {
    try {
      _orgWithUpdates
          .addRegularMember(OrganizationMember(ucid: ucid, role: 'Member'));
      return true;
    } catch (error) {
      throw Exception(
          'Error in UpdateOrganizationProvider addRegularMember method: ' +
              error.toString());
    }
  }

  bool removeRegularMember(String ucid) {
    try {
      _orgWithUpdates
          .removeRegularMember(OrganizationMember(ucid: ucid, role: 'Member'));
      return true;
    } catch (error) {
      throw Exception(
          'Error in UpdateOrganizationProvider removeRegularMember method: ' +
              error.toString());
    }
  }

  /* ALL ORGANIZATION REGISTRATION AND EDITING FORM FIELD VALIDATORS */

  String reasonValidator(String reason) {
    if (reason == null || reason.isEmpty) {
      return 'Reason for organization update is required.';
    } else if (reason.length > _maxReasonLength) {
      return 'Update reason length must be under ' +
          _maxReasonLength.toString() +
          ' characters.';
    } else {
      return null;
    }
  }

  String nameValidator(String name) {
    if (name == null || name.isEmpty) {
      return 'Organization name is required.';
    } else if (name.length > _maxNameLength) {
      return 'Organization name length must be under ' +
          _maxNameLength.toString() +
          ' characters.';
    } else {
      return null;
    }
  }

  String descriptionValidator(String desc) {
    if (desc == null || desc.isEmpty) {
      return 'Organization description is required.';
    } else if (desc.length > _maxDescriptionLength) {
      return 'Organization description length must be under ' +
          _maxDescriptionLength.toString() +
          ' characters.';
    } else {
      return null;
    }
  }

  String eBoardMemberValidator(String ucid, String role) {
    if (ucid == null || ucid.length == 0 || role == null || role.length == 0) {
      return 'Both UCID and role are required.';
    } else if (_orgWithUpdates.eBoardMembers.firstWhere(
            (OrganizationMember member) => member.ucid == ucid,
            orElse: () => null) !=
        null) {
      return 'Duplicate E-board member exists.';
    } else if (_orgWithUpdates.regularMembers.firstWhere(
            (OrganizationMember member) => member.ucid == ucid,
            orElse: () => null) !=
        null) {
      return 'Duplicate regular member exists.';
    } else if (ucid.length > _maxUCIDLength) {
      return 'UCID must be less than length ' + _maxUCIDLength.toString() + '.';
    } else if (role.length > _maxRoleLength) {
      return 'Role must be less than length ' + _maxUCIDLength.toString() + '.';
    } else
      return null;
  }

  String regularMemberValidator(String ucid) {
    if (ucid == null || ucid.length == 0)
      return 'UCID is required.';
    else if (_orgWithUpdates.regularMembers.firstWhere(
            (OrganizationMember member) => member.ucid == ucid,
            orElse: () => null) !=
        null) {
      return 'Duplicate regular member exists.';
    } else if (_orgWithUpdates.eBoardMembers.firstWhere(
            (OrganizationMember member) => member.ucid == ucid,
            orElse: () => null) !=
        null) {
          return 'Duplicate E-Board member exists.';
    } else if (ucid.length > _maxUCIDLength) {
      return 'UCID must be less than length ' + _maxUCIDLength.toString() + '.';
    } else {
      return null;
    }
  }

  /* "SUBMIT" FUNCTIONS FOR EDITING */

  Future<bool> registerOrganization() async {
    try {
      bool registered =
          await DatabaseEventAPI.registerOrganization(_orgWithUpdates);
      clear();
      if (registered) {
        return true;
      } else {
        throw Exception(
            'Error in UpdateOrganizationProvider function registerOrganization, failed to register organization.');
      }
    } catch (error) {
      throw Exception(
          'Error in UpdateOrganizationProvider function registerOrganization: ' +
              error.toString());
    }
  }

  Future<bool> requestReactivation() async {
    try {
      bool requestSubmitted =
          await DatabaseEventAPI.requestReactivation(_orgWithUpdates);
      clear();
      if (requestSubmitted) {
        return true;
      } else {
        throw Exception(
            'Error in UpdateOrganizationProvider function requestReactivation, failed to request reactivation.');
      }
    } catch (error) {
      throw Exception(
          'Error in UpdateOrganizationProvider function requestReactivation: ' +
              error.toString());
    }
  }

  Future<bool> updateOrganization() async {
    try {
      if (_equal(_originalOrg, _orgWithUpdates)) {
        throw Exception(
            'No changes made from original organization. Cannot submit updates.');
      }
      bool updated = await DatabaseEventAPI.updateOrganization(_orgWithUpdates);
      clear();
      if (updated) {
        return true;
      } else {
        throw Exception(
            'Error in UpdateOrganizationProvider function updateOrganization, failed to update organization.');
      }
    } catch (error) {
      throw Exception(
          'Error in UpdateOrganizationProvider function updateOrganization: ' +
              error.toString());
    }
  }

  Future<bool> requestEboardChange() async {
    try {
      if (_equal(_originalOrg, _orgWithUpdates)) {
        throw Exception(
            'No changes made from original organization. Cannot submit updates.');
      }
      bool requestedChange =
          await DatabaseEventAPI.requestEboardChange(_orgWithUpdates);
      clear();
      if (requestedChange) {
        return true;
      } else {
        throw Exception(
            'Error in UpdateOrganizationProvider function requestEboardChange, failed to request E-Board changes for the organization.');
      }
    } catch (error) {
      throw Exception(
          'Error in UpdateOrganizationProvider function requestEboardChange: ' +
              error.toString());
    }
  }
}
