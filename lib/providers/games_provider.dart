import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:airsoft_tournament/models/game_participation.dart';
import './login_provider.dart';

class GamesProvider extends ChangeNotifier {
  List<Game> _games = [];
  List<GameParticipation> _loggedUserParticipations = [];
  List<GameParticipation> _gameParticipations = [];

  GamesProvider() {
    print('[GameProvider] Constructor');
  }

  List<Game> get games => _games;
  List<GameParticipation> get loggedUserParticipations =>
      _loggedUserParticipations;
  List<GameParticipation> get gameParticipations => _gameParticipations;

  void sortParticipations() {
    _gameParticipations
      ..sort((a, b) {
        if (a.isGoing && !b.isGoing) return -1;
        if (!a.isGoing && b.isGoing) return 1;
        if (a.faction == null) return -1;
        if (b.faction == null) return 1;
        return a.faction.compareTo(b.faction);
      });

    notifyListeners();
  }

  Future<Game> addNewGame(Game newGame) async {
    print('[GameProvider/addNewGame] title: ${newGame.title}');

    final uploadedGame = await FirebaseHelper.addGame(newGame);
    _games.add(uploadedGame);

    //Sort by date descending
    _games.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
    return uploadedGame;
  }

  Future<void> fetchAndSetGames(String teamId, bool forceRefresh) async {
    print('[GameProvider/fetchAndSetGames] starting');
    if (_games.isEmpty || forceRefresh) {
      _games = await FirebaseHelper.fetchGames(teamId);
      _games.sort((a, b) => b.date.compareTo(a.date));
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

  Future<void> fetchAndSetGameParticipations(String gameId) async {
    print(
        '[GameProvider/fetchAndSetGameParticipations] starting for teamId : $gameId');

    _gameParticipations = await FirebaseHelper.fetchGameParticipations(gameId);
    sortParticipations();

    notifyListeners();
  }

  Future<void> editParticipation(
      GameParticipation participation, bool isLoggedUserParticipation) async {
    print(
        '[GameProvider/editParticipation] starting for userId : ${participation.id} and gameId : ${participation.gameId}');
    if (participation.id != null) {
      final index = _gameParticipations
          .indexWhere((element) => element.id == participation.id);

      _loggedUserParticipations
          .removeWhere((element) => element.id == participation.id);
      //_gameParticipations must stay sorted to allow the user to easily decide factions
      _gameParticipations.removeAt(index);

      final newParticipation =
          await FirebaseHelper.editParticipation(participation);
      _loggedUserParticipations.add(newParticipation);
      _gameParticipations.insert(index, newParticipation);
    } else {
      final newParticipation =
          await FirebaseHelper.addNewParticipation(participation);
      if (isLoggedUserParticipation)
        _loggedUserParticipations.add(newParticipation);
      _gameParticipations.add(newParticipation);
    }

    notifyListeners();
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
}
