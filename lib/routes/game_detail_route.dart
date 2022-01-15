import 'dart:ui';
import 'package:airsoft_tournament/helpers/map_opener.dart';
import 'package:airsoft_tournament/providers/game_provider.dart';
import 'package:airsoft_tournament/routes/game_invitations_route.dart';
import 'package:airsoft_tournament/widgets/dialogs/confirmation_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/game.dart';
import 'team_detail_route.dart';

import 'package:airsoft_tournament/models/game_participation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/providers/team_provider.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/routes/game_participations_route.dart';

import 'package:airsoft_tournament/widgets/box_and_texts/detail_routes_elements.dart';

import 'edit_game_route.dart';

class GameDetailRoute extends StatefulWidget {
  static const routeName = '/game-detail';

  @override
  _GameDetailRouteState createState() => _GameDetailRouteState();
}

class _GameDetailRouteState extends State<GameDetailRoute> {
  Player loggedPlayer;
  Game game;
  String gameId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    gameId = ModalRoute.of(context).settings.arguments;
    final games = Provider.of<GamesProvider>(context, listen: false).games;

    if (games.isNotEmpty)
      game = games.firstWhere((element) => element.id == gameId, orElse: null);

    loggedPlayer =
        Provider.of<LoginProvider>(context, listen: false).loggedPlayer;
    Provider.of<GamesProvider>(context, listen: false)
        .fetchAndSetLoggedUserParticipations(loggedPlayer.id);
  }

  void onModifyPop(Game editedGame) {
    if (editedGame != null) {
      setState(() {
        game = editedGame;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameProvider>(
        create: (context) => GameProvider(game),
        builder: (context, _) {
          return FutureBuilder(
              future: Future.wait([
                // Provider.of<GamesProvider>(context, listen: false)
                //     .getGameById(gameId)
                //     .then((value) => game = value),
                Provider.of<GameProvider>(context, listen: false)
                    .fetchAndSetGameParticipations(),
                Provider.of<GameProvider>(context, listen: false)
                    .fetchAndSetInvitations(),
              ]),
              builder: (context, snapshot) {
                return Scaffold(
                  // appBar: AppBar(),
                  body: snapshot.connectionState == ConnectionState.done
                      ? CustomScrollView(
                          slivers: [
                            GameCover(game, onModifyPop),
                            GameParticipations(game),
                            GameDetails(game),
                            _BottomButtons(game, loggedPlayer),
                          ],
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        ),
                );
              });
        });
  }
}

class GameCover extends StatelessWidget {
  final Game game;
  final Function editCallBack;

  GameCover(this.game, this.editCallBack);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      actions: [MenuPopUp(game, editCallBack)],
      pinned: true,
      floating: true,
      bottom: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 56),
        child: Container(
          // height: 56,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                game.title,
                style: kCardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
      forceElevated: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(
              game.imageUrl,
            ),
          ),
        ),
      ),
      expandedHeight: MediaQuery.of(context).size.width,
      elevation: 0,
    );
  }
}

class GameDetails extends StatelessWidget {
  final Game game;
  GameDetails(this.game);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          TitleAndInfo(
              'Data e Luogo',
              '${DateFormat('dd/MM/yyyy').format(game.date)}\n${game.place}',
              _openMapsButton(context, game.place)),
          TitleAndInfo('Descrizione', game.description),
        ],
      ),
    );
  }

  Widget _openMapsButton(BuildContext context, String query) {
    return GestureDetector(
      child: Icon(Icons.map_outlined),
      onTap: () => MapsLauncher.launchQuery(query),
    );
  }
}

class GameParticipations extends StatelessWidget {
  final Game game;

  GameParticipations(this.game);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final Player player =
            Provider.of<LoginProvider>(context, listen: false).loggedPlayer;
        final participations = gameProvider.gameParticipations;

        final hasReplied = participations.isEmpty
            ? false
            : participations.indexWhere(
                        (element) => element.playerId == player.id) >
                    -1
                ? true
                : false;

        final playerParticipation = hasReplied
            ? participations.where((p) => p.playerId == player.id).first
            : null;
        final isGoing = hasReplied ? playerParticipation.isGoing : false;
        final isPlayerInvited = player.teamId.compareTo(game.hostTeamId) == 0 ||
            gameProvider.isTeamInvited(player.teamId);

        return SliverList(
          delegate: SliverChildListDelegate(
            [
              if (!DateTime.now().isAfter(game.date) && isPlayerInvited)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Parteciperai?',
                            style: kMediumText,
                          ),
                        ),
                        ToggleButtons(
                          renderBorder: true,
                          borderWidth: 10,
                          borderRadius: BorderRadius.circular(24),
                          borderColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          selectedBorderColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'Parteciperò',
                                style: hasReplied && isGoing
                                    ? kMediumText
                                    : TextStyle(),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Non parteciperò',
                                style: hasReplied && !isGoing
                                    ? kMediumText
                                    : TextStyle(),
                              ),
                            ),
                          ],
                          isSelected: [
                            hasReplied && isGoing,
                            hasReplied && !isGoing,
                          ],
                          onPressed: (i) {
                            if (i == 0 && hasReplied && isGoing) return;
                            if (i == 1 && hasReplied && !isGoing) return;

                            final newParticipation = GameParticipation(
                              id: playerParticipation?.id,
                              gameId: game.id,
                              gameName: game.title,
                              isGoing: i == 0,
                              playerId: player.id,
                              playerName: player.nickname,
                              gameTeamId: game.hostTeamId,
                              gameTeamName: game.hostTeamName,
                              playerTeamId: player.teamId,
                              playerTeamName: player.teamName,
                            );

                            if (!hasReplied) {
                              gameProvider
                                  .addParticipation(newParticipation)
                                  .then((value) => Provider.of<GamesProvider>(
                                          context,
                                          listen: false)
                                      .addLoggedUserParticipation(value));
                            } else {
                              gameProvider.editParticipation(newParticipation);
                              Provider.of<GamesProvider>(context, listen: false)
                                  .editLoggedUserParticipation(
                                      newParticipation);
                            }
                          },
                        ),
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(
                    //       'Parteciperanno alla giocata ${gameParticipations.where((p) => p.isGoing).length} giocatori!'),
                    // ),
                  ],
                ),
              if (!DateTime.now().isAfter(game.date) && !isPlayerInvited)
                Row(
                  children: [
                    TeamPageButton(game),
                  ],
                ),
              if (DateTime.now().isAfter(game.date) && isPlayerInvited)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        !hasReplied
                            ? 'Non hai risposto alla giocata'
                            : isGoing
                                ? 'Hai partecipato a questa giocata'
                                : 'Non hai partecipato a questa giocata',
                        style: kMediumText,
                      ),
                    ),
                    // Text(
                    //     'Hanno partecipato a questa giocata ${gameParticipations.where((p) => p.isGoing).length} giocatori!'),
                  ],
                ),
              if (DateTime.now().isAfter(game.date) && !isPlayerInvited)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'La giocata è scaduta',
                        style: kMediumText,
                      ),
                    ),
                    // Text(
                    //     'Hanno partecipato a questa giocata ${gameParticipations.where((p) => p.isGoing).length} giocatori!'),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class MenuPopUp extends StatelessWidget {
  final Game game;
  final Function editCallback;

  MenuPopUp(this.game, this.editCallback);

  @override
  Widget build(BuildContext context) {
    final itemsList = [
      if (Provider.of<LoginProvider>(context, listen: false)
              .loggedPlayer
              .isGM &&
          Provider.of<LoginProvider>(context, listen: false)
                  .loggedPlayer
                  .teamId ==
              game.hostTeamId)
        PopupMenuItem(
          value: () => Navigator.of(context)
              .pushNamed(EditGameRoute.routeName, arguments: game)
              .then((value) => editCallback(value)),
          child: Text('Modifica'),
        ),
      if (Provider.of<LoginProvider>(context, listen: false)
              .loggedPlayer
              .isGM &&
          Provider.of<LoginProvider>(context, listen: false)
                  .loggedPlayer
                  .teamId ==
              game.hostTeamId)
        PopupMenuItem(
          value: () => showConfirmationDialog(context).then(
            (value) {
              if (value) {
                Provider.of<GamesProvider>(context, listen: false)
                    .deleteGame(game);
                Navigator.of(context).pop();
              }
            },
          ),
          child: Text('Elimina'),
        ),
      if (Provider.of<LoginProvider>(context, listen: false)
              .loggedPlayer
              .isGM &&
          Provider.of<LoginProvider>(context, listen: false)
                  .loggedPlayer
                  .teamId ==
              game.hostTeamId)
        PopupMenuItem(
          value: () {
            Navigator.of(context).pushNamed(GameInvitationsRoute.routeName,
                arguments: Provider.of<GameProvider>(context, listen: false));
          },
          child: Text('Invita altri Team'),
        ),
    ];

    return PopupMenuButton<Function>(
      enabled: itemsList.isNotEmpty,
      onSelected: (value) => value(),
      itemBuilder: (context) => itemsList,
      // offset: Offset(0, 50),
    );
  }
}

class _BottomButtons extends StatelessWidget {
  final Game game;
  final Player loggedPlayer;

  _BottomButtons(this.game, this.loggedPlayer);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Consumer<GameProvider>(
              builder: (context, gameProvider, _) => Row(
                children: [
                  if (gameProvider.isPlayerInvited(loggedPlayer))
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                            GameParticipationsRoute.routeName,
                            arguments: Provider.of<GameProvider>(context,
                                listen: false)),
                        child: Text('Lista dei partecipanti'),
                      ),
                    ),
                  if (game.attachmentUrl != null && game.attachmentUrl != '')
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => _openAttachment(game.attachmentUrl),
                        child: Row(
                          children: [
                            Icon(Icons.insert_link),
                            SizedBox(width: 8),
                            Text('Apri allegato'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _openAttachment(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class TeamPageButton extends StatefulWidget {
  final Game game;

  TeamPageButton(this.game);

  @override
  _TeamPageButtonState createState() => _TeamPageButtonState();
}

class _TeamPageButtonState extends State<TeamPageButton> {
  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  setState(() {
                    isLoading = true;
                  });

                  var hostTeam =
                      await Provider.of<TeamsProvider>(context, listen: false)
                          .getTeamById(widget.game.hostTeamId);

                  setState(() {
                    isLoading = false;
                  });

                  Navigator.pushNamed(context, TeamDetailRoute.routeName,
                      arguments: hostTeam);
                },
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text('Contatta i ${widget.game.hostTeamName}'),
        ),
      ),
    );
  }
}
