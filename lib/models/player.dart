import 'package:flutter/foundation.dart';

class Player {
  final String id;
  final String email;
  final String nickname;
  final String teamId;

  Player({
    @required this.id,
    @required this.email,
    @required this.nickname,
    this.teamId,
  });

  Player.fromMap(String id, Map<String, dynamic> map)
      : this.id = id,
        this.email = map['email'],
        this.nickname = map['nickname'],
        this.teamId = map['teamId'];

  Map<String, dynamic> get asMap => {
        'id': id,
        'email': email,
        'nickname': nickname,
        'teamId': teamId,
      };
}
