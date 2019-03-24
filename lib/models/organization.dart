import 'package:flutter/material.dart';

class Organization {
  String name;
  String description;
  Map<String, String> eBoardMemberUCIDsToRoles;
  List<String> regularMemberUCIDs;
  bool active;

  Organization(
      {String name,
      String description,
      bool active,
      Map<String, String> eBoardUCIDsToRoles,
      List<String> restOfMemberUCIDs}) {
    this.name = name;
    this.description = description;
    this.active = active;
    setEboardMembers(eBoardUCIDsToRoles);
    setMembers(restOfMemberUCIDs);
  }

  void setName(String name) {
    this.name = name;
  }

  void setDescription(String description) {
    this.description = description;
  }

  void setActive(bool active) {
    this.active = active;
  }

  void setEboardMembers(Map<String, String> members) {
    if (members != null && members.length > 0)
      eBoardMemberUCIDsToRoles = members;
  }

  void setMembers(List<String> members) {
    if (members != null && members.length > 0) regularMemberUCIDs = members;
  }
}
