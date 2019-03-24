import '../models/organization.dart';
import '../api/database_event_api.dart';

//provides methods to deal with organizations, mostly for the organization page
class OrganizationProvider {
  DatabaseEventAPI _dbAPI;
  Organization _organization;
  Map<String, String> _eBoardMemberUCIDsToRoles;
  List<String> _regularMemberUCIDs;

  OrganizationProvider() {
    _dbAPI = DatabaseEventAPI();
  }

  void setName(String name) {
    _organization.name = name;
  }

  void setDescription(String desc) {
    _organization.description = desc;
  }

  void addEboardMember(String ucid, String role) {
    _eBoardMemberUCIDsToRoles[ucid] = role;
  }

  void addRegularMember(String ucid) {
    _regularMemberUCIDs.add(ucid);
  }

  Future<bool> addOrganization() {
    return _dbAPI.addOrganization(_organization);
  }

  String nameValidator(String name) {
    if (name == null || name.isEmpty)
      return 'Organization name is required.';
    else
      return null;
  }

  String descriptionValidator(String desc) {
    if (desc == null || desc.isEmpty)
      return 'Organization description is required.';
    else
      return null;
  }
  
}
