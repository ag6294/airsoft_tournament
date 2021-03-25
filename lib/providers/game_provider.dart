import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_invitation.dart';
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
      isPresent = isPresent || teamId == element.teamId;
    });
    return isPresent;
  }

  Future<void> addInvitation(GameInvitation invitation) async {
    _invitations.add(invitation);
    FirebaseHelper.addInvitation(invitation);

    notifyListeners();
  }
}
