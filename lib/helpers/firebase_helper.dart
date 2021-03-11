import 'dart:io';
import 'package:airsoft_tournament/constants/exceptions.dart';
import 'package:airsoft_tournament/models/team_post.dart';
import 'package:path/path.dart' as ph;

import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:airsoft_tournament/models/game_participation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseStorage _store = FirebaseStorage.instance;

// const endPoint = 'https://airsoft-tournament.firebaseio.com';
// const endPoint = 'https://airsoft-tournament.firebaseio.com/DEV';
const authority = 'airsoft-tournament.firebaseio.com';

class FirebaseHelper {
  static Future<Player> userSignUp(email, password, nickname) async {
    try {
      UserCredential uc = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = _auth.currentUser;
      Player playerTemp = Player(
          id: user.uid, email: user.email, nickname: nickname, isGM: false);

      var _authToken = await user.getIdToken();

      var path = '/players/${playerTemp.id}.json';
      var params = {
        'auth': _authToken,
      };
      var uri = Uri.https(authority, path, params);

      final body = json.encode(playerTemp.asMap);

      print(
          '[FirebaseHelper/userSignUp] PUT to ${uri.toString().substring(0, 50)}, body = $body');
      final response = await http.put(uri, body: body);
      print(
          '[FirebaseHelper/userSignUp] resolved to ${response.body.toString()}');

      return playerTemp;
    } on Exception catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<Player> updatePlayer(Player player) async {
    final _authToken = await _auth.currentUser.getIdToken();

    var path = '/players/${player.id}.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);

    final body = json.encode(player.asMap);

    print(
        '[FirebaseHelper/updatePlayer] PATCH to ${uri.toString().substring(0, 200)}, body = $body');
    final response = await http.patch(uri, body: body);
    print(
        '[FirebaseHelper/updatePlayer] resolved to ${response.body.toString()}');

    //todo remove team update
    path = '/teams/${player.teamId}/players/${player.id}.json';
    params = {
      'auth': _authToken,
    };
    uri = Uri.https(authority, path, params);

    print(
        '[FirebaseHelper/updatePlayer] PATCH to ${uri.toString().substring(0, 200)}, body = $body');
    final teamResponse = await http.patch(uri, body: body);
    print(
        '[FirebaseHelper/updatePlayer] resolved to ${teamResponse.body.toString()}');

    return player;
  }

  static Future<Player> addNewPlayer(Player player) async {
    final _authToken = await _auth.currentUser.getIdToken();

    var path = '/players.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);
    final body = json.encode(player.asMap);

    print(
        '[FirebaseHelper/addNewPlayer] POST to ${uri.toString().substring(0, 50)}, body = $body');
    final response = await http.post(uri, body: body);
    print(
        '[FirebaseHelper/addNewPlayer] resolved to ${response.body.toString()}');

    final playerId = json.decode(response.body)['name'];

    // path = '/players/$playerId.json';
    // params = {
    //   'auth': _authToken,
    // };
    // var uri = Uri.https(authority, path, params);
    //
    // print(
    //     '[FirebaseHelper/addNewPlayer] PATCH to ${url.substring(0, 20)}, body = $body');
    // await http.patch(uri, body: json.encode({'id': playerId}));

    return Player.fromMap(playerId, player.asMap);
  }

  static Future<Player> getPlayerById(String id) async {
    try {
      final _authToken = await _auth.currentUser.getIdToken();

      var path = '/players/$id.json';
      var params = {
        'auth': _authToken,
      };
      var uri = Uri.https(authority, path, params);

      print(
          '[FirebaseHelper/getPlayerById] GET to ${uri.toString().substring(0, 100)},');

      final response = await http.get(uri);

      print(
          '[FirebaseHelper/getPlayerById] resolved to ${response.body.toString()}');
      Map<String, dynamic> decodedResponse = json.decode(response.body);

      return Player.fromMap(id, decodedResponse);
    } catch (e) {
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

      var path = '/players/${user.uid}.json';
      var params = {
        'auth': _authToken,
      };
      var uri = Uri.https(authority, path, params);

      print(
          '[FirebaseHelper/userSignIn] GET to ${uri.toString().substring(0, 20)}');
      final response = await http.get(uri);
      print(
          '[FirebaseHelper/userSignIn] resolved to ${response.body.toString()}');

      final decodedResponse = json.decode(response.body);

      final player = Player.fromMap(user.uid, decodedResponse);

      return player;
    } on Exception catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<void> userLogout() async {
    await _auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<Team> createTeam({String name, String password}) async {
    final _authToken = await _auth.currentUser.getIdToken();

    var path = '/teams.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);

    print(
        '[FirebaseHelper/createTeam] GET to ${uri.toString().substring(0, 200)}');

    var response = await http.post(uri,
        body: json.encode({
          'name': name,
          'password': password,
        }));

    print(
        '[FirebaseHelper/createTeam] resolved to ${response.body.toString()}');

    return Team(
        id: json.decode(response.body)['name'],
        name: name,
        players: [],
        password: password);
  }

  static Future<Team> editTeam(Team team, String oldImageUrl) async {
    final _authToken = await _auth.currentUser.getIdToken();

    var path = '/teams/${team.id}.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);
    String imageUrl;

    try {
      if (team.imageUrl != null &&
          team.imageUrl != '' &&
          !isNetworkImage(team.imageUrl)) {
        removeFile(oldImageUrl);

        final imageFile = File(team.imageUrl);
        final ref = _store
            .ref()
            .child('team_images')
            .child(team.id + ph.extension(imageFile.path));

        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      } else
        imageUrl = team.imageUrl;

      print(
          '[FirebaseHelper/updateTeam] GET to ${uri.toString().substring(0, 200)}');

      final uploadedTeam = Team(
        id: team.id,
        imageUrl: imageUrl,
        description: team.description,
        name: team.name,
        players: team.players,
        password: team.password,
        contacts: team.contacts,
      );

      await http.patch(uri, body: json.encode(uploadedTeam.asMap));

      return uploadedTeam;
    } catch (e) {
      imageUrl = team.imageUrl;
      throw (e);
    }
  }

  static Future<Player> addCurrentPlayerToTeam(
      String teamId, Player loggedPlayer) async {
    final _authToken = await _auth.currentUser.getIdToken();

    //todo remove team update
    var path = '/teams/$teamId/players.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);
    print(
        '[FirebaseHelper/addCurrentPlayerToTeam] player: ${loggedPlayer.id}, team: $teamId ');

    await http.patch(uri,
        body: json.encode({loggedPlayer.id: loggedPlayer.asMap}));

    path = '/players/${loggedPlayer.id}.json';
    params = {
      'auth': _authToken,
    };
    uri = Uri.https(authority, path, params);
    await http.patch(uri,
        body: json.encode({'teamId': teamId, 'isGM': loggedPlayer.isGM}));

    return Player(
      id: loggedPlayer.id,
      email: loggedPlayer.email,
      nickname: loggedPlayer.nickname,
      teamId: teamId,
      isGM: loggedPlayer.isGM,
    );
  }

  static Future<List<Team>> fetchTeams() async {
    try {
      final _authToken = await _auth.currentUser.getIdToken();
      final path = '/teams.json';
      var params = {
        'auth': _authToken,
      };
      var uri = Uri.https(authority, path, params);

      final response = await http.get(uri);
      Map<String, dynamic> decodedResponse = json.decode(response.body);

      return decodedResponse != null
          ? decodedResponse
              .map((key, value) => MapEntry(key, Team.fromMap(key, value, [])))
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
      final path = '/teams/$id.json';

      var params = {
        'auth': _authToken,
      };
      var uri = Uri.https(authority, path, params);

      print('[FirebaseHelper/getTeamById] GET /teams, id: $id');
      final response = await http.get(uri);
      Map<String, dynamic> decodedResponse = json.decode(response.body);

      print('[FirebaseHelper/getTeamById] resolved in $decodedResponse');

      final players = await fetchTeamMembers(id);

      return Team.fromMap(id, decodedResponse, players);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  static Future<List<Player>> fetchTeamMembers(String teamId) async {
    try {
      final _authToken = await _auth.currentUser.getIdToken();

      final path = '/players.json';
      var params = {
        'orderBy': '\"teamId\"',
        'equalTo': '\"$teamId\"',
        'auth': _authToken,
      };
      var uri = Uri.https(authority, path, params);

      print(
          '[FirebaseHelper/fetchTeamMembers] GET to ${uri.toString().substring(0, 200)}');
      final response = await http.get(uri);
      print(
          '[FirebaseHelper/fetchTeamMembers] resolved to ${response.body.toString()}');
      Map<String, dynamic> map = json.decode(response.body);

      return map
          .map((key, value) => MapEntry(key, Player.fromMap(key, value)))
          .values
          .toList();
    } on Exception catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<Game> addGame(Game game) async {
    final _authToken = await _auth.currentUser.getIdToken();

    String body;
    String path;
    Map<String, dynamic> params;

    String gameId;

    try {
      path = '/games.json';
      var params = {
        'auth': _authToken,
      };
      var uri = Uri.https(authority, path, params);
      body = json.encode(game.asMap);

      print(
          '[FirebaseHelper/addGame] POST to ${uri.toString().substring(0, 20)}, body = $body');
      final response = await http.post(uri, body: body);
      gameId = json.decode(response.body)['name'];
      print('[FirebaseHelper/addGame] resolved to ${response.body.toString()}');
    } catch (e) {
      print(e);
      throw FirebaseDBException(e.toString());
    }

    print(
        '[FirebaseHelper/addGame] Uploading image to storage - imageFilePath: ${game.imageUrl}');
    final imageFile = File(game.imageUrl);

    final ref = _store
        .ref()
        .child('game_images')
        .child(gameId + ph.extension(imageFile.path));

    await ref.putFile(imageFile);

    final imageUrl = await ref.getDownloadURL();
    print(
        '[FirebaseHelper/addGame] Uploading image to storage - downloadUrl: $imageUrl');

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
      hostTeamName: game.hostTeamName,
      attachmentUrl: game.attachmentUrl,
      factions: game.factions,
      isPrivate: game.isPrivate,
    );

    path = '/games/$gameId.json';
    params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);
    body = json.encode(uploadedGame.asMap);

    print(
        '[FirebaseHelper/addGame] PATCH to ${uri.toString().substring(0, 200)}, body = $body');
    final response = await http.patch(uri, body: body);
    print('[FirebaseHelper/addGame] resolved to ${response.body.toString()}');

    return uploadedGame;
  }

  static Future<List<Game>> fetchGamesForTeam(String teamId) async {
    final _authToken = await _auth.currentUser.getIdToken();

    final path = '/games.json';
    var params = {
      'auth': _authToken,
      'orderBy': '\"hostTeamId\"',
      'equalTo': '\"$teamId\"',
    };
    var uri = Uri.https(authority, path, params);

    print(
        '[FirebaseHelper/fetchGamesForTeam] GET  /games where hostTeamId : $teamId');

    final response = await http.get(uri);
    Map<String, dynamic> map = json.decode(response.body);

    print('[FirebaseHelper/fetchGamesForTeam] GET  /games resolved to $map');

    return map.map((k, v) => MapEntry(k, Game.fromMap(k, v))).values.toList();
  }

  static Future<List<Game>> fetchFutureGames() async {
    final _authToken = await _auth.currentUser.getIdToken();
    final dataString =
        DateTime.now().subtract(Duration(days: 7)).toIso8601String();

    final path = '/games.json';
    var params = {
      'orderBy': '\"date\"',
      'startAt': '\"$dataString\"',
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);
    print(
        '[FirebaseHelper/fetchFutureGames] GET ${uri.toString().substring(0, 200)}');

    final response = await http.get(uri);
    Map<String, dynamic> map = json.decode(response.body);

    print('[FirebaseHelper/fetchFutureGames] GET  /games resolved to $map');

    return map.map((k, v) => MapEntry(k, Game.fromMap(k, v))).values.toList();
  }

  static Future<List<GameParticipation>> fetchUserParticipations(
      String playerId) async {
    final _authToken = await _auth.currentUser.getIdToken();

    final path = '/participations.json';
    var params = {
      'auth': _authToken,
      'orderBy': '\"playerId\"',
      'equalTo': '\"$playerId\"',
    };
    var uri = Uri.https(authority, path, params);

    print(
        '[FirebaseHelper/participations] GET  /participations where playerId : $playerId');

    final response = await http.get(uri);
    Map<String, dynamic> map = json.decode(response.body);

    print(
        '[FirebaseHelper/fetchParticipations] GET  /participations resolved to $map');

    return map
        .map((k, v) => MapEntry(k, GameParticipation.fromMap(k, v)))
        .values
        .toList();
  }

  static Future<List<GameParticipation>> fetchGameParticipations(
      String gameId) async {
    final _authToken = await _auth.currentUser.getIdToken();

    final path = '/participations.json';
    var params = {
      'auth': _authToken,
      'orderBy': '\"gameId\"',
      'equalTo': '\"$gameId\"',
    };
    var uri = Uri.https(authority, path, params);
    print(
        '[FirebaseHelper/fetchGameParticipations] GET  /participations where gameId : $gameId');

    final response = await http.get(uri);
    Map<String, dynamic> map = json.decode(response.body);

    print(
        '[FirebaseHelper/fetchGameParticipations] GET  /participations resolved to $map');

    return map
        .map((k, v) => MapEntry(k, GameParticipation.fromMap(k, v)))
        .values
        .toList();
  }

  static editParticipation(GameParticipation participation) async {
    final _authToken = await _auth.currentUser.getIdToken();

    final path = '/participations/${participation.id}.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);

    print(
        '[FirebaseHelper/editParticipation] PATCH to /participations, body = ${participation.asMap}');

    await http.patch(uri, body: json.encode(participation.asMap));

    return participation;
  }

  static addNewParticipation(GameParticipation participation) async {
    final _authToken = await _auth.currentUser.getIdToken();

    var path = '/participations.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);

    print(
        '[FirebaseHelper/addNewParticipation] POST to /participations, body = ${participation.asMap}');
    final response =
        await http.post(uri, body: json.encode(participation.asMap));

    print(
        '[FirebaseHelper/addNewParticipation] POST to /participations, resolved in ${json.decode(response.body)}');

    final id = json.decode(response.body)['name'];

    path = '/participations/$id.json';
    params = {
      'auth': _authToken,
    };
    uri = Uri.https(authority, path, params);

    await http.patch(uri, body: json.encode({'id': id}));

    return GameParticipation.fromMap(id, participation.asMap);
  }

  static Future<void> deleteGame(Game game) async {
    final _authToken = await _auth.currentUser.getIdToken();
    var path = '/games/${game.id}.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);

    print(
        '[FirebaseHelper/deleteGame] DELETE DELETE to ${uri.toString().substring(0, 200)}');
    var response = await http.delete(uri);
    print(
        '[FirebaseHelper/deleteGame] DELETE to /games, resolved in ${response.statusCode.toString()}');

    print(
        '[FirebaseHelper/deleteGame] Removing image from storage : ${game.imageUrl}');
    await _store.refFromURL(game.imageUrl).delete();

    final participations = await fetchGameParticipations(game.id);

    participations.forEach((element) {
      final path = '/participations/${element.id}.json';
      final params = {
        'auth': _authToken,
      };
      final uri = Uri.https(authority, path, params);

      print(
          '[FirebaseHelper/deleteGame] DELETE to ${uri.toString().substring(0, 200)}');
      http.delete(uri).then((value) => print(
          '[FirebaseHelper/deleteGame] DELETE resolved in ${value.statusCode.toString()}'));
    });
  }

  // static Future<void> deleteParticipationsForGame(Game game) async {
  //   final _authToken = await _auth.currentUser.getIdToken();
  //
  //   final path = '/participations.json';
  //   var params = {
  //     'auth': _authToken,
  //     'orderBy': 'gameId',
  //     'equalTo': game.id,
  //   };
  //   var uri = Uri.https(authority, path, params);
  //
  //   print(
  //       '[FirebaseHelper/deletePost] DELETE to ${uri.toString().substring(0, 200)}');
  //   var response = await http.delete(uri);
  //   print(
  //       '[FirebaseHelper/deletePost]resolved to ${json.decode(response.body)}');
  // }

  static Future<Game> editGame(Game game, String oldImageUrl) async {
    final _authToken = await _auth.currentUser.getIdToken();
    var path = '/games/${game.id}.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);

    String imageUrl;

    try {
      if (!isNetworkImage(game.imageUrl)) {
        removeFile(oldImageUrl);

        final imageFile = File(game.imageUrl);
        final ref = _store
            .ref()
            .child('game_images')
            .child(game.id + ph.extension(imageFile.path));

        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      } else
        imageUrl = game.imageUrl;

      print(
          '[FirebaseHelper/addGame] PATCH to /games, body = title : ${game.title}');

      final uploadedGame = Game(
        id: game.id,
        imageUrl: imageUrl,
        date: game.date,
        description: game.description,
        lastModifiedBy: game.lastModifiedBy,
        lastModifiedOn: game.lastModifiedOn,
        place: game.place,
        title: game.title,
        hostTeamId: game.hostTeamId,
        hostTeamName: game.hostTeamName,
        attachmentUrl: game.attachmentUrl,
        isPrivate: game.isPrivate,
        factions: game.factions,
      );

      await http.patch(uri, body: json.encode(uploadedGame.asMap));

      return uploadedGame;
    } catch (e) {
      imageUrl = game.imageUrl;
      throw (e);
    }
  }

  static Future<void> removeFile(String url) async {
    print('[FirebaseHelper/removeFile] Removing file from storage : $url');
    await _store.refFromURL(url).delete();
  }

  static bool isNetworkImage(String url) {
    return url == null ? false : url.contains('firebasestorage');
  }

  static Future<TeamPost> editTeamPost(TeamPost post) async {
    final _authToken = await _auth.currentUser.getIdToken();
    final path = '/posts/${post.id}.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);
    final body = json.encode(post.asMap);

    print(
        '[FirebaseHelper/editTeamPost] PATCH to ${uri.toString().substring(0, 20)}, body = $body');
    final response = await http.patch(uri, body: body);

    print(
        '[FirebaseHelper/editTeamPost] resolved to ${response.body.toString()}');

    return post;
  }

  static Future<TeamPost> addTeamPost(TeamPost post) async {
    final _authToken = await _auth.currentUser.getIdToken();

    final path = '/posts.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);
    final body = json.encode(post.asMap);

    print(
        '[FirebaseHelper/addTeamPost] POST to ${uri.toString().substring(0, 20)}, body = $body');
    final response = await http.post(uri, body: body);
    print(
        '[FirebaseHelper/addTeamPost] resolved to ${response.body.toString()}');

    final id = json.decode(response.body)['name'];

    // url = endPoint + '/posts/$id.json?auth=$_authToken';
    // uri = Uri.dataFromString(url);
    // await http.patch(uri, body: json.encode({'id': id}));

    return TeamPost.fromMap(id, post.asMap);
  }

  static Future<List<TeamPost>> fetchTeamPosts(String teamId) async {
    final _authToken = await _auth.currentUser.getIdToken();

    final path = '/posts.json';
    var params = {
      'orderBy': '\"teamId\"',
      'equalTo': '\"$teamId\"',
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);

    print(
        '[FirebaseHelper/fetchTeamPosts] GET to ${uri.toString().substring(0, 200)}');
    final response = await http.get(uri);
    Map<String, dynamic> map = json.decode(response.body);

    return map
        .map((k, v) => MapEntry(k, TeamPost.fromMap(k, v)))
        .values
        .toList();
  }

  static Future<void> deletePost(TeamPost post) async {
    final _authToken = await _auth.currentUser.getIdToken();

    final path = '/posts/${post.id}.json';
    var params = {
      'auth': _authToken,
    };
    var uri = Uri.https(authority, path, params);

    print(
        '[FirebaseHelper/deletePost] DELETE to ${uri.toString().substring(0, 200)}');
    var response = await http.delete(uri);
    print(
        '[FirebaseHelper/deletePost]resolved to ${json.decode(response.body)}');
  }
}
