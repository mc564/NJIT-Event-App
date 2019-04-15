import 'package:flutter/material.dart';

class OrganizationMember {
  String ucid;
  String role;
  OrganizationMember({@required this.ucid, @required this.role});
  @override
  String toString() {
    return '[' + ucid + ' ' + role + ']';
  }
}

//used by BLOC so that I have both the original organization
//and the requested update and can compare
class OrganizationUpdateRequestData {
  Organization original;
  Organization updated;
  OrganizationUpdateRequestData(
      {@required Organization original, @required Organization updated})
      : original = original,
        updated = updated;
}

enum OrganizationStatus {
  AWAITING_APPROVAL,
  AWAITING_REACTIVATION,
  AWAITING_EBOARD_CHANGE,
  AWAITING_INACTIVATION,
  ACTIVE,
  INACTIVE,
  OTHER
}

class OrganizationStatusHelper {
  static Map<OrganizationStatus, String> statusToString = {
    OrganizationStatus.AWAITING_APPROVAL: 'Awaiting Approval',
    OrganizationStatus.AWAITING_REACTIVATION: 'Awaiting Reactivation',
    OrganizationStatus.AWAITING_EBOARD_CHANGE: 'Awaiting E-Board Change',
    OrganizationStatus.AWAITING_INACTIVATION: 'Awaiting Inactivation',
    OrganizationStatus.ACTIVE: 'Active',
    OrganizationStatus.INACTIVE: 'Inactive',
    OrganizationStatus.OTHER: 'Other'
  };

  static Map<String, OrganizationStatus> stringToStatus = {
    'Awaiting Approval': OrganizationStatus.AWAITING_APPROVAL,
    'Awaiting Reactivation': OrganizationStatus.AWAITING_REACTIVATION,
    'Awaiting E-Board Change': OrganizationStatus.AWAITING_EBOARD_CHANGE,
    'Awaiting Inactivation': OrganizationStatus.AWAITING_INACTIVATION,
    'Active': OrganizationStatus.ACTIVE,
    'Inactive': OrganizationStatus.INACTIVE,
    'Other': OrganizationStatus.OTHER
  };

  static String getString(OrganizationStatus status) {
    return statusToString[status];
  }

  static OrganizationStatus getStatus(String statusStr) {
    if (stringToStatus.containsKey(statusStr))
      return stringToStatus[statusStr];
    else
      return OrganizationStatus.OTHER;
  }
}

class Organization {
  String _name;
  String _description;
  List<OrganizationMember> _eBoardMembers;
  List<OrganizationMember> _regularMembers;
  OrganizationStatus _status;

  String toString() {
    String str = "Organization: \n[\n";
    str += "Name: " + (_name == null ? "null" : _name) + "\n";
    str +=
        "Description: " + (_description == null ? "null" : _description) + "\n";
    str += "E-Board Members: \n";
    if (_eBoardMembers == null || eBoardMembers.length == 0) {
      //shouldn't happen, but
      str += "None right now.\n";
    } else {
      for (OrganizationMember member in _eBoardMembers) {
        str += "UCID: " + member.ucid + " Role: " + member.role + "\n";
      }
    }
    str += "Regular Members: \n";
    if (_regularMembers == null || _regularMembers.length == 0) {
      str += "None right now.\n";
    } else {
      for (OrganizationMember member in _regularMembers) {
        str += "UCID: " + member.ucid + " Role: " + member.role + "\n";
      }
    }
    str += "]\n";
    return str;
  }

  Organization(
      {String name,
      String description,
      OrganizationStatus status = OrganizationStatus.AWAITING_APPROVAL,
      List<OrganizationMember> eBoardMembers,
      List<OrganizationMember> regularMembers}) {
    _name = name;
    _description = description;
    _status = status;
    setEboardMembers(eBoardMembers);
    setMembers(regularMembers);
  }

  String get name => _name;
  String get description => _description;
  List<OrganizationMember> get eBoardMembers =>
      List<OrganizationMember>.from(_eBoardMembers);
  List<OrganizationMember> get regularMembers =>
      List<OrganizationMember>.from(_regularMembers);
  OrganizationStatus get status => _status;

  void setName(String name) {
    _name = name;
  }

  void setDescription(String description) {
    _description = description;
  }

  void setStatus(OrganizationStatus status) {
    _status = status;
  }

  void setEboardMembers(List<OrganizationMember> members) {
    if (members != null && members.length > 0)
      _eBoardMembers = members;
    else
      _eBoardMembers = List<OrganizationMember>();
  }

  void setMembers(List<OrganizationMember> members) {
    if (members != null && members.length > 0)
      _regularMembers = members;
    else
      _regularMembers = List<OrganizationMember>();
  }

  void addEboardMember(OrganizationMember eBoardMember) {
    _eBoardMembers.add(eBoardMember);
  }

  void removeEboardMember(OrganizationMember eBoardMember) {
    _eBoardMembers.removeWhere((OrganizationMember member) =>
        member.ucid == eBoardMember.ucid && member.role == eBoardMember.role);
  }

  void addRegularMember(OrganizationMember regularMember) {
    _regularMembers.add(regularMember);
  }

  void removeRegularMember(OrganizationMember regularMember) {
    _regularMembers.removeWhere((OrganizationMember member) =>
        member.ucid == regularMember.ucid && member.role == regularMember.role);
  }
}
