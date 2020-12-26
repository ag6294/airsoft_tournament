import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:airsoft_tournament/routes/games_route.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import '../models/game_participation.dart';

class HomeRoute extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  String playerId;
  String playerNickname;
  String teamName;
  List<GameParticipation> playerParticipations;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playerId = Provider.of<LoginProvider>(
      context,
      listen: false,
    ).loggedPlayer.id;
    playerNickname = Provider.of<LoginProvider>(
      context,
      listen: false,
    ).loggedPlayer.nickname;
    teamName = Provider.of<LoginProvider>(
      context,
      listen: false,
    ).loggedPlayerTeam.name;
    Provider.of<GamesProvider>(context, listen: false)
        .fetchAndSetLoggedUserParticipations(playerId);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement initState
    super.didChangeDependencies();

    playerParticipations =
        Provider.of<GamesProvider>(context).loggedUserParticipations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {},
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Logged in as $playerNickname, Team: $teamName !!'),
              Text(
                  'Hai partecipato a ${playerParticipations?.length} giocate!'),
              ElevatedButton(
                child: Text('Vai alla lista delle partite'),
                onPressed: () async {
                  await Navigator.of(context).pushNamed(GamesRoute.routeName);
                },
              ),
              ElevatedButton(
                child: Text('Logout'),
                onPressed:
                    Provider.of<LoginProvider>(context, listen: false).logOut,
              )
            ],
          ),
        ),
      ),
    );
  }
}
