import 'dart:io';
import 'package:intl/intl.dart';

import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_invitation.dart';
import 'package:airsoft_tournament/models/game_participation.dart';
import 'package:airsoft_tournament/models/notification.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/models/team.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class GameProvider extends ChangeNotifier {
  final Game game;

  List<GameParticipation> _gameParticipations = [];

  bool filteringOnStatus = false;
  bool filteringOnFaction = false;
  participationStatus filterStatus;
  String filterFaction;

  List<GameParticipation> _filteredGameParticipations = [];
  List<Player> _notReplyingPlayers = [];
  List<Player> _filteredNotReplyingPlayers = [];
  int selectedKpi = -1;

  List<GameInvitation> _invitations = [];
  List<GameInvitation> get invitations => List.from([..._invitations]);

  GameProvider(this.game);

  List<GameParticipation> get gameParticipations => _gameParticipations;
  List<GameParticipation> get filteredGameParticipations =>
      _filteredGameParticipations;
  List<Player> get notReplyingPlayers => _notReplyingPlayers
    ..sort((Player a, Player b) =>
        a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase()));
  List<Player> get filteredNotReplyingPlayers => _filteredNotReplyingPlayers
    ..sort((Player a, Player b) =>
        a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase()));

  Future<void> fetchAndSetInvitations() async {
    _invitations = await FirebaseHelper.fetchGameInvitations(game.id);
    notifyListeners();
  }

  bool isTeamInvited(String teamId) {
    var isPresent = false;
    _invitations.forEach((element) {
      isPresent = (isPresent || teamId == element.teamId);
    });
    return isPresent;
  }

  bool isPlayerInvited(Player player) {
    return game.hostTeamId.compareTo(player.teamId) == 0 ||
        isTeamInvited(player.teamId);
  }

  Future<void> addInvitation(GameInvitation invitation) async {
    _invitations.add(invitation);
    FirebaseHelper.addInvitation(invitation);

    notifyListeners();

    final players = await FirebaseHelper.fetchTeamMembers(invitation.teamId);
    players
        .forEach((element) => FirebaseHelper.addNotification(CustomNotification(
              gameId: game.id,
              title: 'Sei stato invitato a una giocata',
              description:
                  'Inserisci la presenza per ${game.title}, organizzata da ${game.hostTeamName}',
              playerId: element.id,
              read: false,
              type: notificationType.invitation,
              creationDate: DateTime.now(),
              expirationDate: game.date,
            )));
  }

  Future<void> removeInvitation(GameInvitation invitation) async {
    _invitations.removeWhere((element) => element.id == invitation.id);
    FirebaseHelper.deleteInvitation(invitation);

    notifyListeners();

    final idsToRemove = [];

    _gameParticipations.forEach((element) {
      if (element.playerTeamId == invitation.teamId) {
        idsToRemove.add(element);
      }
    });

    idsToRemove.forEach((element) {
      deleteParticipation(element);
    });
  }

  List<Team> invitableTeams(List<Team> allTeams) {
    return List<Team>.from(allTeams
      ..removeWhere((element) =>
          element.id == game.hostTeamId || isTeamInvited(element.id)));
  }

  Future<void> exportParticipations(Game game, String loggedPlayerEmail) async {
    var participations = await FirebaseHelper.fetchGameParticipations(game.id);
    List<Player> players = [];

    for (GameParticipation element in participations) {
      if (element.isGoing) {
        final newPlayer = await FirebaseHelper.getPlayerById(element.playerId);
        players.add(newPlayer);
      }
    }

    final path = await getLocalPath();
    final fileName =
        'participations_${game.title}_${DateTime.now().millisecondsSinceEpoch}';
    final filePath = '$path/$fileName.csv';
    final file = await File(filePath).create();

    final rows = players?.map((e) => e.asRow)?.toList();
    rows?.insert(0, [
      'Email',
      'Nickname',
      'Nome',
      'Cognome',
      'Luogo di nascita',
      'Data di nascita',
    ]);

    final csv = ListToCsvConverter().convert(rows);
    file.writeAsString(csv);

    final Email email = Email(
      body:
          'In allegato la lista dei presenti per la giocata ${game.title} del ${DateFormat('dd/MM/yyyy').format(game.date)}',
      subject:
          '${DateFormat('dd/MM/yyyy').format(game.date)} ${game.title} - Presenti',
      recipients: [loggedPlayerEmail],
      isHTML: true,
      attachmentPaths: [filePath],
    );

    await FlutterEmailSender.send(email);
  }

  int getKpiForStatus(participationStatus status) {
    switch (status) {
      case participationStatus.going:
        return _gameParticipations.where((element) => element.isGoing).length;

      case participationStatus.not_going:
        return _gameParticipations.where((element) => !element.isGoing).length;

      case participationStatus.not_replied:
        return notReplyingPlayers.length;

      default:
        return 0;
    }
  }

  int getKpiForFaction(String factionId) {
    return List.from(_gameParticipations.where(
        (element) => factionId.compareTo(element.faction ?? '') == 0)).length;
  }

  void sortParticipations() {
    _gameParticipations
      ..sort((a, b) {
        if (a.isGoing && !b.isGoing) return -1;
        if (!a.isGoing && b.isGoing) return 1;
        if (a.faction == null) return -1;
        if (b.faction == null) return 1;
        return a.faction.compareTo(b.faction);
      });

    _filteredGameParticipations
      ..sort((a, b) {
        if (a.isGoing && !b.isGoing) return -1;
        if (!a.isGoing && b.isGoing) return 1;
        if (a.faction == null) return -1;
        if (b.faction == null) return 1;
        return a.faction.compareTo(b.faction);
      });

    notifyListeners();
  }

  void resetFilterHelpers() {
    filteringOnStatus = false;
    filteringOnFaction = false;
    filterStatus = null;
    filterFaction = null;
  }

  void filterParticipationsByStatus(participationStatus status, int kpiIndex) {
    selectedKpi = kpiIndex;

    resetFilterHelpers();
    filteringOnStatus = true;
    filterStatus = status;

    switch (status) {
      case participationStatus.going:
        {
          _filteredGameParticipations = List<GameParticipation>.from(
              _gameParticipations.where((element) => element.isGoing));
          _filteredNotReplyingPlayers = [];
        }
        break;
      case participationStatus.not_going:
        {
          _filteredGameParticipations = List<GameParticipation>.from(
              _gameParticipations.where((element) => !element.isGoing));
          _filteredNotReplyingPlayers = [];
        }
        break;
      case participationStatus.not_replied:
        {
          _filteredGameParticipations = [];
          _filteredNotReplyingPlayers = notReplyingPlayers;
        }
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void filterParticipationsByFaction(String factionId, int kpiIndex) {
    selectedKpi = kpiIndex;

    resetFilterHelpers();
    filteringOnFaction = true;
    filterFaction = factionId;

    _filteredGameParticipations = List<GameParticipation>.from(
        _gameParticipations.where(
            (element) => factionId.compareTo(element.faction ?? '') == 0));
    _filteredNotReplyingPlayers = [];

    notifyListeners();
  }

  void resetFilteredParticipations() {
    resetFilterHelpers();
    selectedKpi = -1;
    _filteredNotReplyingPlayers = List<Player>.from(notReplyingPlayers);
    _filteredGameParticipations =
        List<GameParticipation>.from(gameParticipations);

    notifyListeners();
  }

  void filterAgainParticipations() {
    if (filteringOnStatus) {
      filterParticipationsByStatus(filterStatus, selectedKpi);
    } else if (filteringOnFaction) {
      filterParticipationsByFaction(filterFaction, selectedKpi);
    } else
      resetFilteredParticipations();
  }

  Future<void> fetchAndSetGameParticipations() async {
    print(
        '[GameProvider/fetchAndSetGameParticipations] starting for teamId : ${game.id}');

    _gameParticipations = await FirebaseHelper.fetchGameParticipations(game.id);

    //fixing participations with factions that have been lately deleted
    for (int i = 0; i < _gameParticipations.length; i++) {
      var found = false;
      final p = _gameParticipations[i];
      game.factions.forEach((f) {
        if (f.id == p.faction) found = true;
      });
      if (!found) {
        _gameParticipations.removeAt(i);
        _gameParticipations.insert(
            i,
            GameParticipation(
                id: p.id,
                gameId: p.gameId,
                gameName: p.gameName,
                playerId: p.playerId,
                playerName: p.playerName,
                gameTeamId: p.gameTeamId,
                gameTeamName: p.gameTeamName,
                playerTeamId: p.playerTeamId,
                playerTeamName: p.playerTeamName,
                isGuest: p.isGuest,
                isGoing: p.isGoing));
      }
    }

    sortParticipations();

    resetFilteredParticipations();
    notifyListeners();
  }

  Future<void> fetchAndSetNotReplyingPlayers() async {
    final invitations = await FirebaseHelper.fetchGameInvitations(game.id);
    final invitedTeams = List.from(invitations.map((e) => e.teamId));
    invitedTeams.add(game.hostTeamId);

    _notReplyingPlayers = [];
    for (var i in invitedTeams) {
      _notReplyingPlayers.addAll(await FirebaseHelper.fetchTeamMembers(i));
    }

    for (GameParticipation p in _gameParticipations) {
      _notReplyingPlayers
          .removeWhere((player) => player.id.compareTo(p.playerId) == 0);
    }
    resetFilteredParticipations();
  }

  Future<void> fetchAndSetGameParticipationsAndInvitedPlayers() async {
    await fetchAndSetGameParticipations();
    await fetchAndSetNotReplyingPlayers();
  }

  void editParticipation(GameParticipation participation) {
    print(
        '[GameProvider/editParticipation] starting for participation ${participation.asMap}');
    if (participation.id != null) {
      var index = _gameParticipations
          .indexWhere((element) => element.id == participation.id);

      //_gameParticipations must stay sorted to allow the user to easily decide factions
      _gameParticipations.removeAt(index);
      _gameParticipations.insert(index, participation);

      filterAgainParticipations();

      notifyListeners();

      FirebaseHelper.editParticipation(participation);
    }
  }

  Future<GameParticipation> addParticipation(
      GameParticipation participation) async {
    {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final tempParticipation =
          GameParticipation.fromMap(tempId, participation.asMap);
      _gameParticipations.add(tempParticipation);
      notifyListeners();

      filterAgainParticipations();

      print(
          '[GameProvider/addParticipation] added tempParticipation ${tempParticipation.asMap}');

      final uploadedParticipation =
          await FirebaseHelper.addNewParticipation(participation);

      var index = _gameParticipations.indexWhere((gp) => gp.id == tempId);
      _gameParticipations.removeAt(index);
      _gameParticipations.insert(index, uploadedParticipation);

      filterAgainParticipations();

      print(
          '[GameProvider/editParticipation] added participation ${uploadedParticipation.asMap}');

      // resetFilteredParticipations();
      notifyListeners();

      return uploadedParticipation;
    }
  }

  Future<void> deleteParticipation(GameParticipation participation) async {
    _gameParticipations
        .removeWhere((element) => element.id == participation.id);
    notifyListeners();

    await FirebaseHelper.deleteParticipation(participation);
  }
}

Future<String> getLocalPath() async {
  final directory = await getApplicationSupportDirectory();
  return directory.absolute.path;
}
