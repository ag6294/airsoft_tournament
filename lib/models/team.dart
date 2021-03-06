import 'package:airsoft_tournament/models/player.dart';
import 'package:flutter/foundation.dart';

class Team {
  final String id;
  final String name;
  final String password;
  final List<Player> players;
  final String imageUrl;
  final String contacts;
  final String description;

  Team({
    @required this.id,
    @required this.name,
    @required this.players,
    @required this.password,
    this.imageUrl,
    this.contacts,
    this.description,
  });

  Team.fromMap(String id, Map<String, dynamic> map, List<Player> members)
      : this.id = id,
        this.name = map['name'],
        this.password = map['password'],
        this.players = members ?? [],
        this.imageUrl = map['imageUrl'],
        this.contacts = map['contacts'],
        this.description = map['description'];
//todo remove players to map, and delete it from db
  Map<String, dynamic> get asMap => {
        'name': name,
        'players':
            Map.fromIterable(players, key: (p) => p.id, value: (p) => p.asMap),
        'imageUrl': imageUrl,
        'contacts': contacts,
        'description': description,
      };
}
