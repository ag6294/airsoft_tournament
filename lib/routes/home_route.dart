import 'package:airsoft_tournament/constants/style.dart';

import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/providers/team_provider.dart';
import 'package:airsoft_tournament/routes/player_edit_route.dart';
import 'package:airsoft_tournament/routes/team_detail_route.dart';
import 'package:airsoft_tournament/widgets/box_and_texts/kpibox.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import 'package:airsoft_tournament/routes/games_route.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';

import '../routes/team_edit_route.dart';

class HomeRoute extends StatefulWidget {
  static const routeName = '/home';

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        // ignore: missing_return
        onWillPop: () {},
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomePageTitle(),
                HomePageParticipations(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

PopupMenuButton _settingsMenu(BuildContext context) {
  final itemsList = [
    PopupMenuItem(
      value: () async {
        await Future.delayed(Duration(milliseconds: 500));
        Provider.of<GamesProvider>(context, listen: false).logOut();
        Provider.of<TeamsProvider>(context, listen: false).logOut();
        Provider.of<LoginProvider>(context, listen: false).logOut();
      },
      child: Text('Logout'),
    ),
    if (Provider.of<LoginProvider>(context, listen: false).loggedPlayer.isGM)
      PopupMenuItem(
        value: () => Navigator.pushNamed(context, TeamEditRoute.routeName,
            arguments: Provider.of<LoginProvider>(context, listen: false)
                .loggedPlayerTeam),
        child: Text('Impostazioni team'),
      ),
    PopupMenuItem(
      value: () => Navigator.pushNamed(context, PlayerEditRoute.routeName,
          arguments:
              Provider.of<LoginProvider>(context, listen: false).loggedPlayer),
      child: Text('Modifica profilo utente'),
    ),
  ];

  return PopupMenuButton<Function>(
    icon: Icon(Icons.settings),
    enabled: itemsList.isNotEmpty,
    onSelected: (value) {
      value.call();
    },
    //captureInheritedThemes: false,
    itemBuilder: (_) => itemsList,
    // offset: Offset(0, 50),
  );
}

class HomePageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 60, bottom: 8),
                  child: Text(
                    loginProvider.loggedPlayer.nickname,
                    style: kPageTitle,
                    // overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              _settingsMenu(context),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 60),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                  TeamDetailRoute.routeName,
                  arguments: loginProvider.loggedPlayerTeam),
              child: Text(
                loginProvider.loggedPlayer.isGM
                    ? 'Game Maker dei ${loginProvider.loggedPlayerTeam.name}'
                    : 'Associato dei ${loginProvider.loggedPlayerTeam.name}',
                // overflow: TextOverflow.ellipsis,
                style: kPageSubtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePageParticipations extends StatefulWidget {
  @override
  _HomePageParticipationsState createState() => _HomePageParticipationsState();
}

class _HomePageParticipationsState extends State<HomePageParticipations> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Provider.of<GamesProvider>(context, listen: false)
        .fetchAndSetLoggedUserParticipations(
            Provider.of<LoginProvider>(context, listen: false).loggedPlayer.id);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Consumer<GamesProvider>(
        builder: (context, games, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                KPIBox(
                    value: games.loggedUserParticipations
                        ?.where((element) => element.isGoing)
                        ?.length
                        ?.toString(),
                    label: 'Presenze'),
                KPIBox(
                    value: games.loggedUserParticipations
                        ?.where((element) => !element.isGoing)
                        ?.length
                        ?.toString(),
                    label: 'Assenze'),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: Text('Vai alla pagina del team'),
                      onPressed: () async =>
                          await Navigator.of(context).pushNamed(
                        TeamDetailRoute.routeName,
                        arguments:
                            Provider.of<LoginProvider>(context, listen: false)
                                .loggedPlayerTeam,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
