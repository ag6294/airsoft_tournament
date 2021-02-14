import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:airsoft_tournament/helpers/shared_preferences_helper.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  Player _loggedPlayer;
  Team _loggedPlayerTeam;

  LoginProvider() {
    print('[LoginProvider] Constructor');
  }

  bool get isLogged {
    print('[LoginProvider/isLogged] : ${!(_loggedPlayer == null)}');
    return !(_loggedPlayer == null);
  }

  bool get hasTeam {
    print('[LoginProvider/isLogged] : ${!(_loggedPlayer == null)}');
    return !(_loggedPlayer.teamId == null);
  }

  Player get loggedPlayer => _loggedPlayer;

  Team get loggedPlayerTeam {
    print('loggedPlayerTeam = ${_loggedPlayerTeam.asMap}');
    return _loggedPlayerTeam;
  }

  Future<void> trySignIn(String email, String pwd) async {
    print('[LoginProvider/trySignIn] $email - $pwd');

    try {
      _loggedPlayer = await FirebaseHelper.userSignIn(email.toLowerCase(), pwd);
      await SharedPreferencesHelper.storeLoginData(email.toLowerCase(), pwd);
      await getAndSetLoggedPlayerTeam();
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> getAndSetLoggedPlayerTeam() async {
    print(
        '[LoginProvider/getAndSetLoggedPlayerTeam] get team ${_loggedPlayer.teamId}');
    if (loggedPlayer.teamId != null) {
      _loggedPlayerTeam = await FirebaseHelper.getTeamById(loggedPlayer.teamId);
      print(
          '[LoginProvider/getAndSetLoggedPlayerTeam] team: ${loggedPlayerTeam.asMap}');
    }
  }

  Future<void> tryAutoSignIn() async {
    print('[LoginProvider/tryAutoSignIn] Starting');

    final loginMap = await SharedPreferencesHelper.getLoginData();

    if (loginMap != null) {
      print(
          '[LoginProvider/tryAutoSignIn] User found in storage: ${loginMap['email']}');
      await trySignIn(loginMap['email'], loginMap['password']);
    }
    print('[LoginProvider/tryAutoSignIn] No user found in storage');
  }

  Future<void> trySignUp(String email, String pwd, String nickname) async {
    print('[LoginProvider/trySignup] $nickname | $email - $pwd');

    try {
      _loggedPlayer =
          await FirebaseHelper.userSignUp(email.toLowerCase(), pwd, nickname);
      await SharedPreferencesHelper.storeLoginData(email.toLowerCase(), pwd);

      // await GentiHelper.registerUser({
      //   player, pwd
      // });
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> updatePlayer(Player player) async {
    try {
      var newPlayer = await FirebaseHelper.updatePlayer(player);

      if (newPlayer.id == loggedPlayer.id) _loggedPlayer = newPlayer;
    } catch (e) {
      print(e);
      rethrow;
    }

    notifyListeners();
  }

  Future<Player> addNewPlayer(Player player) async {
    Player newPlayer;
    try {
      newPlayer = await FirebaseHelper.addNewPlayer(player);
    } catch (e) {
      print(e);
      rethrow;
    }

    return newPlayer;
  }

  Future<void> logOut() async {
    await SharedPreferencesHelper.logout();
    await FirebaseHelper.userLogout();
    _loggedPlayer = null;
    _loggedPlayerTeam = null;
    notifyListeners();
  }

  Future<void> createNewTeam({String name, String pwd}) async {
    print('[LoginProvider/createNewTeam] name = $name, pwd = $pwd');

    var team = await FirebaseHelper.createTeam(
      name: name,
      password: pwd,
    );

    _loggedPlayer = Player(
        id: _loggedPlayer.id,
        isGM: true,
        email: _loggedPlayer.email.toLowerCase(),
        nickname: _loggedPlayer.nickname,
        teamId: loggedPlayer.teamId);

    _loggedPlayer =
        await FirebaseHelper.addCurrentPlayerToTeam(team.id, loggedPlayer);
    _loggedPlayerTeam = await FirebaseHelper.getTeamById(loggedPlayer.teamId);
    notifyListeners();
  }

  Future<void> tryTeamLogin({String teamId}) async {
    print('[LoginProvider/tryTeamLogin] teamId = $teamId');
    await FirebaseHelper.addCurrentPlayerToTeam(teamId, loggedPlayer);

    _loggedPlayer =
        await FirebaseHelper.addCurrentPlayerToTeam(teamId, loggedPlayer);
    _loggedPlayerTeam = await FirebaseHelper.getTeamById(teamId);
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseHelper.resetPassword(email);
    } catch (e) {
      rethrow;
    }
  }
}
