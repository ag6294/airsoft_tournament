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

  Future<void> addNewGame(Game newGame) async {
    print('[GameProvider/addNewGame] title: ${newGame.title}');
    games.add(await FirebaseHelper.addGame(newGame));

    //Sort by date descending
    _games.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> fetchAndSetGames(String teamId) async {
    print('[GameProvider/fetchAndSetGames] starting');
    _games = await FirebaseHelper.fetchGames(teamId);

    //Sort by date descending
    _games.sort((a, b) => b.date.compareTo(a.date));
    print('[GameProvider/fetchAndSetGames] ending');

    notifyListeners();
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

    notifyListeners();
  }

  Future<void> editParticipation(GameParticipation participation) async {
    // TODO Controllare come mai non funziona bene lo switch della partecipazione e se cancelliamo le entry su firebase
    print(
        '[GameProvider/editParticipation] starting for userId : ${participation.id} and gameId : ${participation.gameId}');
    if (participation.id != null) {
      _loggedUserParticipations
          .removeWhere((element) => element.id == participation.id);
      _gameParticipations
          .removeWhere((element) => element.id == participation.id);

      final newParticipation =
          await FirebaseHelper.editParticipation(participation);
      _loggedUserParticipations.add(newParticipation);
      _gameParticipations.add(newParticipation);
    } else {
      final newParticipation =
          await FirebaseHelper.addNewParticipation(participation);
      _loggedUserParticipations.add(newParticipation);
      _gameParticipations.add(newParticipation);
    }

    notifyListeners();
  }
}
