// In order to receive these kind if intents it is important
// to add the value “FLUTTER_NOTIFICATION_CLICK”
// with the key “click_action”
// to the “custom data” section when sending messages from the Firebase console.

import 'dart:convert';

import 'package:airsoft_tournament/models/game.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

const kVapidKey =
    'BIS0R3MN4qYc0-C3pUeEm6Jk1HYHiv0lofM6NuFkUHMXvX2dK05pNyBcj1BmjnwApFCOvctWGz5ZQ6l_a0fOWaU';
const serverKey =
    'AAAA-0fgixQ:APA91bE5sBShtkYbzxp7Vw-R6WmBkNqsOiWWzoxcgGWiQVCXJx1gJvmFkS8qMXiNftTJBM9sKJAgJ10KNXnUutZQfkCgY2DYsoCB0RE6ZARHWN6VL9k0UInOd6sN-XotZ7U6pVr1ZPEL';

FirebaseMessaging _messaging = FirebaseMessaging.instance;

class FirebaseNotificationHelper {
  FirebaseMessaging get instance => _messaging;

  static void init() async {
    NotificationSettings settings = await _messaging.getNotificationSettings();

    String token = await _messaging.getToken();

    if (!(settings.authorizationStatus == AuthorizationStatus.authorized)) {
      _messaging.requestPermission();
    }

    print("[FirebaseNotificationHelper/init] FirebaseMessaging token: $token");

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void subscribeChannel(String channel) {
    if (Platform.isAndroid || Platform.isIOS)
      _messaging.subscribeToTopic(channel);
  }

  static void logout(String channel) {
    _messaging.unsubscribeFromTopic(channel);
  }

  static Future<void> sendNewGameNotification(Game game) async {
    final _authToken = await FirebaseAuth.instance.currentUser.getIdToken();

    final message = {
      'notification': {
        'title': 'Nuova giocata di ${game.hostTeamName}',
        'body':
            'Nuova giocata il ${game.date.toString()} che si chiama ${game.title}'
      },
      'topic': game.hostTeamId,
      // 'token': _authToken,
    };

    final authority = 'fcm.googleapis.com';
    final path = '/v1/projects/airsoft-tournament/messages:send';
    // var params = {
    //   'auth': _authToken,
    // };
    var uri = Uri.https(authority, path);

    print(
        '[FirebaseNotificationHelper/sendNewGameNotification] POST to ${uri.toString()} body: $message');

    var response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': serverKey,
        },
        body: json.encode(message));

    print(
        '[FirebaseNotificationHelper/sendNewGameNotification] resolved to ${response.body.toString()}');
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
