import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/routes/home_route.dart';
import 'package:airsoft_tournament/routes/login_route.dart';
import 'package:airsoft_tournament/routes/team_login_route.dart';
import 'package:airsoft_tournament/routes/games_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        )
      ],
      child: Consumer<LoginProvider>(
        builder: (context, authProvider, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData.dark(),
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
          },
        ),
      ),
    );
  }
}
