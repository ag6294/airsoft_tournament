import 'package:airsoft_tournament/models/player.dart';
import 'package:flutter/foundation.dart';

class Team {
  final String id;
  final String name;
  final String password;
  final List<Player> players;

  Team({
    @required this.id,
    @required this.name,
    @required this.players,
    @required this.password,
  });

  Team.fromMap(String id, Map<String, dynamic> map)
      : this.id = id,
        this.name = map['name'],
        this.password = map['password'],
        this.players = map['players'] != null
            ? List<Player>.from(map['players']
                .map((key, value) => MapEntry(key, Player.fromMap(key, value)))
                .values)
            : [];
}
