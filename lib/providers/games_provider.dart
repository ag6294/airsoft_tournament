import 'package:flutter/foundation.dart';
import 'package:airsoft_tournament/models/game.dart';

class GamesProvider extends ChangeNotifier {
  List<Game> _games = [
    Game(
      id: '123',
      date: DateTime.now(),
      title: 'Titolo',
      description: 'Descrizione breve',
      lastModifiedBy: 'Ale',
      lastModifiedOn: DateTime.now(),
      place: 'Chivasso as always',
    )
  ];

  List<Game> get games => _games;
}
