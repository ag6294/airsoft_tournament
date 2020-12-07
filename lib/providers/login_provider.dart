import 'package:airsoft_tournament/helpers/firebase_helper.dart';
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

  Team get loggedPlayerTeam => _loggedPlayerTeam;

  Future<void> trySignIn(String email, String pwd) async {
    print('[LoginProvider/trySignIn] $email - $pwd');

    try {
      _loggedPlayer = await FirebaseHelper.userSignIn(email, pwd);
      if (loggedPlayer.teamId != null)
        _loggedPlayerTeam =
            await FirebaseHelper.getTeambyId(loggedPlayer.teamId);
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> trySignUp(String email, String pwd, String nickname) async {
    print('[LoginProvider/trySignup] $nickname | $email - $pwd');

    try {
      _loggedPlayer = await FirebaseHelper.userSignUp(email, pwd, nickname);
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> createNewTeam({String name, String pwd}) async {
    print('[LoginProvider/createNewTeam] name = $name, pwd = $pwd');

    var team = await FirebaseHelper.createTeam(
      name: name,
      password: pwd,
    );

    _loggedPlayer =
        await FirebaseHelper.addCurrentPlayerToTeam(team.id, loggedPlayer);
    _loggedPlayerTeam = await FirebaseHelper.getTeambyId(loggedPlayer.teamId);
    notifyListeners();
  }

  Future<void> tryTeamLogin({String teamId}) async {
    print('[LoginProvider/tryTeamLogin] teamId = $teamId');
    await FirebaseHelper.addCurrentPlayerToTeam(teamId, loggedPlayer);

    _loggedPlayer =
        await FirebaseHelper.addCurrentPlayerToTeam(teamId, loggedPlayer);
    _loggedPlayerTeam = await FirebaseHelper.getTeambyId(teamId);
    notifyListeners();
  }

  Future<List<Team>> fetchTeams() async {
    List<Team> teams = [];
    print('[LoginProvider/fetchTeams] starting');

    teams = await FirebaseHelper.fetchTeams();
    print(
        '[LoginProvider/fetchTeams] ${teams.map((e) => '|| name: ${e.name}, id: ${e.id}')}');

    return teams;
  }
}
