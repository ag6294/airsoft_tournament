import 'package:quiver/core.dart';

class Game {
  final String id;
  final String title;
  final String description;
  final String place;
  final DateTime date;
  final String lastModifiedBy;
  final DateTime lastModifiedOn;

  Game(
      {this.id,
      this.title,
      this.description,
      this.place,
      this.date,
      this.lastModifiedBy,
      this.lastModifiedOn});

  Game.fromMap(String id, Map map)
      : this.id = map['id'],
        this.title = map['title'],
        this.description = map['description'],
        this.place = map['place'],
        this.date = map['date'],
        this.lastModifiedBy = map['lastModifiedBy'],
        this.lastModifiedOn = map['lastModifiedOn'];

  Map<String, dynamic> get asMap {
    return {
      'id': id,
      'title': title,
      'description': description,
      'place': place,
      'date': date,
      'lastModifiedBy': lastModifiedBy,
      'lastModifiedOn': lastModifiedOn,
    };
  }
}
