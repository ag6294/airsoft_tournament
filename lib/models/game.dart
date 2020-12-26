import 'package:flutter/foundation.dart';

class Game {
  final String id;
  final String title;
  final String description;
  final String place;
  final DateTime date;
  final String lastModifiedBy;
  final DateTime lastModifiedOn;
  final String imageUrl;
  final String hostTeamId;
  final String hostTeamName;

  Game(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.place,
      @required this.date,
      @required this.lastModifiedBy,
      @required this.lastModifiedOn,
      @required this.imageUrl,
      @required this.hostTeamId,
      @required this.hostTeamName});

  Game.fromMap(String id, Map map)
      : this.id = map['id'],
        this.title = map['title'],
        this.description = map['description'],
        this.place = map['place'],
        this.date = DateTime.tryParse(map['date']),
        this.lastModifiedBy = map['lastModifiedBy'],
        this.lastModifiedOn = DateTime.tryParse(map['lastModifiedOn']),
        this.imageUrl = map['imageUrl'],
        this.hostTeamId = map['hostTeamId'],
        this.hostTeamName = map['hostTeamName'];

  Map<String, dynamic> get asMap {
    return {
      'id': id,
      'title': title,
      'description': description,
      'place': place,
      'date': date.toIso8601String(),
      'lastModifiedBy': lastModifiedBy,
      'lastModifiedOn': lastModifiedOn.toIso8601String(),
      'imageUrl': imageUrl,
      'hostTeamId': hostTeamId,
      'hostTeamName': hostTeamName,
    };
  }
}
