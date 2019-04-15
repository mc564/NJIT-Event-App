import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../providers/message_provider.dart';
import '../../models/organization.dart';

//delivers organization specific messages for the organization bloc!
class OrganizationMessageProvider {
  final MessageProvider _messageProvider;
  final String _ucid;

  OrganizationMessageProvider(
      {@required MessageProvider messageProvider, @required String ucid})
      : _messageProvider = messageProvider,
        _ucid = ucid;

  /* REGISTRATION MESSAGES */
  Future<bool> sendMessageToAdminsAboutRegistration(
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

  Future<bool> messageEBoardMembersAboutApproval(Organization org) async {
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

  Future<bool> messageEBoardMembersAboutRejection(
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

  /* REACTIVATION MESSAGES */
  Future<bool> sendMessageToAdminsAboutReactivationRequest(
      Organization orgToReactivate) async {
    try {
      String orgName = orgToReactivate.name;
      DateFormat expirationFormatter = new DateFormat('yyyy-MM-dd');
      DateFormat registrationDateFormatter = new DateFormat('E, MMMM dd');
      DateTime curr = DateTime.now();
      DateTime expirationDate = curr.add(Duration(days: 14));
      String title = 'Please Approve Or Deny Organization Reactivation for [' +
          orgName +
          ']';
      String messageBody = 'User ' +
          _ucid +
          " requested reactivation of the organization " +
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
          'Error sending message alerting admins of organization reactivation request: ' +
              error.toString());
    }
  }

  Future<bool> messageEboardMembersAboutRejectedRevival(
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
      String title =
          'Your Reactivation/Revival Request For The Organization [' +
              orgName +
              '] Has Been Rejected';
      String messageBody = 'Your request for revival of the organization ' +
          orgName +
          ' has been denied for the NJIT Event Planner App as of ' +
          dateFormatter.format(now) +
          '. The reason for rejection is as followed: [ ' +
          reasonforRejection +
          ' ] As a listed E-Board member, ' +
          'we thought you would like to know of this update. Thank you for your attempt and we would be glad' +
          ' to look at any further organization reactivation requests! This message ' +
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
          'Error sending message alerting eboard members of organization revival rejection: ' +
              error.toString());
    }
  }

  Future<bool> messageMembersAboutApprovedRevival(Organization org) async {
    try {
      String orgName = org.name;
      DateFormat dateFormatter = new DateFormat('E yyyy-MM-dd');
      DateTime now = DateTime.now();
      DateTime expiryDate = now.add(Duration(days: 14));
      List<String> recipientUCIDS = List<String>();
      for (OrganizationMember eBoardMember in org.eBoardMembers) {
        recipientUCIDS.add(eBoardMember.ucid);
      }
      for (OrganizationMember regularMember in org.regularMembers) {
        recipientUCIDS.add(regularMember.ucid);
      }
      String title = 'The Revival Request For The Organization [' +
          orgName +
          '] Has Been Approved!';
      String messageBody = 'Congratulations, your organization ' +
          orgName +
          ' has been accepted into the NJIT Event Planner App as of ' +
          dateFormatter.format(now) +
          '! As a member, ' +
          'we thought you would be interested in this update. Thanks for your continued patronage! This message ' +
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
          'Error sending message alerting members of organization reactivation approval: ' +
              error.toString());
    }
  }

  /*EBOARD CHANGE REQUEST MESSAGES */
  Future<bool> sendMessageToAdminsAboutEboardChangeRequest(
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

  Future<bool> messageEboardMembersAboutApprovedEboardChangeRequest(
      OrganizationUpdateRequestData orgData) async {
    try {
      List<String> recipientUCIDs = List<String>();
      for (OrganizationMember originalEboardMember
          in orgData.original.eBoardMembers) {
        recipientUCIDs.add(originalEboardMember.ucid);
      }
      for (OrganizationMember updatedEboardMember
          in orgData.updated.eBoardMembers) {
        recipientUCIDs.add(updatedEboardMember.ucid);
      }
      recipientUCIDs = recipientUCIDs.toSet().toList();
      String orgName = orgData.updated.name;
      DateFormat expirationFormatter = new DateFormat('yyyy-MM-dd');
      DateTime curr = DateTime.now();
      DateTime expirationDate = curr.add(Duration(days: 14));
      String originalEboardMembers = '';
      String updatedEboardMembers = '';
      for (OrganizationMember originalEboardMember
          in orgData.original.eBoardMembers) {
        originalEboardMembers += "UCID: " +
            originalEboardMember.ucid +
            " Role: " +
            originalEboardMember.role +
            "\n";
      }
      for (OrganizationMember updatedEboardMember
          in orgData.updated.eBoardMembers) {
        updatedEboardMembers += "UCID: " +
            updatedEboardMember.ucid +
            " Role: " +
            updatedEboardMember.role +
            "\n";
      }
      String title = 'The E-Board Change Request For Organization [' +
          orgName +
          '] Has Been Approved';
      String messageBody = "An E-Board member from " +
          orgName +
          " requested an E-Board change for your organization. " +
          "The requested change is as followed: \n\nOriginal E-Board Members:\n" +
          originalEboardMembers +
          "\nChanged E-Board Members:\n" +
          updatedEboardMembers +
          "\nThe submitted request has been approved. As a former or current E-Board member for this organization, this is relevant information. " +
          "Please contact the admins for any further questions. " +
          " This message expires on " +
          expirationFormatter.format(expirationDate) +
          ".";
      bool messagesSent = await _messageProvider.sendMessage(
          _ucid, recipientUCIDs, title, messageBody, expirationDate);
      if (messagesSent) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error sending message alerting organization E-Board members of approved E-Board change request: ' +
              error.toString());
    }
  }

  Future<bool> messageEboardMembersAboutRejectedEboardChangeRequest(
      OrganizationUpdateRequestData orgData, String reason) async {
    try {
      List<String> recipientUCIDs = List<String>();
      for (OrganizationMember originalEboardMember
          in orgData.original.eBoardMembers) {
        recipientUCIDs.add(originalEboardMember.ucid);
      }
      for (OrganizationMember updatedEboardMember
          in orgData.updated.eBoardMembers) {
        recipientUCIDs.add(updatedEboardMember.ucid);
      }
      recipientUCIDs = recipientUCIDs.toSet().toList();
      String orgName = orgData.updated.name;
      DateFormat expirationFormatter = new DateFormat('yyyy-MM-dd');
      DateTime curr = DateTime.now();
      DateTime expirationDate = curr.add(Duration(days: 14));
      String originalEboardMembers = '';
      String updatedEboardMembers = '';
      for (OrganizationMember originalEboardMember
          in orgData.original.eBoardMembers) {
        originalEboardMembers += "UCID: " +
            originalEboardMember.ucid +
            " Role: " +
            originalEboardMember.role +
            "\n";
      }
      for (OrganizationMember updatedEboardMember
          in orgData.updated.eBoardMembers) {
        updatedEboardMembers += "UCID: " +
            updatedEboardMember.ucid +
            " Role: " +
            updatedEboardMember.role +
            "\n";
      }
      String title = 'The E-Board Change Request For Organization [' +
          orgName +
          '] Has Been Rejected';
      String messageBody = "An E-Board member from " +
          orgName +
          " requested an E-Board change for your organization. " +
          "The requested change is as followed: \n\nOriginal E-Board Members:\n" +
          originalEboardMembers +
          "\nChanged E-Board Members:\n" +
          updatedEboardMembers +
          "\nThe submitted request has been rejected for the listed reason: [" +
          reason +
          "]. As a former or current E-Board member for this organization, this is relevant information. " +
          "Please contact the admins for any further questions. " +
          " This message expires on " +
          expirationFormatter.format(expirationDate) +
          ".";
      bool messagesSent = await _messageProvider.sendMessage(
          _ucid, recipientUCIDs, title, messageBody, expirationDate);
      if (messagesSent) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error sending message alerting organization E-Board members of rejected E-Board change request: ' +
              error.toString());
    }
  }

  /* INACTIVATION MESSAGES */
  Future<bool> sendMessageToAdminsAboutInactivationRequest(
      Organization orgChanged, String reason) async {
    try {
      String orgName = orgChanged.name;
      DateFormat expirationFormatter = new DateFormat('yyyy-MM-dd');
      DateFormat requestDateFormatter = new DateFormat('E, MMMM dd');
      DateTime curr = DateTime.now();
      DateTime expirationDate = curr.add(Duration(days: 14));
      String title =
          'Please Approve Or Deny Organization Inactivation Request for Organization [' +
              orgName +
              ']';
      String messageBody = 'User ' +
          _ucid +
          " requested the inactivation of their organization " +
          orgName +
          " on " +
          requestDateFormatter.format(curr) +
          ". The reason provided for this change is as followed: [" +
          reason +
          "]. Please review the request and respond with the appropriate action on the Administration page. " +
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
          'Error sending message alerting admins of organization inactivation request: ' +
              error.toString());
    }
  }

  
  Future<bool> messageMembersAboutInactivation(Organization org) async {
    try {
      List<String> recipientUCIDs = List<String>();
      for (OrganizationMember eBoardMember in org.eBoardMembers) {
        recipientUCIDs.add(eBoardMember.ucid);
      }
      for (OrganizationMember member in org.regularMembers) {
        recipientUCIDs.add(member.ucid);
      }

      recipientUCIDs = recipientUCIDs.toSet().toList();
      String orgName = org.name;
      DateFormat expirationFormatter = new DateFormat('yyyy-MM-dd');
      DateTime curr = DateTime.now();
      DateTime expirationDate = curr.add(Duration(days: 14));

      String title = 'The Organization [' + orgName + '] Has Been Inactivated';
      String messageBody = "An E-Board member from " +
          orgName +
          " requested inactivation of your organization. " +
          "The submitted request has been approved. " +
          "As a current member of this organization, this is relevant information. " +
          "Inactivation means the organization currently has ceased all activities until another group of students in future semesters chooses to revive it. " +
          "Please contact the admins and former E-Board members for any further questions. " +
          "This message expires on " +
          expirationFormatter.format(expirationDate) +
          ".";
      bool messagesSent = await _messageProvider.sendMessage(
          _ucid, recipientUCIDs, title, messageBody, expirationDate);
      if (messagesSent) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error sending message alerting organization E-Board members of refused inactivation request: ' +
              error.toString());
    }
  }

  Future<bool> messageEboardMembersAboutRefusedInactivationRequest(
      Organization org, String reason) async {
    try {
      List<String> recipientUCIDs = List<String>();
      for (OrganizationMember eBoardMember in org.eBoardMembers) {
        recipientUCIDs.add(eBoardMember.ucid);
      }

      recipientUCIDs = recipientUCIDs.toSet().toList();
      String orgName = org.name;
      DateFormat expirationFormatter = new DateFormat('yyyy-MM-dd');
      DateTime curr = DateTime.now();
      DateTime expirationDate = curr.add(Duration(days: 14));

      String title = 'The Inactivation Request For Organization [' +
          orgName +
          '] Has Been Refused';
      String messageBody = "An E-Board member from " +
          orgName +
          " requested inactivation of your organization. " +
          "The submitted request has been rejected for the listed reason: [" +
          reason +
          "]. As a current E-Board member for this organization, this is relevant information. " +
          "Please contact the admins for any further questions. " +
          " This message expires on " +
          expirationFormatter.format(expirationDate) +
          ".";
      bool messagesSent = await _messageProvider.sendMessage(
          _ucid, recipientUCIDs, title, messageBody, expirationDate);
      if (messagesSent) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception(
          'Error sending message alerting organization E-Board members of refused inactivation request: ' +
              error.toString());
    }
  }
}
