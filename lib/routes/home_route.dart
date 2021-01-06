import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/widgets/box_and_texts/kpibox.dart';
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
  bool isGM;
  List<GameParticipation> playerParticipations = [];

  @override
  void initState() {
    super.initState();
    playerId = Provider.of<LoginProvider>(
      context,
      listen: false,
    ).loggedPlayer.id;
    playerNickname = Provider.of<LoginProvider>(
      context,
      listen: false,
    ).loggedPlayer.nickname;
    isGM = Provider.of<LoginProvider>(
      context,
      listen: false,
    ).loggedPlayer.isGM;
    teamName = Provider.of<LoginProvider>(
      context,
      listen: false,
    ).loggedPlayerTeam.name;
    Provider.of<GamesProvider>(context, listen: false)
        .fetchAndSetLoggedUserParticipations(playerId);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    playerParticipations =
        Provider.of<GamesProvider>(context).loggedUserParticipations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {},
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 60, bottom: 8),
                        child: Text(
                          playerNickname,
                          style: kPageTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _settingsMenu(context),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 60),
                    child: Text(
                      isGM
                          ? 'Game Maker dei $teamName'
                          : 'Associato dei $teamName',
                      overflow: TextOverflow.ellipsis,
                      style: kPageSubtitle,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      KPIBox(
                          value: playerParticipations
                              ?.where((element) => element.isGoing)
                              ?.length
                              ?.toString(),
                          label: 'Presenze'),
                      KPIBox(
                          value: playerParticipations
                              ?.where((element) => !element.isGoing)
                              ?.length
                              ?.toString(),
                          label: 'Assenze'),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: Text('Vai alla lista delle partite'),
                      onPressed: () async {
                        await Navigator.of(context)
                            .pushNamed(GamesRoute.routeName);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PopupMenuButton _settingsMenu(BuildContext context) {
  final itemsList = [
    PopupMenuItem(
      value: () => Provider.of<LoginProvider>(context, listen: false).logOut(),
      child: Text('Logout'),
    ),
    if (Provider.of<LoginProvider>(context, listen: false).loggedPlayer.isGM)
      PopupMenuItem(
        value: () {},
        child: Text('Impostazioni team'),
      ),
  ];

  return PopupMenuButton<Function>(
    icon: Icon(Icons.settings),
    enabled: itemsList.isNotEmpty,
    onSelected: (value) {
      value.call();
    },
    captureInheritedThemes: false,
    itemBuilder: (_) => itemsList,
    offset: Offset(0, 50),
  );
}
