import '../../models/organization.dart';
import '../../models/event.dart';
import '../../api/database_event_api.dart';

//provides methods to deal with organizations (generally)
//form specific functions are in different providers
class OrganizationProvider {
  Future<bool> removeOrganization(Organization org) {
    return DatabaseEventAPI.removeOrganization(org);
  }

  Future<List<Organization>> allViewableOrganizations() async {
    List<Organization> orgs = await DatabaseEventAPI.getViewableOrganizations();
    if (orgs != null)
      orgs.sort(
          (Organization o1, Organization o2) => o1.name.compareTo(o2.name));
    return orgs;
  }

  Future<List<Organization>> allInactiveOrganizations() async {
    List<Organization> orgs = await DatabaseEventAPI.getInactiveOrganizations();
    if (orgs != null)
      orgs.sort(
          (Organization o1, Organization o2) => o1.name.compareTo(o2.name));
    return orgs;
  }

  Future<List<Organization>> allOrganizationsAwaitingApproval() async {
    List<Organization> orgs =
        await DatabaseEventAPI.getOrganizationsAwaitingApproval();
    if (orgs != null)
      orgs.sort(
          (Organization o1, Organization o2) => o1.name.compareTo(o2.name));
    return orgs;
  }

  Future<List<Organization>> allOrganizationsAwaitingInactivation() async {
    List<Organization> orgs =
        await DatabaseEventAPI.getOrganizationsAwaitingInactivation();
    if (orgs != null)
      orgs.sort(
          (Organization o1, Organization o2) => o1.name.compareTo(o2.name));
    return orgs;
  }

  Future<List<Organization>> allOrganizationsAwaitingReactivation() async {
    List<Organization> orgs =
        await DatabaseEventAPI.getOrganizationsAwaitingReactivation();
    if (orgs != null)
      orgs.sort(
          (Organization o1, Organization o2) => o1.name.compareTo(o2.name));
    return orgs;
  }

  Future<List<OrganizationUpdateRequestData>>
      allOrganizationsAwaitingEboardChange() {
    return DatabaseEventAPI.getOrganizationsAwaitingEboardChange();
  }

  Future<bool> setOrganizationStatus(
      OrganizationStatus status, Organization org) {
    return DatabaseEventAPI.setOrganizationStatus(status, org);
  }

  Future<bool> approveOrganization(Organization org) {
    return DatabaseEventAPI.approveOrganization(org);
  }

  Future<Organization> organizationInfo(String name) {
    return DatabaseEventAPI.getOrganizationInfo(name);
  }

  Future<bool> canEdit(String ucid, bool isAdmin, Event event) async {
    try {
      if (isAdmin) {
        return true;
      } else {
        Organization orgInfo = await organizationInfo(event.organization);
        if (orgInfo.eBoardMembers.singleWhere(
                (OrganizationMember member) => member.ucid == ucid,
                orElse: () => null) !=
            null) {
          return true;
        } else {
          //not sure if I should throw an error here? probably can continue on using program without
          //this working
          return false;
        }
      }
    } catch (error) {
      throw Exception(
          'Error in Organization Provider function organizationInfo: ' +
              error.toString());
    }
  }

  bool canSendOrganizationRequest(Organization organization) {
    if (organization.status == OrganizationStatus.AWAITING_EBOARD_CHANGE ||
        organization.status == OrganizationStatus.AWAITING_INACTIVATION)
      return false;
    else
      return true;
  }

  Future<bool> approveEboardChange(Organization organization) async {
    return DatabaseEventAPI.approveEboardChange(organization);
  }

  Future<bool> rejectEboardChanges(Organization organization) async {
    return DatabaseEventAPI.rejectEboardChanges(organization);
  }

  Future<bool> inactivateOrganization(Organization organization) async {
    return DatabaseEventAPI.inactivateOrganization(organization);
  }

  Future<bool> rejectRevival(Organization organization) async {
    return DatabaseEventAPI.rejectRevival(organization);
  }

  Future<bool> approveRevival(Organization organization) async {
    return DatabaseEventAPI.approveRevival(organization);
  }
}
