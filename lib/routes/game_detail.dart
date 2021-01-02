import 'dart:ui';

import 'package:airsoft_tournament/constants/style.dart';
import 'package:airsoft_tournament/models/game.dart';

import 'package:airsoft_tournament/models/game_participation.dart';
import 'package:airsoft_tournament/routes/games_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:airsoft_tournament/providers/games_provider.dart';
import 'package:airsoft_tournament/providers/login_provider.dart';
import 'package:airsoft_tournament/models/player.dart';
import 'package:airsoft_tournament/routes/game_participations.dart';

import 'edit_game_route.dart';

class GameDetailRoute extends StatefulWidget {
  static const routeName = '/game-detail';

  @override
  _GameDetailRouteState createState() => _GameDetailRouteState();
}

class _GameDetailRouteState extends State<GameDetailRoute> {
  Game game;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game = ModalRoute.of(context).settings.arguments;
  }

  void onModifyPop(Game editedGame) {
    setState(() {
      game = editedGame;
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<GamesProvider>(context, listen: false)
        .fetchAndSetGameParticipations(game.id);

    return Scaffold(
      // appBar: AppBar(),
      body: CustomScrollView(
        slivers: [
          GameCover(game, onModifyPop),
          GameParticipations(game),
          GameDetails(game),
        ],
      ),
    );
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
      floating: true,
      flexibleSpace: Hero(
        tag: game.id,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: Image.network(
            game.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
      expandedHeight: MediaQuery.of(context).size.width,
      pinned: true,
      elevation: 0,
      bottom: PreferredSize(
        child: Container(
          height: 56,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              game.title,
              style: kCardTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        preferredSize: Size.fromHeight(56),
      ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Luogo', style: kTitle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              game.place,
              style: kMediumText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Descrizione', style: kTitle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              game.description,
              style: kMediumText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Data', style: kTitle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat('dd/MM/yyyy').format(game.date),
              style: kMediumText,
            ),
          ),
        ],
      ),
    );
  }
}

class GameParticipations extends StatelessWidget {
  final Game game;

  GameParticipations(this.game);

  @override
  Widget build(BuildContext context) {
    return Consumer<GamesProvider>(builder: (context, gamesProvider, _) {
      final Player player =
          Provider.of<LoginProvider>(context, listen: false).loggedPlayer;
      final gameParticipations = gamesProvider.gameParticipations;

      final hasReplied = gameParticipations.isEmpty
          ? false
          : gameParticipations.indexWhere(((p) => p.playerId == player.id)) >
              -1;
      final playerParticipation = hasReplied
          ? gameParticipations.where((p) => p.playerId == player.id).first
          : null;
      final isGoing = hasReplied ? playerParticipation.isGoing : false;

      return SliverList(
        delegate: SliverChildListDelegate(
          [
            if (!DateTime.now().isAfter(game.date))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Parteciperai?'),
                      ),
                      ToggleButtons(
                        renderBorder: false,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Parteciperò',
                              style: kMediumText,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Non parteciperò',
                              style: kMediumText,
                            ),
                          ),
                        ],
                        isSelected: [
                          hasReplied && isGoing,
                          hasReplied && !isGoing,
                        ],
                        onPressed: (i) async {
                          if (i == 0 && hasReplied && isGoing) return;
                          if (i == 1 && hasReplied && !isGoing) return;

                          final newParticipation = GameParticipation(
                            id: playerParticipation?.id,
                            gameId: game.id,
                            gameName: game.title,
                            isGoing: i == 0,
                            playerId: player.id,
                            playerName: player.nickname,
                          );

                          // playerParticipation = newParticipation;
                          // hasReplied = true;
                          await gamesProvider
                              .editParticipation(newParticipation);
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        'Parteciperanno alla giocata ${gameParticipations.where((p) => p.isGoing).length} giocatori!'),
                  ),
                ],
              ),
            if (DateTime.now().isAfter(game.date))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    !hasReplied
                        ? 'Non hai risposto alla giocata'
                        : isGoing
                            ? 'Hai partecipato a questa giocata'
                            : 'Non hai partecipato a questa giocata',
                    style: kMediumText,
                  ),
                  Text(
                      'Hanno partecipato a questa giocata ${gameParticipations.where((p) => p.isGoing).length} giocatori!'),
                ],
              ),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                  GameParticipationsRoute.routeName,
                  arguments: game),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Vai alla lista dei partecipanti',
                  style: kMediumText,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class MenuPopUp extends StatelessWidget {
  final Game game;
  final Function editCallback;

  MenuPopUp(this.game, this.editCallback);

  @override
  Widget build(BuildContext context) {
    final itemsList = [
      if (Provider.of<LoginProvider>(context, listen: false).loggedPlayer.isGM)
        PopupMenuItem(
          value: () => Navigator.of(context)
              .pushNamed(EditGameRoute.routeName, arguments: game)
              .then((value) => editCallback(value)),
          child: Text('Modifica'),
        ),
      if (Provider.of<LoginProvider>(context, listen: false).loggedPlayer.isGM)
        PopupMenuItem(
          value: () {
            Provider.of<GamesProvider>(context, listen: false).deleteGame(game);
            Navigator.of(context).pop();
          },
          child: Text('Elimina'),
        ),
    ];

    return PopupMenuButton<Function>(
      enabled: itemsList.isNotEmpty,
      onSelected: (value) => value(),
      itemBuilder: (context) => itemsList,
      offset: Offset(0, 50),
    );
  }
}
