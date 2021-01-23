import 'package:airsoft_tournament/constants/exceptions.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:http/http.dart' as http;

const endpoint = 'http://dev.airsofttacticalmaps.eu/api';

class GentiHelper {
  static Future<void> registerUser(Player player, String pwd) async {
    final url = endpoint + '/registerUser/';

    final map = {
      'id_firebase': player.id,
      'email': player.email,
      'pwd': pwd,
      'nickname': player.nickname,
      'sono': player.isGM ? '99' : '0',
    };

    try {
      print('[GentiHelper/registerUser] POST to $url, body = $map');
      final response = await http.post(url, body: map);
      print(
          '[GentiHelper/registerUser] resolved to ${response.body.toString()}');
    } catch (e) {
      print(e);
      throw GentiAPIException(e.toString());
    }
  }

  static Future<void> editUser(Player player, {String pwd}) async {
    final url = endpoint + '/editUser/';
    final map = {
      'id_firebase': player.id,
      'email': player.email,
      'nickname': player.nickname,
      'sono': player.isGM ? '99' : '0',
    };

    if (pwd != null) map.addAll({'pwd': pwd});

    try {
      print('[GentiHelper/registerUser] POST to $url, body = $map');
      final response = await http.post(url, body: map);
      print(
          '[GentiHelper/registerUser] resolved to ${response.body.toString()}');
    } catch (e) {
      print(e);
      throw GentiAPIException(e.toString());
    }
  }

  static Future<void> createChannel(Faction faction) async {
    final url = endpoint + '/createChannel/';

    final map = {'id': faction.id, 'name': faction.name};

    try {
      print('[GentiHelper/createChannel] POST to $url, body = $map');
      final response = await http.post(url, body: map);
      print(
          '[GentiHelper/createChannel] resolved to ${response.body.toString()}');
    } catch (e) {
      print(e);
      throw GentiAPIException(e.toString());
    }
  }
}
