import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

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
        this.email = map['email'].toLowerCase(),
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
        email?.capitalize,
        nickname.capitalize,
        name?.capitalizeEachWord,
        lastName?.capitalizeEachWord,
        placeOfBirth?.capitalizeEachWord,
        dateOfBirth == null ? '' : DateFormat('dd/MM/yyyy').format(dateOfBirth),
      ];
}

extension CapExtension on String {
  String get capitalize => this != null && this != ''
      ? '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}'
      : this;
  String get capitalizeEachWord {
    return this.contains(' ')
        ? this.split(' ').map((e) => e.capitalize).toList().join(' ')
        : this.capitalize;
  }
}
