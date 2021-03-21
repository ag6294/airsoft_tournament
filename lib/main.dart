import 'package:airsoft_tournament/helpers/notification_helper.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/providers/notifications_provider.dart';
import 'package:airsoft_tournament/providers/team_provider.dart';
import 'package:airsoft_tournament/routes/game_detail_route.dart';
import 'package:airsoft_tournament/routes/game_participations_route.dart';
import 'package:airsoft_tournament/routes/home_route.dart';
import 'package:airsoft_tournament/routes/login_route.dart';
import 'package:airsoft_tournament/routes/notifications_route.dart';
import 'package:airsoft_tournament/routes/player_edit_route.dart';
import 'package:airsoft_tournament/routes/privacy_route.dart';
import 'package:airsoft_tournament/routes/team_detail_route.dart';
import 'package:airsoft_tournament/routes/team_edit_route.dart';
import 'package:airsoft_tournament/routes/team_login_route.dart';
import 'package:airsoft_tournament/routes/games_route.dart';
import 'package:airsoft_tournament/routes/edit_game_route.dart';
import 'package:airsoft_tournament/routes/team_members_route.dart';
import 'package:airsoft_tournament/routes/team_posts_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseNotificationHelper.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // @override
  // void initState() {
  //   super.initState();
  //   // FirebaseMessaging.instance
  //   //     .getInitialMessage()
  //   //     .then((RemoteMessage message) {
  //   //   if (message != null) {
  //   //     Navigator.pushNamed(context, '/message',
  //   //         arguments: MessageArguments(message, true));
  //     }
  //   });

  @override
  Widget build(BuildContext context) {
    print('[MyApp] Build');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginProvider>(
          create: (context) => LoginProvider(),
        ),
        ChangeNotifierProvider<GamesProvider>(
          create: (context) => GamesProvider(),
        ),
        ChangeNotifierProvider<TeamsProvider>(
          create: (context) => TeamsProvider(),
        ),
        ChangeNotifierProxyProvider<LoginProvider, NotificationsProvider>(
          update: (context, loginProvider, previousNotificationsProvider) =>
              previousNotificationsProvider
                ..setLoggedPlayer(loginProvider.loggedPlayer),
          create: (context) => NotificationsProvider(),
        ),
      ],
      child: Consumer<LoginProvider>(
        builder: (context, authProvider, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Airsoft Gamemakers',
          theme: ThemeData.dark().copyWith(
            appBarTheme: AppBarTheme().copyWith(
              color: ThemeData.dark().scaffoldBackgroundColor,
              elevation: 0,
            ),
          ),
          home: authProvider.isLogged
              ? authProvider.hasTeam
                  ? HomeRoute()
                  : TeamLoginRoute()
              : LoginRoute(),
          routes: {
            LoginRoute.routeName: (context) => LoginRoute(),
            HomeRoute.routeName: (context) => HomeRoute(),
            TeamLoginRoute.routeName: (context) => TeamLoginRoute(),
            GamesRoute.routeName: (context) => GamesRoute(),
            EditGameRoute.routeName: (context) => EditGameRoute(),
            GameDetailRoute.routeName: (context) => GameDetailRoute(),
            GameParticipationsRoute.routeName: (context) =>
                GameParticipationsRoute(),
            TeamDetailRoute.routeName: (context) => TeamDetailRoute(),
            TeamEditRoute.routeName: (context) => TeamEditRoute(),
            TeamMembersRoute.routeName: (context) => TeamMembersRoute(),
            TeamPostsRoute.routeName: (context) => TeamPostsRoute(),
            PrivacyRoute.routeName: (context) => PrivacyRoute(),
            PlayerEditRoute.routeName: (context) => PlayerEditRoute(),
            NotificationsRoute.routeName: (context) => NotificationsRoute(),
          },
        ),
      ),
    );
  }
}
