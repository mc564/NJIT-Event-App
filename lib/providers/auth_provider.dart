import '../api/login_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider {
  String _ucid;
  String _password;
  User _user;

  void setUCID(String ucid) {
    _ucid = ucid;
  }

  void setPassword(String password) {
    _password = password;
  }

  void clearFormFields() {
    _ucid = null;
    _password = null;
  }

  //allows automatic login for the same device when app reopens
  Future<bool> autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String ucid = prefs.getString('ucid');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (ucid != null) {
      //TODO also verify that expirytime has not been passed
      _user = User(name: '', ucid: ucid);
      return true;
    }
    return false;
  }

  Future<bool> authenticate() async {
    bool verified = await LoginAPI.loginVerified(_ucid, _password);
    if (verified) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('ucid', _ucid);
      //TODO get actual expiryTime..
      prefs.setString('expiryTime', 'dummyval');
      _user = User(name: '', ucid: _ucid);
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
      return true;
    } catch (error) {
      return false;
    }
  }
}
