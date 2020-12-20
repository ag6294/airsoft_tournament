import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:airsoft_tournament/models/game.dart';
import './login_provider.dart';

class GamesProvider extends ChangeNotifier {
  List<Game> _games = [];

  GamesProvider() {
    print('[GameProvider] Constructor');
  }

  List<Game> get games => _games;

  Future<void> addNewGame(Game newGame) async {
    games.add(await FirebaseHelper.addGame(newGame));

    notifyListeners();
  }

  Future<List<Game>> fetchAndSetGames(String teamId) async {
    if (games.isEmpty) _games = await FirebaseHelper.fetchGames(teamId);

    return games;
  }
}
