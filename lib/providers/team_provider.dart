import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:airsoft_tournament/models/notification.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:airsoft_tournament/models/team_post.dart';
import 'package:flutter/foundation.dart';

class TeamsProvider extends ChangeNotifier {
  List<TeamPost> _posts = [];
  List<Player> _members = [];

  //newest on top
  List<TeamPost> get posts => List<TeamPost>.from(
      _posts..sort((a, b) => b.creationDate.compareTo(a.creationDate)));

  List<Player> get members => List<Player>.from(_members
    ..sort((a, b) =>
        a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase())));

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

  void logOut() {
    _posts = [];
    _members = [];
  }

  Future<void> fetchAndSetPosts(String teamId, bool isLoggedPlayerTeam) async {
    final newPosts = await FirebaseHelper.fetchTeamPosts(teamId);
    if (!isLoggedPlayerTeam)
      newPosts.removeWhere((element) => element.isPrivate);
    _posts = List<TeamPost>.from(newPosts);
    notifyListeners();
  }

  Future<void> addOrEditPost(TeamPost post) async {
    if (post.id == null) {
      //new
      final newPost = await FirebaseHelper.addTeamPost(post);
      _posts.add(newPost);
      sendNewPostNotifications(newPost, _members);
    } else {
      //edit
      final newPost = await FirebaseHelper.editTeamPost(post);
      _posts.removeWhere((element) => element.id.compareTo(post.id) == 0);
      _posts.add(newPost);
    }

    notifyListeners();
  }

  Future<void> sendNewPostNotifications(
      TeamPost post, List<Player> players) async {
    players.forEach((element) {
      FirebaseHelper.addNotification(CustomNotification(
        title: 'Nuova post in bacheca',
        description: 'E\' stato creato un nuovo post: ${post.title}',
        playerId: element.id,
        postId: post.id,
        read: false,
        type: notificationType.new_post,
        creationDate: DateTime.now(),
        expirationDate: DateTime.now().add(Duration(days: 30)),
      ));
    });
  }

  Future<void> deletePost(TeamPost post) async {
    FirebaseHelper.deletePost(post);
    _posts.removeWhere((element) => element.id.compareTo(post.id) == 0);

    notifyListeners();
  }

  Future<void> fetchAndSetMembers(String teamId) async {
    _members = await FirebaseHelper.fetchTeamMembers(teamId);
    notifyListeners();
  }

  Future<void> updateTeamMember(Player player) async {
    FirebaseHelper.updatePlayer(player);

    final index = _members.indexWhere((element) => element.id == player.id);
    _members.removeAt(index);
    _members.insert(index, player);
    notifyListeners();
  }

  Future<void> removeMemberFromTeam(Player player) async {
    Player updatedPlayer = Player(
      email: player.email,
      nickname: player.nickname,
      id: player.id,
      isGM: player.isGM,
      name: player.name,
      teamId: null,
      teamName: null,
      dateOfBirth: player.dateOfBirth,
      lastName: player.lastName,
      placeOfBirth: player.placeOfBirth,
    );
    FirebaseHelper.updatePlayer(updatedPlayer);
    final index = _members.indexWhere((element) => element.id == player.id);
    _members.removeAt(index);
    notifyListeners();
  }
}
