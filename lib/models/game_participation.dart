import 'package:flutter/foundation.dart';

enum participationStatus { going, not_going, not_replied }

class GameParticipation {
  final String id;
  final String gameId;
  final String gameName;
  final String playerId;
  final String playerName;
  final bool isGoing;
  final String faction;
  final bool isGuest;
  final String playerTeamId;
  final String playerTeamName;
  final String gameTeamId;
  final String gameTeamName;

  GameParticipation({
    @required this.id,
    @required this.gameId,
    @required this.gameName,
    @required this.playerId,
    @required this.playerName,
    @required this.isGoing,
    @required this.playerTeamId,
    @required this.playerTeamName,
    @required this.gameTeamId,
    @required this.gameTeamName,
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
        this.playerTeamId = map['playerTeamId'],
        this.playerTeamName = map['playerTeamName'],
        this.gameTeamId = map['gameTeamId'],
        this.gameTeamName = map['gameTeamName'],
        this.isGuest = map['isGuest'] ?? false;

  Map<String, dynamic> get asMap => {
        'gameId': gameId,
        'gameName': gameName,
        'playerId': playerId,
        'playerName': playerName,
        'isGoing': isGoing,
        'faction': faction,
        'isGuest': isGuest,
        'playerTeamId': playerTeamId,
        'playerTeamName': playerTeamName,
        'gameTeamId': gameTeamId,
        'gameTeamName': gameTeamName
      };
}
