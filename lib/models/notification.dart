import 'package:airsoft_tournament/routes/game_detail_route.dart';
import 'package:airsoft_tournament/routes/team_posts_route.dart';
import 'package:flutter/material.dart';

enum notificationType { new_game, invitation, new_post }

extension notificationTypeExtension on notificationType {
  Function onTap(CustomNotification notification) {
    switch (this) {
      case notificationType.new_game:
        return (BuildContext context) => Navigator.of(context).pushNamed(
            GameDetailRoute.routeName,
            arguments: notification.gameId);
      case notificationType.invitation:
        return (BuildContext context) => Navigator.of(context).pushNamed(
            GameDetailRoute.routeName,
            arguments: notification.gameId);
      case notificationType.new_post:
        return (BuildContext context) => Navigator.of(context).pushNamed(
            TeamPostsRoute.routeName,
            arguments: {'postId': notification.postId});
      default:
        return () {};
    }
  }
}

class CustomNotification {
  final String id;
  final String playerId;
  final String title;
  final String description;
  final notificationType type;
  final bool read;
  final String gameId;
  final String postId;
  final DateTime creationDate;
  final DateTime expirationDate;

  CustomNotification(
      {this.id,
      this.playerId,
      this.title,
      this.description,
      this.type,
      this.read,
      this.gameId,
      this.postId,
      this.creationDate,
      this.expirationDate});

  CustomNotification.fromMap(String id, Map<String, dynamic> map)
      : this.id = id,
        this.playerId = map['playerId'],
        this.title = map['title'],
        this.description = map['description'],
        this.type = notificationType.values[map['type']],
        this.read = map['read'],
        this.gameId = map['gameId'],
        this.postId = map['postId'],
        this.creationDate = DateTime.tryParse(map['creationDate']),
        this.expirationDate = DateTime.tryParse(map['expirationDate']);

  Map<String, dynamic> get asMap => {
        'title': title,
        'description': description,
        'type': type.index,
        'read': read,
        'playerId': playerId,
        'gameId': gameId,
        'postId': postId,
        'expirationDate': expirationDate.toIso8601String(),
        'creationDate': creationDate.toIso8601String(),
      };
}
