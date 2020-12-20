import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<void> storeLoginData(String email, String pwd) async {
    final _prefs = await SharedPreferences.getInstance();

    _prefs.setString(
      'loginData',
      json.encode({
        'email': email,
        'password': pwd,
      }),
    );
  }

  static Future<Map<String, String>> getLoginData() async {
    final _prefs = await SharedPreferences.getInstance();

    final string = _prefs.getString('loginData');

    if (string != null && string != '') {
      final map = json.decode(string);

      return {
        'email': map['email'],
        'password': map['password'],
      };
    }
    return null;
  }

  static Future<void> logout() async {
    final _prefs = await SharedPreferences.getInstance();
    await _prefs.clear();
  }
}
