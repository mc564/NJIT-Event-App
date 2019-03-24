import '../api/login_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../api/database_event_api.dart';

class UserProvider {
  DatabaseEventAPI _dbAPI;
  String _authUCID;
  String _authPassword;
  User _user;
  List<UserTypes> _initialUserTypes;
  List<String> _initialFavoriteIds;
  Map<String, String> _initialOrgRoles;

  UserProvider() {
    _dbAPI = DatabaseEventAPI();
  }

  String get ucid => _user.ucid;
  String get name => _user.name;
  //all initial getters for use when logging in
  //state changes are maintained in the respective providers
  List<UserTypes> get initialUserTypes => _initialUserTypes;
  List<String> get initialFavoriteIds => _initialFavoriteIds;
  Map<String, String> get initialOrgRoles => _initialOrgRoles;

  void setAuthUCID(String ucid) {
    _authUCID = ucid;
  }

  void setAuthPassword(String password) {
    _authPassword = password;
  }

  void clearFormFields() {
    _authUCID = null;
    _authPassword = null;
  }

  //allows automatic login for the same device when app reopens
  Future<bool> autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String ucid = prefs.getString('ucid');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (ucid != null) {
      //TODO also verify that expirytime has not been passed
      _user = User(name: '', ucid: ucid);
      Map<String, dynamic> userInitialInfo = await _dbAPI.userInitialInfo(ucid);
      _initialUserTypes = userInitialInfo['types'];
      _initialFavoriteIds = userInitialInfo['favorites'];
      _initialOrgRoles = userInitialInfo['organizations'];
      return true;
    }
    return false;
  }

  Future<bool> authenticate() async {
    bool verified = await LoginAPI.loginVerified(_authUCID, _authPassword);
    if (verified) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('ucid', _authUCID);
      //TODO get actual expiryTime..
      prefs.setString('expiryTime', 'dummyval');
      _user = User(name: '', ucid: _authUCID);
      Map<String, dynamic> userInitialInfo = await _dbAPI.userInitialInfo(ucid);
      _initialUserTypes = userInitialInfo['types'];
      _initialFavoriteIds = userInitialInfo['favorites'];
      _initialOrgRoles = userInitialInfo['organizations'];
      clearFormFields();
      return true;
    }
    clearFormFields();
    return false;
  }

  Future<bool> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      prefs.remove('ucid');
      prefs.remove('expiryTime');
      print('cleared prefs and logout in auth provider');
      _user = null;
      return true;
    } catch (error) {
      return false;
    }
  }
}
