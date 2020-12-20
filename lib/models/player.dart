import 'package:flutter/foundation.dart';

class Player {
  final String id;
  final String email;
  final String nickname;
  final String teamId;
  final bool isGM;

  Player({
    @required this.id,
    @required this.email,
    @required this.nickname,
    @required this.isGM,
    this.teamId,
  });

  Player.fromMap(String id, Map<String, dynamic> map)
      : this.id = id,
        this.email = map['email'],
        this.nickname = map['nickname'],
        this.teamId = map['teamId'],
        this.isGM = map['isGM'] ?? false;

  Map<String, dynamic> get asMap => {
        'id': id,
        'email': email,
        'nickname': nickname,
        'teamId': teamId,
        'isGM': isGM,
      };
}
