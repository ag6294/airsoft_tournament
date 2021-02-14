import 'package:flutter/foundation.dart';

class GameParticipation {
  final String id;
  final String gameId;
  final String gameName;
  final String playerId;
  final String playerName;
  final bool isGoing;
  final String faction;
  final bool isGuest;

  GameParticipation({
    @required this.id,
    @required this.gameId,
    @required this.gameName,
    @required this.playerId,
    @required this.playerName,
    @required this.isGoing,
    this.faction,
    this.isGuest = false,
  });

  GameParticipation.fromMap(String id, Map<String, dynamic> map)
      : this.id = id,
        this.gameId = map['gameId'],
        this.gameName = map['gameName'],
        this.playerId = map['playerId'],
        this.playerName = map['playerName'],
        this.isGoing = map['isGoing'],
        this.faction = map['faction'],
        this.isGuest = map['isGuest'] ?? false;

  Map<String, dynamic> get asMap => {
        'id': id,
        'gameId': gameId,
        'gameName': gameName,
        'playerId': playerId,
        'playerName': playerName,
        'isGoing': isGoing,
        'faction': faction,
        'isGuest': isGuest,
      };
}
