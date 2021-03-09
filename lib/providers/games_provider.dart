import 'dart:io';

import 'package:airsoft_tournament/helpers/NotificationsHelper.dart';
import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_participation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class GamesProvider extends ChangeNotifier {
  List<Game> _games = [];
  List<Game> _filteredGames = [];
  List<GameParticipation> _loggedUserParticipations = [];
  List<GameParticipation> _gameParticipations = [];
  List<GameParticipation> _filteredGameParticipations = [];
  List<Player> _notReplyingPlayers = [];
  List<Player> _filteredNotReplyingPlayers = [];
  int selectedKpi = -1;

  GamesProvider() {
    print('[GameProvider] Constructor');
  }

  void initialize(String playerId) {
    fetchAndSetLoggedUserParticipations(playerId);
  }

  void logOut() {
    _games = [];
    _loggedUserParticipations = [];
    _gameParticipations = [];
  }

  List<Game> get games => _games;
  List<Game> get filteredGames => _filteredGames;

  void filterGamesByTitleOrTeam(String query) {
    if (query != null) {
      _filteredGames = [
        ..._games.where((element) =>
            element.title.toLowerCase().contains(query) ||
            element.hostTeamName.toLowerCase().contains(query))
      ];
    } else {
      _filteredGames = List<Game>.from(_games);
    }
    notifyListeners();
  }

  List<GameParticipation> get loggedUserParticipations =>
      _loggedUserParticipations;
  List<GameParticipation> get gameParticipations => _gameParticipations;
  List<GameParticipation> get filteredGameParticipations =>
      _filteredGameParticipations;
  List<Player> get notReplyingPlayers => _notReplyingPlayers
    ..sort((Player a, Player b) =>
        a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase()));
  List<Player> get filteredNotReplyingPlayers => _filteredNotReplyingPlayers
    ..sort((Player a, Player b) =>
        a.nickname.toLowerCase().compareTo(b.nickname.toLowerCase()));

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

  void filterParticipationsByStatus(participationStatus status, int kpiIndex) {
    selectedKpi = kpiIndex;

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

    _filteredGameParticipations = List<GameParticipation>.from(
        _gameParticipations.where(
            (element) => factionId.compareTo(element.faction ?? '') == 0));
    _filteredNotReplyingPlayers = [];

    notifyListeners();
  }

  void resetFilteredParticipations() {
    selectedKpi = -1;
    _filteredNotReplyingPlayers = List<Player>.from(notReplyingPlayers);
    _filteredGameParticipations =
        List<GameParticipation>.from(gameParticipations);

    notifyListeners();
  }

  Future<Game> addNewGame(Game newGame) async {
    print('[GameProvider/addNewGame] title: ${newGame.title}');

    Game uploadedGame;

    try {
      uploadedGame = await FirebaseHelper.addGame(newGame);
    } catch (e) {
      rethrow;
    }
    _games.add(uploadedGame);

    //Sort by date descending
    _games.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();

    FirebaseNotificationHelper.sendNewGameNotification(uploadedGame);
    return uploadedGame;
  }

  Future<void> fetchAndSetGames(String teamId, bool forceRefresh) async {
    print('[GameProvider/fetchAndSetGames] starting');
    if (_games.isEmpty || forceRefresh) {
      //TODO fare controllo non con teamId ma con loggedUser team id se mettiamo la lsita delle giocate nella pagina del team
      _games = await FirebaseHelper.fetchFutureGames();

      print(games);

      _games.removeWhere(
          (element) => element.hostTeamId != teamId && element.isPrivate);

      print(games);

      _games.sort((a, b) => b.date.compareTo(a.date));
      filterGamesByTitleOrTeam(null);
      print('[GameProvider/fetchAndSetGames] ending');

      notifyListeners();
    } else {
      // FirebaseHelper.fetchGames(teamId)
      //     .then((value) => _games = value)
      //     .then((_) => _games.sort((a, b) => b.date.compareTo(a.date)))
      //     .then((_) => notifyListeners());

      print('[GameProvider/fetchAndSetGames] ending with no download');
    }
    //Sort by date descending
  }

  Future<void> fetchAndSetLoggedUserParticipations(String playerId) async {
    print(
        '[GameProvider/fetchAndSetUserParticipations] starting for userId : $playerId');

    _loggedUserParticipations =
        await FirebaseHelper.fetchUserParticipations(playerId);

    notifyListeners();
  }

  Future<void> fetchAndSetGameParticipations(
      Game game, List<Player> invitedPlayers) async {
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
                isGoing: p.isGoing));
      }
    }

    sortParticipations();

    //Evaluating invited players that have not replied yet
    _notReplyingPlayers = List<Player>.from(invitedPlayers);
    for (GameParticipation p in _gameParticipations) {
      _notReplyingPlayers
          .removeWhere((player) => player.id.compareTo(p.playerId) == 0);
    }

    resetFilteredParticipations();
    notifyListeners();
  }

  void editParticipation(
      GameParticipation participation, bool isLoggedUserParticipation) {
    print(
        '[GameProvider/editParticipation] starting for participation ${participation.asMap}');
    if (participation.id != null) {
      var index = _gameParticipations
          .indexWhere((element) => element.id == participation.id);

      if (isLoggedUserParticipation) {
        _loggedUserParticipations
            .removeWhere((element) => element.id == participation.id);
        _loggedUserParticipations.add(participation);
      }

      //_gameParticipations must stay sorted to allow the user to easily decide factions
      _gameParticipations.removeAt(index);
      _gameParticipations.insert(index, participation);

      index = _filteredGameParticipations
          .indexWhere((element) => element.id == participation.id);
      _filteredGameParticipations.removeAt(index);
      _filteredGameParticipations.insert(index, participation);

      // resetFilteredParticipations();
      notifyListeners();

      FirebaseHelper.editParticipation(participation);
    } else {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final tempParticipation =
          GameParticipation.fromMap(tempId, participation.asMap);
      _gameParticipations.add(tempParticipation);
      _filteredGameParticipations.add(tempParticipation);

      if (isLoggedUserParticipation)
        _loggedUserParticipations.add(tempParticipation);

      // resetFilteredParticipations();
      notifyListeners();

      print(
          '[GameProvider/editParticipation] added tempParticipation ${tempParticipation.asMap}');

      FirebaseHelper.addNewParticipation(participation).then((value) {
        var index = _gameParticipations.indexWhere((gp) => gp.id == tempId);
        _gameParticipations.removeAt(index);
        _gameParticipations.insert(index, value);

        index = _filteredGameParticipations.indexWhere((gp) => gp.id == tempId);
        _filteredGameParticipations.removeAt(index);
        _filteredGameParticipations.insert(index, value);

        print(
            '[GameProvider/editParticipation] added participation ${value.asMap}');

        if (isLoggedUserParticipation) {
          _loggedUserParticipations.removeWhere((gp) => gp.id == tempId);
          _loggedUserParticipations.add(value);
        }

        // resetFilteredParticipations();
        notifyListeners();
      });
    }
  }

  Future<void> deleteGame(Game game) async {
    print('[GameProvider/addNewGame] title: ${game.title}');
    await FirebaseHelper.deleteGame(game);

    _games.removeWhere((element) => element.id == game.id);
    notifyListeners();
  }

  Future<Game> editGame(Game game, String oldImageUrl) async {
    print('[GameProvider/addNewGame] title: ${game.title}');

    var newGame = await FirebaseHelper.editGame(game, oldImageUrl);
    _games.removeWhere((element) => element.id == newGame.id);
    _games.add(newGame);

    //Sort by date descending
    _games.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    return newGame;
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
      'email',
      'nickname',
      'name',
      'lastName',
      'placeOfBirth',
      'dateOfBirth',
    ]);

    final csv = ListToCsvConverter().convert(rows);
    file.writeAsString(csv);

    final Email email = Email(
      body: 'In allegato la lista dei presenti per la giocata ${game.title}',
      subject: '${game.title} - presenze ${DateTime.now().toString()}',
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
}

Future<String> getLocalPath() async {
  final directory = await getApplicationSupportDirectory();
  return directory.absolute.path;
}
