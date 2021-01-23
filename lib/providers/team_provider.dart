import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:flutter/foundation.dart';

class TeamsProvider extends ChangeNotifier {
  Future<List<Team>> fetchTeams() async {
    List<Team> teams = [];
    print('[LoginProvider/fetchTeams] starting');

    teams = await FirebaseHelper.fetchTeams();
    teams.sort((a, b) => a.name.compareTo(b.name));
    print(
        '[LoginProvider/fetchTeams] ${teams.map((e) => '|| name: ${e.name}, id: ${e.id}')}');

    return teams;
  }

  Future<void> editTeam(Team team, String oldImageUrl) async {
    print('[TeamProvider/editTeam] edit team ${team.id}');

    await FirebaseHelper.editTeam(team, oldImageUrl);
  }

  Future<Team> getTeamById(String id) async {
    print('[TeamProvider/getTeamById] get team $id}');

    return await FirebaseHelper.getTeamById(id);
  }

  void logOut() {}
}
