// In order to receive these kind if intents it is important
// to add the value “FLUTTER_NOTIFICATION_CLICK”
// with the key “click_action”
// to the “custom data” section when sending messages from the Firebase console.

import 'package:airsoft_tournament/models/game.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

const kVapidKey =
    'BIS0R3MN4qYc0-C3pUeEm6Jk1HYHiv0lofM6NuFkUHMXvX2dK05pNyBcj1BmjnwApFCOvctWGz5ZQ6l_a0fOWaU';

FirebaseMessaging _messaging = FirebaseMessaging.instance;

class FirebaseNotificationHelper {
  static void init() async {
    NotificationSettings settings = await _messaging.getNotificationSettings();

    String token = await _messaging.getToken(
      vapidKey: kVapidKey,
    );

    if (!(settings.authorizationStatus == AuthorizationStatus.authorized)) {
      _messaging.requestPermission();
    }

    print("[FirebaseNotificationHelper/init] FirebaseMessaging token: $token");
  }

  static void subscribeChannel(String channel) {
    // if (Platform.isAndroid || Platform.isIOS)
    //   _messaging.subscribeToTopic(channel);
  }

  static void logout(String channel) {
    _messaging.unsubscribeFromTopic(channel);
  }

  static void sendNewGameNotification(Game game) {
    final message = {
      'notification': {
        'title': 'Nuova giocata di ${game.hostTeamName}',
        'body':
            'Nuova giocata il ${game.date.toString()} che si chiama ${game.title}'
      },
      'topic': game.hostTeamId,
    };
    _messaging.sendMessage();
  }
}

// class PushNotificationsManager {
//   PushNotificationsManager._();
//
//   factory PushNotificationsManager() => _instance;
//
//   static final PushNotificationsManager _instance =
//       PushNotificationsManager._();
//
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   bool _initialized = false;
//
//   Future<void> init() async {
//     if (!_initialized) {
//       // For iOS request permission first.
//       _firebaseMessaging.requestNotificationPermissions();
//       _firebaseMessaging.configure();
//
//       // For testing purposes print the Firebase Messaging token
//       String token = await _firebaseMessaging.getToken();
//       print("FirebaseMessaging token: $token");
//
//       _initialized = true;
//     }
//   }
// }
