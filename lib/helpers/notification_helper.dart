// In order to receive these kind if intents it is important
// to add the value “FLUTTER_NOTIFICATION_CLICK”
// with the key “click_action”
// to the “custom data” section when sending messages from the Firebase console.

import 'dart:convert';

import 'package:airsoft_tournament/models/game.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

const kVapidKey =
    'BIS0R3MN4qYc0-C3pUeEm6Jk1HYHiv0lofM6NuFkUHMXvX2dK05pNyBcj1BmjnwApFCOvctWGz5ZQ6l_a0fOWaU';
const serverKey = '';

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

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // _messaging.setForegroundNotificationPresentationOptions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Handling a background message ${message.messageId}');
  }

  static void subscribeChannel(String channel) {
    // if (Platform.isAndroid || Platform.isIOS)
    //   _messaging.subscribeToTopic(channel);
  }

  static void logout(String channel) {
    // _messaging.unsubscribeFromTopic(channel);
  }

  static Future<void> sendNewGameNotification(Game game) async {
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
