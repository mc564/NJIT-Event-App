import '../api/login_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../api/database_event_api.dart';
import '../models/authentication_results.dart';

//TODO figure out how to make an auth token to use with the api, or something similar
class UserProvider {
  String _authUCID;
  String _authPassword;
  User _user;
  List<UserTypes> _userTypes;

  String get ucid => _user.ucid;
  String get name => _user.name;

  List<UserTypes> get userTypes => _userTypes;

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
  Future<AuthenticationResults> autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String ucid = prefs.getString('ucid');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (ucid != null) {
      //TODO also verify that expirytime has not been passed
      _user = User(name: '', ucid: ucid);
      _userTypes = await DatabaseEventAPI.userTypes(ucid);
      if (_userTypes.contains(UserTypes.Banned)) {
        return AuthenticationResults(authenticated: true, banned: true);
      } else {
        return AuthenticationResults(authenticated: true, banned: false);
      }
    }
    return AuthenticationResults(authenticated: false, banned: false);
  }

  Future<AuthenticationResults> authenticate() async {
    bool verified = await LoginAPI.loginVerified(_authUCID, _authPassword);
    if (verified) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('ucid', _authUCID);
      //TODO get actual expiryTime..
      prefs.setString('expiryTime', 'dummyval');
      _user = User(name: '', ucid: _authUCID);
      _userTypes = await DatabaseEventAPI.userTypes(ucid);
      clearFormFields();
      if (_userTypes.contains(UserTypes.Banned)) {
        return AuthenticationResults(authenticated: true, banned: true);
      } else {
        return AuthenticationResults(authenticated: true, banned: false);
      }
    }
    clearFormFields();
    return AuthenticationResults(authenticated: false, banned: false);
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

  Future<bool> banUser(String ucid) async {
    return DatabaseEventAPI.banUser(ucid);
  }

  Future<bool> unbanUser(String ucid) async {
    return DatabaseEventAPI.unbanUser(ucid);
  }

  Future<List<User>> fetchBannedUsers() async {
    return DatabaseEventAPI.fetchBannedUsers();
  }
}
