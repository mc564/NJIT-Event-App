import 'dart:convert'; // Contains the JSON encoder

import 'package:http/http.dart'; // Contains a client for making API calls
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements

class WebScraper {
  static Future<Null> test() async {
    var client = Client();
    Response response = await client
        .get('http://directory.njit.edu/PersDetails.aspx?persid=mc564');

    print(response.body);
  }
}
