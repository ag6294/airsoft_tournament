import 'package:flutter/foundation.dart';

class TeamPost {
  String id;
  String title;
  String description;
  DateTime creationDate;
  DateTime editDate;
  String authorId;
  String authorName;
  String teamId;
  String teamName;
  bool isPrivate;

  TeamPost(
      {this.id,
      this.title,
      this.isPrivate,
      this.description,
      this.authorId,
      this.authorName,
      this.creationDate,
      this.editDate,
      this.teamId,
      this.teamName});

  Map<String, dynamic> get asMap => {
        'id': id,
        'title': title,
        'description': description,
        'creationDate': creationDate.toIso8601String(),
        'editDate': editDate.toIso8601String(),
        'authorId': authorId,
        'authorName': authorName,
        'isPrivate': isPrivate,
        'teamId': teamId,
        'teamName': teamName,
      };

  TeamPost.fromMap(String id, Map<String, dynamic> map)
      : this.id = id,
        this.title = map['title'],
        this.description = map['description'],
        this.creationDate = DateTime.tryParse(map['creationDate']),
        this.editDate = DateTime.tryParse(map['editDate']),
        this.authorId = map['authorId'],
        this.authorName = map['authorName'],
        this.isPrivate = map['isPrivate'],
        this.teamId = map['teamId'],
        this.teamName = map['teamName'];
}
