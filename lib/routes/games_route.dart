import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/routes/edit_game_route.dart';
import 'package:airsoft_tournament/routes/game_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/models/game.dart';

class GamesRoute extends StatefulWidget {
  static const routeName = '/games';

  @override
  _GamesRouteState createState() => _GamesRouteState();
}

class _GamesRouteState extends State<GamesRoute> {
  @override
  Widget build(BuildContext context) {
    final teamId =
        Provider.of<LoginProvider>(context, listen: false).loggedPlayer.teamId;

    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<GamesProvider>(context).fetchAndSetGames(teamId),
        builder: (context, snapshot) {
          var list = snapshot.hasData ? snapshot.data : [];

          return ModalProgressHUD(
            inAsyncCall: snapshot.connectionState != ConnectionState.done,
            child: RefreshIndicator(
              onRefresh: () async {
                list = await Provider.of<GamesProvider>(context, listen: false)
                    .fetchAndSetGames(teamId);
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Center(child: Text('Le tue giocate')),
                    actions: [_menuPopup(context)],
                    floating: true,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => GameCard(list[index]),
                      childCount: list.length,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard(this.game);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .pushNamed(GameDetailRoute.routeName, arguments: game),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              if (game.imageUrl != null)
                AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Hero(
                    tag: game.id,
                    child: Image.network(
                      game.imageUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  game.title,
                  style: kCardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

PopupMenuButton<String> _menuPopup(BuildContext context) {
  final itemsList = [
    if (Provider.of<LoginProvider>(context, listen: false).loggedPlayer.isGM)
      PopupMenuItem(
        value: EditGameRoute.routeName,
        child: Text('Crea una giocata'),
      ),
  ];

  return PopupMenuButton<String>(
    enabled: itemsList.isNotEmpty,
    onSelected: (value) => Navigator.of(context).pushNamed(value),
    itemBuilder: (context) => itemsList,
    offset: Offset(0, 50),
  );
}
