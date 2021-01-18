import 'package:http/http.dart' as http;
import 'dart:convert';

class GentiHelper {
  static Future<void> registerUser(Map<String, dynamic> map) async {
    final url = 'http://dev.airsofttacticalmaps.eu/api/registerUser/';

    print(json.encode(map));

    final response = await http.post(url, body: map);
    print(response.body.toString());
  }
}
