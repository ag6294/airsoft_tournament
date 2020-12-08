import 'package:quiver/core.dart';

class Game {
  final String id;
  final String title;
  final String description;
  final String place;
  final DateTime date;
  final String lastModifiedBy;
  final DateTime lastModifiedOn;
  final String imageUrl;

  Game(
      {this.id,
      this.title,
      this.description,
      this.place,
      this.date,
      this.lastModifiedBy,
      this.lastModifiedOn,
      this.imageUrl});

  Game.fromMap(String id, Map map)
      : this.id = map['id'],
        this.title = map['title'],
        this.description = map['description'],
        this.place = map['place'],
        this.date = map['date'],
        this.lastModifiedBy = map['lastModifiedBy'],
        this.lastModifiedOn = map['lastModifiedOn'],
        this.imageUrl = map['imageUrl'];

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
    };
  }
}
