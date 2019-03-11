import 'package:http/http.dart' as http;

//TODO make it so that I can figure out someone's name from the housing login

//uses the NJIT webmail login api to validate login
class LoginAPI {
  static Future<bool> loginVerified(String ucid, String password) async {
    try {
      Map<String, String> map = {
        'ucid': ucid,
        'pass': password,
      };
      var url = "https://aevitepr2.njit.edu/myhousing/login.cfm";
      http.Response response = await http.post(url, body: map);
      if (response.statusCode == 302) {
        //redirect means user is verified because this particular page/api
        //redirects if a user is verified
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw Exception("Error in LoginAPI class: "+error.toString());
    }
  }
}
