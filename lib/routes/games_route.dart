import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/routes/edit_game_route.dart';
import 'package:airsoft_tournament/routes/game_detail_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'package:intl/intl.dart';

class GamesRoute extends StatefulWidget {
  static const routeName = '/games';

  @override
  _GamesRouteState createState() => _GamesRouteState();
}

class _GamesRouteState extends State<GamesRoute> {
  bool isSearching = false;
  final searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamId =
        Provider.of<LoginProvider>(context, listen: false).loggedPlayer.teamId;

    return WillPopScope(
      onWillPop: () {
        Provider.of<GamesProvider>(context, listen: false)
            .filterGamesByTitleOrTeam(null);
        return Future.value(true);
      },
      child: Scaffold(
        body: FutureBuilder(
          future: Provider.of<GamesProvider>(context, listen: false)
              .fetchAndSetGames(teamId, false),
          builder: (context, snapshot) {
            return ModalProgressHUD(
              inAsyncCall: snapshot.connectionState != ConnectionState.done,
              child: RefreshIndicator(
                onRefresh: () async {
                  await Provider.of<GamesProvider>(
                    context,
                    listen: false,
                  ).fetchAndSetGames(teamId, true);
                },
                child: Consumer<GamesProvider>(
                    builder: (context, gamesProvider, _) {
                  final list =
                      Provider.of<GamesProvider>(context).filteredGames;

                  return CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        title: isSearching
                            ? TextField(
                                autofocus: true,
                                controller: searchController,
                                decoration: InputDecoration(
                                    hintText: 'Filtra per titolo o squadra'),
                                onChanged: (value) =>
                                    Provider.of<GamesProvider>(context,
                                            listen: false)
                                        .filterGamesByTitleOrTeam(
                                            value.toLowerCase()),
                              )
                            : Center(child: Text('Le tue giocate')),
                        actions: [
                          if (isSearching)
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  isSearching = false;
                                  searchController.clear();
                                  Provider.of<GamesProvider>(context,
                                          listen: false)
                                      .filterGamesByTitleOrTeam(null);
                                });
                              },
                            ),
                          if (!isSearching)
                            IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  setState(() {
                                    isSearching = true;
                                  });
                                }),
                          if (!isSearching) _menuPopup(context)
                        ],
                        floating: true,
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => GameCard(list[index]),
                          childCount: list.length,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            );
          },
        ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  game.title,
                  style: kCardTitle,
                  // maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 12.0,
                        bottom: 12.0,
                        right: 12.0,
                      ),
                      child: Text(
                        game.hostTeamName + ', ' + game.place,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 12.0,
                      bottom: 12.0,
                    ),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(game.date),
                    ),
                  )
                ],
              )
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
    // offset: Offset(0, 50),
  );
}
