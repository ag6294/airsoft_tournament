import 'package:flutter/foundation.dart';

class GameInvitation {
  final String id;
  final String teamId;
  final String teamName;
  final String gameId;
  final String gameName;

  GameInvitation({
    this.id,
    this.teamId,
    this.teamName,
    this.gameId,
    this.gameName,
  });

  GameInvitation.fromMap(String id, Map<String, dynamic> map)
      : this.id = id,
        this.teamId = map['teamId'],
        this.teamName = map['teamName'],
        this.gameId = map['gameId'],
        this.gameName = map['gameName'];

  Map<String, dynamic> get asMap => {
        'id': id,
        'gameId': gameId,
        'gameName': gameName,
        'teamId': teamId,
        'teamName': teamName,
      };
}
