import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:airsoft_tournament/models/game_invitation.dart';
import 'package:flutter/foundation.dart';

class Game extends ChangeNotifier {
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
  final String attachmentUrl;
  final List<Faction> factions;
  final bool isPrivate;

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
      @required this.hostTeamName,
      @required this.attachmentUrl,
      @required this.factions,
      @required this.isPrivate});

  Game.fromMap(String id, Map map)
      : this.id = id,
        this.title = map['title'],
        this.description = map['description'],
        this.place = map['place'],
        this.date = DateTime.tryParse(map['date']),
        this.lastModifiedBy = map['lastModifiedBy'],
        this.lastModifiedOn = DateTime.tryParse(map['lastModifiedOn']),
        this.imageUrl = map['imageUrl'],
        this.hostTeamId = map['hostTeamId'],
        this.hostTeamName = map['hostTeamName'],
        this.attachmentUrl = map['attachmentUrl'],
        this.factions = map['factions'] != null
            ? List<Faction>.from(
                map['factions']?.map((e) => Faction.fromMap(e)))
            : [],
        this.isPrivate = map['isPrivate'] ?? false;

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
      'attachmentUrl': attachmentUrl,
      'factions': factions.map((e) => e.asMap).toList(),
      'isPrivate': isPrivate,
    };
  }
}

class Faction {
  final String id;
  final String name;

  Faction({
    @required this.id,
    @required this.name,
  });

  Faction.fromMap(Map<String, dynamic> map)
      : this.id = map['id'],
        name = map['name'];

  Map<String, dynamic> get asMap => {
        'id': id,
        'name': name,
      };
}
