import 'dart:async';

import 'package:airsoft_tournament/helpers/firebase_helper.dart';
import 'package:airsoft_tournament/models/notification.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:flutter/cupertino.dart';

const refreshTimer = Duration(minutes: 5);

class NotificationsProvider extends ChangeNotifier {
  Player _loggedPlayer;
  List<CustomNotification> _notifications = [];
  Timer timer;

  NotificationsProvider();

  void setLoggedPlayer(Player player) {
    _loggedPlayer = player;
  }

  int get unreadNotificationsCount =>
      _notifications.where((element) => !element.read).length;

  List<CustomNotification> get notifications => List<CustomNotification>.from(
      _notifications.where((element) => !element.read));

  void logOut() {
    _loggedPlayer = null;
    _notifications = [];
    if (timer != null) timer.cancel();
  }

  Future<void> fetchAndSetPlayerNotifications() async {
    _notifications =
        await FirebaseHelper.fetchPlayerNotifications(_loggedPlayer.id);
    notifyListeners();

    if (timer != null) timer.cancel();
    timer = Timer.periodic(
        refreshTimer, (timer) => fetchAndSetPlayerNotifications());
  }

  Future<void> readNotification(CustomNotification notification) async {
    final CustomNotification newNotification = CustomNotification(
      title: notification.title,
      gameId: notification.gameId,
      id: notification.id,
      description: notification.description,
      playerId: notification.playerId,
      read: true,
      type: notification.type,
      expirationDate: notification.expirationDate,
      creationDate: notification.creationDate,
    );

    _notifications.removeWhere((element) => element.id == notification.id);
    notifyListeners();

    FirebaseHelper.editNotification(newNotification);
  }
}
