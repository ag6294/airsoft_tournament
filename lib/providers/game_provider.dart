import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_invitation.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:flutter/foundation.dart';

class GameProvider extends ChangeNotifier {
  final Game game;

  List<GameInvitation> _invitations = [];
  List<GameInvitation> get invitations => List.from([..._invitations]);

  GameProvider(this.game);

  Future<void> fetchAndSetInvitations() async {
    _invitations = await FirebaseHelper.fetchGameInvitations(game.id);
  }

  bool isInvited(String teamId) {
    var isPresent = false;
    _invitations.forEach((element) {
      isPresent = (isPresent || teamId == element.teamId);
    });
    return isPresent;
  }

  Future<void> addInvitation(GameInvitation invitation) async {
    _invitations.add(invitation);
    FirebaseHelper.addInvitation(invitation);

    notifyListeners();

    //todo mandare notifiche a tutto il mondo belin di dio
    // FirebaseHelper.addNotification(notification)
  }

  Future<void> removeInvitation(GameInvitation invitation) async {
    _invitations.removeWhere((element) => element.id == invitation.id);
    FirebaseHelper.deleteInvitation(invitation);

    notifyListeners();

    //todo mandare notifiche a tutto il mondo belin di dio
    // FirebaseHelper.addNotification(notification)
    //todo eliminare partecipazioni di questo team alla giocata
  }

  List<Team> invitableTeams(List<Team> allTeams) {
    return List<Team>.from(allTeams
      ..removeWhere(
          (element) => element.id == game.hostTeamId || isInvited(element.id)));
  }
}
