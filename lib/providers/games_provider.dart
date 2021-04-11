import 'dart:io';

import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:airsoft_tournament/models/notification.dart';
import 'package:airsoft_tournament/models/player.dart';

import 'package:flutter/foundation.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_participation.dart';

class GamesProvider extends ChangeNotifier {
  List<Game> _games = [];
  List<Game> _filteredGames = [];
  List<GameParticipation> _loggedUserParticipations = [];

  GamesProvider() {
    print('[GameProvider] Constructor');
  }

  void initialize(String playerId) {
    fetchAndSetLoggedUserParticipations(playerId);
  }

  void logOut() {
    _games = [];
    _loggedUserParticipations = [];
  }

  List<Game> get games => _games;
  List<Game> get filteredGames => _filteredGames;

  Future<Game> getGameById(String id) async {
    Game game;
    if (_games.isNotEmpty) {
      game = _games.firstWhere((element) => element.id == id, orElse: null);
    }
    if (game == null) {
      game = await FirebaseHelper.getGameById(id);
    }
    return game;
  }

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

  Future<Game> addNewGame(Game newGame,
      {File image, List<Player> players}) async {
    print('[GameProvider/addNewGame] title: ${newGame.title}');

    Game uploadedGame;

    try {
      uploadedGame = await FirebaseHelper.addGame(newGame, image);
    } catch (e) {
      rethrow;
    }
    _games.add(uploadedGame);

    //Sort by date descending
    _games.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();

    // FirebaseNotificationHelper.sendNewGameNotification(uploadedGame);
    sendNewGameNotifications(uploadedGame, players);
    return uploadedGame;
  }

  Future<void> sendNewGameNotifications(Game game, List<Player> players) async {
    players.forEach((element) {
      FirebaseHelper.addNotification(CustomNotification(
        title: 'Nuova giocata',
        description: 'Inserisci la presenza per la nuova giocata ${game.title}',
        playerId: element.id,
        gameId: game.id,
        read: false,
        type: notificationType.new_game,
        creationDate: DateTime.now(),
        expirationDate: game.date,
      ));
    });
  }

  Future<void> fetchAndSetGames(String teamId, bool forceRefresh) async {
    print('[GameProvider/fetchAndSetGames] starting');
    if (_games.isEmpty || forceRefresh) {
      //TODO fare controllo non con teamId ma con loggedUser team id se mettiamo la lsita delle giocate nella pagina del team
      _games = await FirebaseHelper.fetchFutureGamesForTeam(teamId);

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

  Future<void> deleteGame(Game game) async {
    print('[GameProvider/addNewGame] title: ${game.title}');
    _games.removeWhere((element) => element.id == game.id);
    _filteredGames.removeWhere((element) => element.id == game.id);
    _loggedUserParticipations
        .removeWhere((element) => element.gameId == game.id);
    notifyListeners();

    FirebaseHelper.deleteGame(game);
    // await FirebaseHelper.deleteParticipationsForGame(game);
  }

  Future<Game> editGame(Game game, String oldImageUrl,
      {File image, List<Player> players}) async {
    print('[GameProvider/addNewGame] title: ${game.title}');

    var newGame = await FirebaseHelper.editGame(game, oldImageUrl, image);
    _games.removeWhere((element) => element.id == newGame.id);
    _games.add(newGame);

    //Sort by date descending
    _games.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    return newGame;
  }

  void editLoggedUserParticipation(GameParticipation participation) {
    _loggedUserParticipations
        .removeWhere((element) => element.id == participation.id);
    _loggedUserParticipations.add(participation);

    notifyListeners();
  }

  void addLoggedUserParticipation(GameParticipation participation) {
    _loggedUserParticipations.add(participation);
    notifyListeners();
  }
}
