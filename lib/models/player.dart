import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Player {
  final String id;
  final String email;
  String nickname;
  final String teamId;
  final String teamName;
  final bool isGM;
  String name;
  String lastName;
  String placeOfBirth;
  DateTime dateOfBirth;

  Player(
      {@required this.id,
      @required this.email,
      @required this.nickname,
      @required this.isGM,
      this.teamId,
      this.teamName,
      this.name,
      this.lastName,
      this.dateOfBirth,
      this.placeOfBirth});

  Player.fromMap(String id, Map<String, dynamic> map)
      : this.id = id,
        this.email = map['email'],
        this.nickname = map['nickname'],
        this.teamId = map['teamId'] ?? '',
        this.teamName = map['teamName'] ?? '',
        this.isGM = map['isGM'] ?? false,
        this.name = map['name'] ?? '',
        this.lastName = map['lastName'] ?? '',
        this.placeOfBirth = map['placeOfBirth'] ?? '',
        this.dateOfBirth = map['dateOfBirth'] == null
            ? null
            : DateTime.tryParse(map['dateOfBirth']);

  Map<String, dynamic> get asMap => {
        'email': email,
        'nickname': nickname,
        'teamId': teamId,
        'teamName': teamName,
        'isGM': isGM,
        'name': name,
        'lastName': lastName,
        'placeOfBirth': placeOfBirth,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      };

  List<dynamic> get asRow => [
        email,
        nickname,
        name,
        lastName,
        teamName,
        placeOfBirth,
        dateOfBirth == null ? '' : DateFormat('dd/MM/yyyy').format(dateOfBirth),
      ];
}
