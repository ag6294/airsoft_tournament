import 'dart:io';
import 'package:path/path.dart' as ph;

import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseStorage _store = FirebaseStorage.instance;

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
      Player playerTemp = Player(
          id: 'null',
          email: user.email,
          nickname: user.displayName,
          isGM: false);

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
        isGM: playerTemp.isGM,
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

  static Future<void> userLogout() async {
    await _auth.signOut();
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

    print(
        '[FirebaseHelper/userSignUp] POST to /teams resolved in ${response.body}');

    return Team(id: json.decode(response.body)['name'], name: name);
  }

  static Future<Player> addCurrentPlayerToTeam(
      String teamId, Player loggedPlayer) async {
    final _authToken = await _auth.currentUser.getIdToken();
    var url = endPoint + '/teams/$teamId/players.json?auth=$_authToken';

    print(
        '[FirebaseHelper/userSignUp] PATCH to /players/${loggedPlayer.id} ${loggedPlayer.asMap} ');

    await http.patch(url,
        body: json.encode({loggedPlayer.id: loggedPlayer.asMap}));

    url = endPoint + '/players/${loggedPlayer.id}.json?auth=$_authToken';
    await http.patch(url,
        body: json.encode({'teamId': teamId, 'isGM': loggedPlayer.isGM}));

    return Player(
      id: loggedPlayer.id,
      email: loggedPlayer.email,
      nickname: loggedPlayer.email,
      teamId: teamId,
      isGM: loggedPlayer.isGM,
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

  static Future<Team> getTeamById(String id) async {
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

  static Future<Game> addGame(Game game) async {
    final _authToken = await _auth.currentUser.getIdToken();
    var url = endPoint + '/games.json?auth=$_authToken';

    print(
        '[FirebaseHelper/addGame] POST to /games, body = title : ${game.title}');

    var response = await http.post(url, body: json.encode(game.asMap));
    print(response.body);

    final String gameId = json.decode(response.body)['name'];

    final imageFile = File(game.imageUrl);
    final ref = _store
        .ref()
        .child('game_images')
        .child(gameId + ph.extension(imageFile.path));

    await ref.putFile(imageFile);

    final imageUrl = await ref.getDownloadURL();

    final uploadedGame = Game(
      id: gameId,
      imageUrl: imageUrl,
      date: game.date,
      description: game.description,
      lastModifiedBy: game.lastModifiedBy,
      lastModifiedOn: game.lastModifiedOn,
      place: game.place,
      title: game.title,
      hostTeamId: game.hostTeamId,
    );

    url = endPoint + '/games/$gameId.json?auth=$_authToken';

    print(
        '[FirebaseHelper/addGame] PATCH to /games, body = title : ${uploadedGame.title}');
    response = await http.patch(url, body: json.encode(uploadedGame.asMap));
    print(response.body);

    return uploadedGame;
  }

  static Future<List<Game>> fetchGames(String teamId) async {
    final _authToken = await _auth.currentUser.getIdToken();
    final url = endPoint +
        '/games.json?orderBy="hostTeamId"&equalTo="$teamId"&auth=$_authToken';

    print('[FirebaseHelper/fetchTeams] GET  /teams where hostTeamId : $teamId');

    final response = await http.get(url);
    Map<String, dynamic> map = json.decode(response.body);

    print('[FirebaseHelper/fetchTeams] GET  /teams resolved to $map');

    return map.map((k, v) => MapEntry(k, Game.fromMap(k, v))).values.toList();
  }
}
