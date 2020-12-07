import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FirebaseAuth _auth = FirebaseAuth.instance;

const endPoint = 'https://airsoft-tournament.firebaseio.com/';

class FirebaseHelper {
  static Future<Player> userSignUp(email, password, nickname) async {
    try {
      UserCredential uc = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await uc.user.updateProfile(displayName: nickname);
      User user = _auth.currentUser; //uc.user;
      Player playerTemp =
          Player(id: 'null', email: user.email, nickname: user.displayName);

      var _authToken = await user.getIdToken();
      var url = endPoint + '/players.json?auth=$_authToken';

      print(
          '[FirebaseHelper/userSignUp] POST to /players, body = ${playerTemp.asMap}');
      final response =
          await http.post(url, body: json.encode(playerTemp.asMap));

      final playerId = json.decode(response.body)['name'];

      url = endPoint + '/players/$playerId.json?auth=$_authToken';
      await http.patch(url, body: json.encode({'id': playerId}));

      return Player(
        id: playerId,
        nickname: playerTemp.nickname,
        email: playerTemp.email,
        teamId: null,
      );
    } on Exception catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<Player> userSignIn(email, password) async {
    try {
      UserCredential uc = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = uc.user;

      final _authToken = await user.getIdToken();
      final url = endPoint +
          '/players.json?orderBy="email"&equalTo="$email"&auth=$_authToken';

      print('[FirebaseHelper/userSignIn] GET  /players where email : $email');
      final response = await http.get(url);
      final decodedResponse = json.decode(response.body);

      final player = Player.fromMap(
          decodedResponse.keys.first, decodedResponse.values.first);

      return player;
    } on Exception catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<Team> createTeam({String name, String password}) async {
    final _authToken = await _auth.currentUser.getIdToken();
    final url = endPoint + '/teams.json?auth=$_authToken';

    print(
        '[FirebaseHelper/userSignUp] POST to /teams, body = name : $name, password : $password ');
    var response = await http.post(url,
        body: json.encode({
          'name': name,
          'password': password,
        }));

    print(response.body);

    return Team(id: json.decode(response.body)['name'], name: name);
  }

  static Future<Player> addCurrentPlayerToTeam(
      String teamId, Player loggedPlayer) async {
    final _authToken = await _auth.currentUser.getIdToken();

    var url = endPoint + '/teams/$teamId/players.json?auth=$_authToken';
    await http.patch(url,
        body: json.encode({loggedPlayer.id: loggedPlayer.asMap}));

    url = endPoint + '/players/${loggedPlayer.id}.json?auth=$_authToken';
    await http.patch(url, body: json.encode({'teamId': teamId}));

    return Player(
      id: loggedPlayer.id,
      email: loggedPlayer.email,
      nickname: loggedPlayer.email,
      teamId: teamId,
    );
  }

  static Future<List<Team>> fetchTeams() async {
    try {
      final _authToken = await _auth.currentUser.getIdToken();
      final url = endPoint + '/teams.json?auth=$_authToken';

      final response = await http.get(url);
      Map<String, dynamic> decodedResponse = json.decode(response.body);

      return decodedResponse != null
          ? decodedResponse
              .map((key, value) => MapEntry(key, Team.fromMap(key, value)))
              .values
              .toList()
          : [];
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<Team> getTeambyId(String id) async {
    try {
      final _authToken = await _auth.currentUser.getIdToken();
      final url = endPoint + '/teams/$id.json?auth=$_authToken';

      final response = await http.get(url);
      Map<String, dynamic> decodedResponse = json.decode(response.body);

      return Team.fromMap(id, decodedResponse);
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
